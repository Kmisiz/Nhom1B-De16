# Bảng Kiểm Thử Hệ Thống (SV4 - Đề 16, Nhóm 1B)

| Đầu vào | Thao tác | Kết quả mong đợi | Kết quả thực tế | Đánh giá | Bằng chứng |
|---|---|---|---|---|---|
| **KT1.1** – Tài khoản khách hàng hợp lệ | Đăng nhập và gọi `/api/my-account` | HTTP 200, trả về đúng thông tin tài khoản | Đăng nhập HTTP 200; `/api/my-account` HTTP 200; tài khoản `1900888801`, số dư 48.996.000 VND | Đạt | `kiem-thu/bang-chung/KT1/k11- Dang nhap va xem tai khoan.jpg` |
| **KT1.2** – Token của tài khoản khách hàng | Gọi `/api/admin/audit-logs` | HTTP 403; khách hàng không được truy cập chức năng quản trị | Đăng nhập HTTP 200; `/api/admin/audit-logs` HTTP 403; phản hồi từ chối quyền truy cập | Đạt | `kiem-thu/bang-chung/KT1/kt12- tu choi quyen admin.jpg` |
| **KT2.1** – VPS1 | Chạy `nc -zv -w 3 10.10.10.30 5432` | Kết nối bị chặn, hết thời gian chờ | `nc` báo `timed out`; script in `KT2.1 PASS` | Đạt | `kiem-thu/bang-chung/KT2/KT2-vps1-chan-vps3.png` |
| **KT2.2** – VPS2 | Chạy `nc -zv -w 3 10.10.10.30 5432` | Kết nối PostgreSQL thành công | `nc` báo kết nối tới `10.10.10.30:5432` thành công; script in `KT2.2 PASS` | Đạt | `kiem-thu/bang-chung/KT2/KT2-vps2-vao-vps3.png` |
| **KT3.1** – Tài khoản `user1`, mật khẩu sai | Thực hiện 3 lần đăng nhập thất bại | Cả 3 lần trả HTTP 401; sự kiện được ghi nhận ở log tập trung, PostgreSQL và Wazuh | 3/3 lần trả HTTP 401; VPS4 ghi nhận 3 sự kiện `LOGIN FAILED`; PostgreSQL VPS3 ghi nhận 3 bản ghi tương ứng; Wazuh ghi nhận 3 cảnh báo rule `100102` | Đạt | `kiem-thu/bang-chung/KT3/kt31- 3 lan dang nhap sai.jpg`; `kiem-thu/bang-chung/KT3/KT3.1-vps4-log-tap-trung.jpg`; `kiem-thu/bang-chung/KT3/KT3.1-vps3-postgresql-audit.jpg`; `kiem-thu/bang-chung/KT3/KT3.1-vps4-wazuh-alerts.jpg` |
| **KT3.2** – CSDL `digital_bank` | Chạy `kt32_test.sh` để kiểm tra quyền của `bank_app` trên `audit_logs` | Tài khoản `bank_app` không có quyền `DELETE` và `DROP` trên `audit_logs` | `DELETE_BLOCKED: t`; `DROP_BLOCKED: t`; script in `KT3.2 PASS` | Đạt | `kiem-thu/bang-chung/KT3/KT3.2-vps3-bao-ve-audit-logs.jpg` |

