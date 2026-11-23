# Bảng Kiểm Thử Hệ Thống (SV2 - Đề 16, Nhóm 1B)

| Đầu vào | Thao tác thực hiện | Kết quả mong đợi | Kết quả thực tế | Đánh giá (Đạt / Chưa đạt) | Bằng chứng xác thực |
| :--- | :--- | :--- | :--- | :--- | :--- |
| vps0 | curl -m 3 http://10.10.10.20:8080/api/health (vps0 gọi thẳng API vps2) | Timed out | Connection timed out after 3001 milliseconds | Đạt | kiem-thu/bang-chung/KT2/KT2-vps0-chan-vps2.png |
| vps0 | nc -zv -w 3 10.10.10.30 5432 (vps0 tới CSDL vps3) | Timed out | Timed out | Đạt | kiem-thu/bang-chung/KT2/KT2-vps0-chan-vps3.png |
| vps1 | nc -zv -w 3 10.10.10.30 5432 (vps1 tới CSDL vps3) | Timed out | Timed out | Đạt | kiem-thu/bang-chung/KT2/KT2-vps1-chan-vps3.png |
| vps2 | nc -zv -w 3 10.10.10.30 5432 (vps2 tới CSDL vps3, đối chứng) | Succeeded | Connection succeeded | Đạt | kiem-thu/bang-chung/KT2/KT2-vps2-vao-vps3.png |
| Máy cá nhân, curl.exe | Truy cập trang chủ https://muoisaubank16.duckdns.org/ | HTTP 200 | HTTP 200 | Đạt | kiem-thu/bang-chung/KT2/KT2-https-home.png |
| Máy cá nhân, curl.exe | Truy cập /admin khi chưa đăng nhập | HTTP 404 | HTTP 404 | Đạt | kiem-thu/bang-chung/KT2/KT2-admin-404.png |
| Máy cá nhân, curl.exe | Gửi UNION SELECT trên URL /api/accounts | HTTP 403 | HTTP 403 (WAF Blocked) | Đạt | kiem-thu/bang-chung/KT2/KT2-waf-sqli.png |
| Máy cá nhân, curl.exe | Đăng nhập user1 sai mật khẩu qua /api/login | HTTP 401 | HTTP 401 (Unauthorized) | Đạt | kiem-thu/bang-chung/KT2/KT2-login-401.png |
| vps4, vòng lặp curl tới WAF vps1 | Gửi 8 lần đăng nhập sai liên tiếp, X-Real-IP 203.0.113.16 | Lần 1-4 HTTP 401, từ lần 5 HTTP 429 | Lần 1-4 HTTP 401, lần 5-8 HTTP 429 | Đạt | kiem-thu/bang-chung/KT2/KT2-ratelimit-429.png |
| Trình duyệt | Mở trang chủ, kiểm tra giao diện và ổ khóa HTTPS | Hiển thị OK | Hiển thị OK, có ổ khóa | Đạt | kiem-thu/bang-chung/KT2/KT2-browser-ui.png |

