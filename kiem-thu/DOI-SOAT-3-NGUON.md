# Đối soát sự kiện đăng nhập sai giữa ba nguồn (SV4 - Đề 16, Nhóm 1B)

Bảng này kiểm tra một lần đăng nhập sai trên vps2 có được ghi đủ ở cả ba nơi hay không: kho log tập trung trên vps4 (rsyslog), bảng `audit_logs` trên vps3 (PostgreSQL) và cảnh báo Wazuh trên vps4. Hai demo chạy ngày 23/11/2026 với tài khoản `user1` và mật khẩu sai, gọi thẳng `http://10.10.10.20:8080/api/login` từ vps2.

Cách đếm ở từng nguồn:

| Nguồn | Lệnh đếm | Chạy trên |
| :--- | :--- | :--- |
| Kho log tập trung | `sudo grep "ACTION=LOGIN" /var/log/central-bank/vps2-app-api/bank-app.log \| grep -c "STATUS=FAILED"` | vps4 |
| `audit_logs` | `SELECT count(*) FROM audit_logs WHERE action='LOGIN' AND status='FAILED';` | vps3 |
| Wazuh | Đếm rule `100102` (mỗi lần đăng nhập sai) và `100104` (lần sai thứ 4 trong 60 giây) của `user1` trong `/var/ossec/logs/alerts/alerts.json` bằng `jq` | vps4 |

Giờ ở dòng nhắc lệnh trong ảnh là lúc dòng nhắc hiện ra, trước khi gõ lệnh, nên có thể sớm hơn lúc lệnh chạy. Giờ thực của từng sự kiện dưới đây lấy từ dấu thời gian trong kho log, bảng `audit_logs` và `journalctl -u rsyslog` trên vps4.

## 1. Demo 5.1: ba lần đăng nhập sai khi hệ thống bình thường

Ba lần đăng nhập sai diễn ra từ 11:50:10 đến 11:50:11 UTC, cả ba trả HTTP 401.

| Nguồn | Trước | Sau | Tăng |
| :--- | ---: | ---: | ---: |
| Kho log vps4 | 12 | 15 | +3 |
| `audit_logs` vps3 | 165 | 168 | +3 |
| Wazuh (`100102` + `100104`) | 12 + 0 = 12 | 15 + 0 = 15 | +3 |

Ba nguồn cùng tăng 3 sự kiện. Không có cảnh báo `100104` vì chỉ có 3 lần sai trong 60 giây.

Ảnh minh chứng (thư mục `kiem-thu/bang-chung/KT3/5.1/`):

- `DS-5-1-truoc-vps4.jpg`: kho log trước khi thử, 12 dòng.
- `DS-5-1-truoc-vps3.jpg`: `audit_logs` trước khi thử, 165 bản ghi.
- `DS-5-1-truoc-wazuh.jpg`: Wazuh trước khi thử, 12 cảnh báo `100102`.
- `DS-5-1-login-vps2.jpg`: ba lần đăng nhập sai, mỗi lần HTTP 401.
- `DS-5-1-sau-vps4.jpg`: kho log sau khi thử, 15 dòng.
- `DS-5-1-sau-vps3.jpg`: `audit_logs` sau khi thử, 168 bản ghi.
- `DS-5-1-sau-wazuh.jpg`: Wazuh sau khi thử, 15 cảnh báo `100102`.

## 2. Demo 5.3: năm lần đăng nhập sai khi rsyslog trên vps4 dừng

Diễn biến theo giờ UTC:

- 12:08:14: lệnh `systemctl stop rsyslog` đầu tiên không giữ được trạng thái dừng, vì `syslog.socket` khởi động lại rsyslog ngay trong cùng giây.
- 12:08:38: dừng cả `syslog.socket` và `rsyslog`; `systemctl is-active rsyslog` trả `inactive`.
- 12:09:08 đến 12:09:09: năm lần đăng nhập sai trên vps2, cả năm trả HTTP 401.
- 12:09:24: chạy lại `syslog.socket` và `rsyslog`; trạng thái `active`. Rsyslog trên vps4 dừng tổng cộng 46 giây.

| Nguồn | Trước | Sau | Tăng |
| :--- | ---: | ---: | ---: |
| Kho log vps4 | 15 | 19 | +4 |
| `audit_logs` vps3 | 168 | 173 | +5 |
| Wazuh (`100102` + `100104`) | 15 + 0 = 15 | 19 + 1 = 20 | +5 |

`audit_logs` đủ 5 bản ghi vì ứng dụng ghi thẳng vào PostgreSQL, không đi qua rsyslog. Wazuh cũng đủ 5 sự kiện vì agent trên vps2 đọc trực tiếp tệp `/var/log/bank-app.log` của vps2 (nhóm `app` trong `tai-lieu-ky-thuat/cau-hinh/vps4-mgmt-log/wazuh/groups/app/agent.conf`), cũng không phụ thuộc rsyslog trên vps4. Lần sai thứ 4 trong 60 giây sinh cảnh báo `100104`, nên Wazuh có 4 cảnh báo `100102` và 1 cảnh báo `100104`.

Kho log vps4 thiếu đúng một sự kiện: lần đăng nhập đầu tiên lúc 12:09:08.7 có trong `audit_logs` và Wazuh nhưng không có trong kho log. Bốn sự kiện còn lại được rsyslog trên vps2 giữ trong hàng đợi (`queue.type="LinkedList"`, `action.resumeRetryCount="-1"` trong `tai-lieu-ky-thuat/cau-hinh/vps2-app-api/60-forward-bank-app.conf`) và gửi lại sau khi vps4 nhận lại kết nối. Bản ghi bị mất là bản ghi gửi đầu tiên sau khi vps4 ngừng nhận, phù hợp với giới hạn của chuyển tiếp syslog qua TCP thường: lệnh gửi đầu tiên vẫn báo thành công ở vps2 trước khi vps2 phát hiện kết nối đã đóng, nên bản ghi đó không được đưa lại vào hàng đợi.

Kết quả: khi kho log tập trung gián đoạn 46 giây, hai nguồn còn lại vẫn đủ sự kiện và đủ để người trực phát hiện 5 lần đăng nhập sai, nhưng kho log mất 1 trên 5 sự kiện. Muốn kho log không mất bản ghi trong tình huống này, có thể chuyển vps2 sang gửi bằng RELP (`omrelp`, có xác nhận từng bản ghi) thay cho TCP thường.

Ảnh minh chứng (thư mục `kiem-thu/bang-chung/KT3/5.3/`):

- `DS-5-3-truoc-vps4.jpg`: kho log trước khi thử, 15 dòng.
- `DS-5-3-truoc-vps3.jpg`: `audit_logs` trước khi thử, 168 bản ghi.
- `DS-5-3-truoc-wazuh.jpg`: Wazuh trước khi thử, 15 cảnh báo `100102`.
- `DS-5-3-stop-vps4.jpg`: dừng `syslog.socket` và `rsyslog`, trạng thái `inactive`.
- `DS-5-3-login-vps2.jpg`: năm lần đăng nhập sai, mỗi lần HTTP 401.
- `DS-5-3-start-vps4.jpg`: chạy lại `syslog.socket` và `rsyslog`, trạng thái `active`.
- `DS-5-3-sau-vps4.jpg`: kho log sau khi thử, 19 dòng.
- `DS-5-3-sau-vps3.jpg`: `audit_logs` sau khi thử, 173 bản ghi.
- `DS-5-3-sau-wazuh.jpg`: Wazuh sau khi thử, 19 cảnh báo `100102` và 1 cảnh báo `100104`.
