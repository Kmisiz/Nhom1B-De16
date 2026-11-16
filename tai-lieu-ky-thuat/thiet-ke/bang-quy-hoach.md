# Bảng quy hoạch hệ thống

Ngân hàng Số Mười Sáu: 5 máy ảo trên Google Cloud, dữ liệu giả lập. Nguồn số liệu: README, `cau-hinh/`, `ma-nguon/backend/main.py`, `ma-nguon/database/init_db.sql`.

## 1. Phân bổ tài nguyên và chia IP

Môi trường: Google Cloud, region `asia-southeast1`, zone `asia-southeast1-b`, mạng `bank-vpc` dải `10.10.10.0/24`, Ubuntu 22.04 LTS.

| Máy | Vùng | IP nội bộ | IP công khai | Machine type | vCPU / RAM | Đĩa | Dịch vụ chính |
|---|---|---|---|---|---|---|---|
| `vps0-web-public` | Công khai | 10.10.10.5 | Có | e2-small | 2 / 2 GB | 20 GB | Nginx, TLS, giao diện web, Wazuh agent |
| `vps1-dmz-fw` | DMZ | 10.10.10.10 | Có | e2-small | 2 / 2 GB | 20 GB | Nginx WAF, giới hạn tần suất, Wazuh agent |
| `vps2-app-api` | Ứng dụng | 10.10.10.20 | Không | e2-small | 2 / 2 GB | 20 GB | FastAPI (`bank-app`), rsyslog chuyển log, Wazuh agent |
| `vps3-data-db` | Dữ liệu | 10.10.10.30 | Không | e2-small | 2 / 2 GB | 20 GB | PostgreSQL 14, sao lưu mã hóa, Wazuh agent |
| `vps4-mgmt-log` | Quản trị | 10.10.10.40 | Có | e2-medium | 2 / 4 GB | 50 GB | Bastion SSH, rsyslog tập trung, Wazuh server + indexer + dashboard |

vps2 và vps3 không có IP công khai, ra Internet qua Cloud NAT (chỉ chiều đi) để cài gói.

### Cổng lắng nghe trên từng máy

| Máy | Cổng | Dịch vụ | Nhận từ |
|---|---|---|---|
| vps0 | 80, 443 | Nginx | Internet |
| vps1 | 8080 | Nginx WAF | vps0 |
| vps2 | 8080 | FastAPI (uvicorn) | vps1 |
| vps3 | 5432 | PostgreSQL | vps2 |
| vps4 | 514 | rsyslog | vps0–vps3 |
| vps4 | 1514, 1515 | Wazuh (sự kiện, đăng ký agent) | vps0–vps3 |
| vps4 | 443 | Dashboard Wazuh | Không mở trên UFW, chỉ qua SSH tunnel |
| vps0–vps4 | 22 | SSH | vps4 vào vps0–vps3; quản trị viên vào vps4 |

Cổng 8080 là cổng nội bộ của hai chặng vps0 → vps1 và vps1 → vps2, không phải cổng bảo mật riêng. Bảo vệ nằm ở chỗ ai được gọi vào cổng đó.

> Mũi tên trong sơ đồ chỉ chiều khởi tạo kết nối (client → server). Cổng là cổng của máy nhận. Phản hồi quay lại trên chính kết nối đó.

### Luật lọc chính

Mặc định chặn mọi kết nối đến, áp ở hai lớp: luật VPC (network tag) và UFW trong từng máy.

| Mã | Nguồn | Đích | Cổng | Hành động |
|---|---|---|---|---|
| FW-01 | Internet | vps0 | TCP 80, 443 | Cho phép |
| FW-02 | vps0 | vps1 | TCP 8080 | Cho phép |
| FW-03 | vps0 | vps2, vps3 | Tất cả | Chặn |
| FW-04 | vps1 | vps2 | TCP 8080 | Cho phép |
| FW-05 | vps1 | vps3 | TCP 5432 | Chặn |
| FW-06 | vps2 | vps3 | TCP 5432 | Cho phép |
| FW-07 | vps4 | vps3 | TCP 5432 | Chặn (sao lưu chạy ngay trên vps3) |
| FW-08 | vps4 | vps0–vps3 | TCP 22 | Cho phép |
| FW-09 | vps0–vps3 | vps4 | TCP 514 | Cho phép (rsyslog, chỉ TCP) |
| FW-10 | vps0–vps3 | vps4 | TCP 1514 | Cho phép (Wazuh agent gửi sự kiện) |
| FW-11 | vps0–vps3 | vps4 | TCP 1515 | Cho phép (Wazuh agent đăng ký) |
| FW-12 | Quản trị viên | vps4 | TCP 443 | Không mở trên UFW; chỉ qua SSH tunnel |

Đầu ra `ufw status verbose` từng máy nằm ở `cau-hinh/<máy>/<máy>.txt`.

## 2. Ma trận phân quyền

Ba vai trò: `customer`, `teller`, `admin`. Cấp quyền ở `ma-nguon/backend/main.py` (`require_roles`). Chưa đăng nhập trả 401, sai vai trò trả 403 và ghi audit `DENIED`.

### 2.1. Theo API

| API | Chưa đăng nhập | customer | teller | admin |
|---|---|---|---|---|
| `GET /api/health` | Có | Có | Có | Có |
| `POST /api/login` | Có | Có | Có | Có |
| `POST /api/logout` | Có | Có | Có | Có |
| `GET /api/me` | 401 | Có | Có | Có |
| `GET /api/auth/staff-check` (Nginx gọi nội bộ để chặn `/admin`) | 401 | 403 | Có (204) | Có (204) |
| `GET /api/my-account` | 401 | Có | 403 | 403 |
| `GET /api/my-transactions` | 401 | Có | 403 | 403 |
| `GET /api/accounts/lookup` | 401 | Có | 403 | 403 |
| `POST /api/transfer` | 401 | Có | 403 | 403 |
| `GET /api/accounts` | 401 | 403 | Có | Có |
| `GET /api/admin/users` | 401 | 403 | 403 | Có |
| `POST /api/admin/users` | 401 | 403 | 403 | Có |
| `PATCH /api/admin/users/{username}/status` | 401 | 403 | 403 | Có |
| `GET /api/admin/audit-logs` | 401 | 403 | 403 | Có |
| Trang `/admin` (Nginx `auth_request`) | 404 | 404 | Có | Có |

### 2.2. Quyền của tài khoản CSDL `bank_app`

Backend (vps2) kết nối PostgreSQL bằng `bank_app`, quyền tối thiểu (`ma-nguon/database/init_db.sql`).

| Đối tượng | SELECT | INSERT | UPDATE | DELETE | TRUNCATE / DROP |
|---|---|---|---|---|---|
| `users`, `accounts`, `transactions` | Có | Có | Có | Không | Không |
| `audit_logs` | Có | Có | Không | Không | Không |
| Sequence | Có (USAGE, SELECT) | | | | |

`pg_hba.conf` trên vps3 chỉ nhận `bank_app` vào `digital_bank` từ `10.10.10.20/32` bằng `scram-sha-256`.
