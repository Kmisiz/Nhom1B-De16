# Bảng Kiểm Thử Hệ Thống (SV2 - Đề 16, Nhóm 1B)

| Đầu vào | Thao tác thực hiện | Kết quả mong đợi | Kết quả thực tế | Đánh giá (Đạt / Chưa đạt) | Bằng chứng xác thực |
| :--- | :--- | :--- | :--- | :--- | :--- |
| ps0 | Ping/kết nối tới ps2 | Timed out | Connection timed out | Đạt | kiem-thu/bang-chung/KT2/KT2-vps0-chan-vps2.png |
| ps0 | Ping/kết nối tới ps3 | Timed out | Timed out | Đạt | kiem-thu/bang-chung/KT2/KT2-vps0-chan-vps3.png |
| ps1 | Ping/kết nối tới ps3 | Timed out | Timed out | Đạt | kiem-thu/bang-chung/KT2/KT2-vps1-chan-vps3.png |
| ps2 | Kết nối cơ sở dữ liệu ps3 | Succeeded | Connection succeeded | Đạt | kiem-thu/bang-chung/KT2/KT2-vps2-vao-vps3.png |
| Trình duyệt | Truy cập trang chủ HTTPS | HTTP 200 | HTTP 200 | Đạt | kiem-thu/bang-chung/KT2/KT2-https-home.png |
| Trình duyệt | Truy cập đường dẫn /admin | HTTP 404 | HTTP 404 | Đạt | kiem-thu/bang-chung/KT2/KT2-admin-404.png |
| Trình duyệt | Gửi payload SQL Injection | HTTP 403 | HTTP 403 (WAF Blocked) | Đạt | kiem-thu/bang-chung/KT2/KT2-waf-sqli.png |
| Trình duyệt | Đăng nhập sai thông tin | HTTP 401 | HTTP 401 (Unauthorized) | Đạt | kiem-thu/bang-chung/KT2/KT2-login-401.png |
| Trình duyệt | Gửi request liên tục (Rate Limit) | HTTP 429 | HTTP 429 (Too Many Requests) | Đạt | kiem-thu/bang-chung/KT2/KT2-ratelimit-429.png |
| Trình duyệt | Kiểm tra giao diện & ổ khóa HTTPS | Hiển thị OK | Hiển thị OK, có ổ khóa | Đạt | kiem-thu/bang-chung/KT2/KT2-browser-ui.png |
