# So sánh hai luồng giám sát: rsyslog (log thô) và Wazuh (SIEM)

Hệ thống chạy song song hai luồng trên cùng nguồn log. rsyslog chuyển nguyên văn log ứng dụng từ vps2 về vps4 (`/var/log/central-bank/`), làm bằng chứng gốc. Wazuh agent trên từng máy gửi sự kiện về Wazuh manager trên vps4 để phân tích bằng decoder, rule, tương quan và FIM. Hai luồng độc lập: hỏng một luồng không làm mất luồng kia.

Bảng dưới so sánh theo cùng tiêu chí, trên cùng sự kiện, đo ngày 17/11/2026.

| Tiêu chí | rsyslog (luồng thô) | Wazuh | Nguồn số liệu |
| :--- | :--- | :--- | :--- |
| Độ trễ: từ lúc gửi đăng nhập sai đến lúc thấy trên vps4 | 0,30–0,32 giây (5 lần đo) | 1,90–2,76 giây đến khi có alert 100102 (5 lần đo) | `tai-lieu-ky-thuat/scripts/kiem-thu/do_tre_rsyslog_wazuh.sh`, ảnh `kiem-thu/bang-chung/SIEM/B5-do-tre-rsyslog-wazuh_2026-11-17T16-52-08.png` |
| Độ trễ FIM (thay đổi tệp web) | Không áp dụng: rsyslog không theo dõi tệp | Alert 554/550/553 đến trong dưới 1 giây sau thao tác (16:49:39 → 16:49:39.844) | W1, ảnh `kiem-thu/bang-chung/SIEM/W1-FIM-vps0_2026-11-17T16-49-38.png` và `W-alerts-vps4_2026-11-17T16-50-39.png` |
| Độ phủ: 8 lần đăng nhập sai liên tiếp (W3) | 4 dòng log thô cho 4 lần HTTP 401; 4 lần HTTP 429 bị WAF chặn nên không tới API, không có log | 4 alert: 3 × 100102 và 1 × 100104 (lần thứ 4 khớp rule tương quan) | W3, ảnh `kiem-thu/bang-chung/SIEM/W3-API-vps4_2026-11-17T16-50-17.png` và `W-alerts-vps4_2026-11-17T16-50-39.png` |
| Tài nguyên trên máy được giám sát (vps0) | rsyslogd 6,3 MB RAM | wazuh-agent 45,4 MB RAM (agentd, syscheckd, logcollector, modulesd, execd) | `ps -eo rss,comm`, ảnh `kiem-thu/bang-chung/SIEM/so-sanh-ram-vps0_2026-11-17T16-51-55.png` |
| Tài nguyên trên máy trung tâm (vps4, 3,8 GB RAM) | rsyslogd là dịch vụ có sẵn của Ubuntu, chỉ ghi tệp; không đo riêng | indexer 1,4 GB, manager 1,2 GB, dashboard 218,5 MB; còn 856 MB khả dụng, không có swap | Ảnh `kiem-thu/bang-chung/ha-tang/B2-ram-vps4_2026-11-17T16-42-56.png`, `B2-wazuh-services_2026-11-17T16-43-05.png` |
| Khả năng phát hiện | Không tự phát hiện, chỉ lưu; người phân tích phải tự đọc và đếm | Có decoder, rule, tương quan (100104: 4 lần sai trong 60 giây; 5712: dò mật khẩu SSH), FIM theo thời gian thực | Ảnh `kiem-thu/bang-chung/SIEM/B3-wazuh-logtest-login_2026-11-17T16-51-15.png`, `W-alerts-vps4_2026-11-17T16-50-39.png` |

## Nhận xét

- rsyslog nhanh hơn khoảng 1,6–2,4 giây và tốn ít RAM hơn khoảng 7 lần trên máy được giám sát, nhưng chỉ lưu. Không có ai đọc thì không phát hiện được gì.
- Wazuh chậm hơn vì phải giải mã, so khớp rule và ghi alert, nhưng tự đưa ra kết luận: 8 lần đăng nhập sai thành một alert mức 10 "possible brute-force attack" thay vì 4 dòng log rời rạc.
- Wazuh không thay thế log thô: kẻ có quyền root trên một máy có thể dừng agent trên máy đó. Khi đó log thô đã chuyển về vps4 vẫn còn, và manager báo agent mất kết nối.
- Chi phí lớn nhất của Wazuh nằm ở vps4: ba thành phần dùng khoảng 2,8 GB trên 3,8 GB, thấp hơn mức 8 GB Wazuh khuyến nghị. Đây là giới hạn của bài và là lý do đề xuất tách indexer sang máy riêng khi mở rộng.
