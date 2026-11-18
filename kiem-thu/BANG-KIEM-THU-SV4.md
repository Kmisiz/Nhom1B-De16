
# Bảng Kiểm Thử Hệ Thống (SV4 - Đề 16, Nhóm 1B)

| Mã | Đầu vào | Thao tác | Kết quả mong đợi | Kết quả thực tế | Đánh giá | Bằng chứng |
|---|---|---|---|---|---|---|
| KT1.1 | Tài khoản khách hàng hợp lệ | Đăng nhập và gọi `/api/my-account` | HTTP 200, đúng số dư | Đăng nhập HTTP 200; `/api/my-account` HTTP 200, tài khoản `1900888801`, số dư 48.996.000 VND | Đạt | `"kiem-thu\bang-chung\minhchung-SV4\kt1.1.jpg` |
| KT1.2 | Token của khách hàng | Gọi `/api/admin/audit-logs` | HTTP 403; có dòng `ACTION=RBAC` trạng thái bị từ chối trong log | Đăng nhập HTTP 200; `/api/admin/audit-logs` HTTP 403; log có `USER=user1 \| ACTION=RBAC \| STATUS=DENIED` lúc 11:32:20 | Đạt | `"kiem-thu\bang-chung\minhchung-SV4\kt12.jpg` |
| KT2.1 | vps1 | `nc -zv -w 3 10.10.10.30 5432` | Hết thời gian chờ | `nc` báo `timed out`; script in `KT2.1 PASS` | Đạt |`kiem-thu\bang-chung\minhchung-SV4\kt21.jpg` |
| KT2.2 | vps2 | `nc -zv -w 3 10.10.10.30 5432` | Kết nối thành công | `nc` báo `Connection to 10.10.10.30 5432 port [tcp/postgresql] succeeded!`; script in `KT2.2 PASS` | Đạt | `kiem-thu\bang-chung\minhchung-SV4\kt22.jpg` |
| KT3.1 | Tài khoản hợp lệ, sai mật khẩu | Đăng nhập sai 3 lần | HTTP 401; log ở vps4 và `audit_logs` đều có sự kiện `LOGIN` trạng thái `FAILED` | HTTP 401 cả 3 lần; mỗi lần có dòng `LOGIN \| FAILED` ở log gốc vps2, kho log vps4 và bảng `audit_logs` | Đạt | `kiem-thu\bang-chung\minhchung-SV4\kt31.jpg`, ảnh mục 6.1 (a) và (b) |
| KT3.2 | CSDL `digital_bank` | Sao lưu, xóa dữ liệu bảng tài khoản, phục hồi, kiểm tra quyền | Dữ liệu nguyên trạng; `bank_app` không chạy được `DELETE` trên `audit_logs` và `DROP TABLE` | Sao lưu AES-256, xóa trắng `transactions` và `accounts`, phục hồi: checksum trước và sau trùng khớp; `bank_app` bị từ chối `DELETE`, `UPDATE`, `TRUNCATE`, `DROP` trên `audit_logs`; `kt32_test.sh` báo `KT3.2 PASS` | Đạt | `kiem-thu\bang-chung\minhchung-SV4\kt32.jpg`, `tests/sv3/evidence/20261108_04-quyen-toi-thieu.log`, `kiem-thu\bang-chung\minhchung-SV4\kt32 (2).jpg` |




