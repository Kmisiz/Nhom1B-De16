# ĐỐI SOÁT SỰ KIỆN ĐĂNG NHẬP SAI TỪ 3 NGUỒN

## 1. Phạm vi kiểm thử

Thực hiện demo 5.1 ngày 23/11/2026: tạo 3 lần đăng nhập sai bằng tài khoản `user1` trên VPS2. Đối chiếu số lượng sự kiện tại log tập trung VPS4, PostgreSQL VPS3 và Wazuh VPS4.

## 2. Bảng đối soát

| Nguồn dữ liệu | Trước khi thử | Sau khi thử | Mức tăng | Kết quả |
|---|---:|---:|---:|---|
| Log tập trung VPS4 | 6 | 9 | +3 | Khớp |
| PostgreSQL VPS3 (`audit_logs`) | 52 | 55 | +3 | Khớp |
| Wazuh VPS4 (rule `100102`) | 6 | 9 | +3 | Khớp |

## 3. Kết luận

Sau khi thực hiện 3 lần đăng nhập sai trên VPS2, cả ba nguồn dữ liệu đều tăng thêm đúng 3 sự kiện. Các lần đăng nhập đều trả về HTTP 401.

Kết quả cho thấy luồng ghi nhận sự kiện đăng nhập thất bại từ ứng dụng, chuyển tiếp đến log tập trung, lưu trữ trong PostgreSQL và giám sát bằng Wazuh hoạt động đúng trong phạm vi demo 5.1.

**Thời gian kiểm thử:** 23/11/2026, khoảng 04:20–04:26 UTC.
