# Đề 16: Thiết kế hạ tầng CNTT an toàn cho ngân hàng số

Học phần Nhập môn Công nghệ nền tảng (RIPT1304), Nhóm 1B.

**Ngân hàng Số Mười Sáu** là mô hình ngân hàng số giả định. Nhóm dựng 5 máy ảo Ubuntu trên Google Cloud, tách thành 5 vùng có kiểm soát: khách hàng, công khai, ứng dụng, dữ liệu và quản trị. Hệ thống chỉ dùng dữ liệu giả lập, không xử lý giao dịch tài chính thật. Báo cáo chính, video và phiếu đóng góp cá nhân nộp riêng.

## 1. Thành viên và phân công

| Họ tên | MSSV | Vai trò | Phụ trách |
|---|---|---|---|
| Đỗ Quốc Khánh | B24DCCC157 | SV1 | Kiến trúc và phân tích nguy cơ, hạ tầng GCP, Wazuh SIEM giám sát 5 máy, so sánh Wazuh với rsyslog (mở rộng tự chọn), tích hợp |
| Vũ Trọng Hiếu | B24DCCC122 | SV2 | Phân vùng và lọc truy cập: UFW, luật VPC, Nginx trên vps0 và vps1 |
| Trần Đức Thắng | B24DCCC246 | SV3 | Xác thực, dữ liệu, sao lưu: backend vps2, PostgreSQL vps3, sao lưu mã hóa và phục hồi |
| Đào Anh Đức | B24DCCC066 | SV4 | Kiểm thử chính sách và nhật ký: audit log ba tầng, luồng log thô rsyslog, KT1–KT3 |

## 2. Kiến trúc hệ thống

![Kiến trúc 5 tầng](tai-lieu-ky-thuat/thiet-ke/01-kien-truc-5-tang.png)

```text
Khách hàng ──443──► vps0-web-public   10.10.10.5   Nginx, TLS, giao diện web
                        │ 8080
                        ▼
                    vps1-dmz-fw       10.10.10.10  Nginx WAF, giới hạn tần suất
                        │ 8080
                        ▼
                    vps2-app-api      10.10.10.20  FastAPI, JWT, RBAC, audit log
                        │ 5432
                        ▼
                    vps3-data-db      10.10.10.30  PostgreSQL, sao lưu mã hóa

Quản trị ──SSH──► vps4-mgmt-log       10.10.10.40  Bastion, rsyslog tập trung,
                                                   Wazuh server + indexer + dashboard
```

Mỗi chặng chỉ mở đúng một cổng cho đúng một máy nguồn. Mặc định chặn mọi kết nối đến, áp ở hai lớp: luật VPC theo network tag và UFW trong từng máy. vps0–vps3 cài Wazuh agent, gửi sự kiện về vps4.

## 3. Tài liệu thiết kế

Toàn bộ nằm trong [`tai-lieu-ky-thuat/thiet-ke/`](tai-lieu-ky-thuat/thiet-ke/).

| File | Nội dung |
|---|---|
| [`01-kien-truc-5-tang.png`](tai-lieu-ky-thuat/thiet-ke/01-kien-truc-5-tang.png) | Kiến trúc 5 tầng, luồng truy cập từ khách hàng tới dữ liệu |
| [`02-phan-vung-loc-truy-cap.png`](tai-lieu-ky-thuat/thiet-ke/02-phan-vung-loc-truy-cap.png) | Phân vùng và lọc truy cập: mặc định chặn, chỉ mở luồng cần thiết (FW-01 đến FW-12) |
| [`03-nguy-co-bien-phap.png`](tai-lieu-ky-thuat/thiet-ke/03-nguy-co-bien-phap.png) | Năm nguy cơ NC1–NC5, biện pháp và bài kiểm thử tương ứng |
| [`04-nhat-ky-giam-sat.png`](tai-lieu-ky-thuat/thiet-ke/04-nhat-ky-giam-sat.png) | Nhật ký và giám sát: hai luồng độc lập về vps4 (rsyslog log thô, Wazuh SIEM) |
| [`bang-quy-hoach.md`](tai-lieu-ky-thuat/thiet-ke/bang-quy-hoach.md) | Tài nguyên và IP từng máy, cổng lắng nghe, luật lọc FW-01 đến FW-12, ma trận phân quyền API và CSDL |

## 4. Môi trường triển khai

| Thành phần | Giá trị |
|---|---|
| Nền tảng | Google Cloud, region `asia-southeast1`, zone `asia-southeast1-b` |
| Mạng | VPC `bank-vpc`, subnet `10.10.10.0/24`, Cloud NAT cho vps2 và vps3 |
| Máy ảo | `e2-small` (vps0–vps3), `e2-medium` (vps4) |
| Hệ điều hành | Ubuntu 22.04 LTS |
| Cơ sở dữ liệu | PostgreSQL 14 |
| SIEM | Wazuh 4.14, all-in-one trên vps4 |
| Ứng dụng | FastAPI (Python), giao diện HTML, CSS, JavaScript |

## 5. Phạm vi và giả định

- Chỉ dùng dữ liệu giả lập, không kết nối hệ thống ngân hàng thật.
- Hệ thống chạy trên máy ảo thật ở Google Cloud, không dùng file mô phỏng Packet Tracer (`.pkt`).
- vps2 và vps3 không có IP công khai, chỉ ra Internet qua Cloud NAT (chiều đi) để cài gói.
- Dashboard Wazuh không mở ra Internet, quản trị viên truy cập qua SSH tunnel vào vps4.
- vps4 chạy Wazuh all-in-one với 4 GB RAM, thấp hơn mức khuyến nghị 8 GB của Wazuh.

## 6. Nguồn tham khảo

- Tài liệu chính thức: Wazuh, Nginx, PostgreSQL, FastAPI, rsyslog, Google Cloud (VPC firewall, Cloud NAT), Let's Encrypt.
- Các thành viên dùng công cụ AI hỗ trợ soạn tài liệu. Phạm vi hỗ trợ và phần tự chỉnh sửa, tự kiểm chứng của từng người khai trong báo cáo cá nhân.
