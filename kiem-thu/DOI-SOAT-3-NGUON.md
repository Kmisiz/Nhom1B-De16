# ĐỐI SOÁT 3 NGUỒN LOG

## Demo 5.1 – 3 lần đăng nhập sai

| Nguồn | Trước | Sau | Chênh lệch |
|---|---:|---:|---:|
| VPS4 central log | 12 | 15 | +3 |
| VPS3 audit_logs | 165 | 168 | +3 |
| Wazuh rule 100102 | 12 | 15 | +3 |
| Wazuh rule 100104 | 0 | 0 | 0 |
| **Tổng Wazuh** | **12** | **15** | **+3** |

**Kết quả:** Cả ba nguồn đều ghi nhận tăng 3 sự kiện đăng nhập thất bại. Wazuh ghi nhận các sự kiện trong rule 100102.

### Minh chứng Demo 5.1

- `kiem-thu\bang-chung\KT3\5.1\DS-5-1-truoc-vps3.jpg`
- `kiem-thu\bang-chung\KT3\5.1\DS-5-1-truoc-vps4.jpg`
- `kiem-thu\bang-chung\KT3\5.1\DS-5-1-truoc-wazuh_1149.jpg`
- `kiem-thu\bang-chung\KT3\5.1\DS-5-1-login-vps2.jpg`
- `kiem-thu\bang-chung\KT3\5.1\DS-5-1-sau-vps3.jpg`
- `kiem-thu\bang-chung\KT3\5.1\DS-5-1-sau-vps4.jpg`
- `kiem-thu\bang-chung\KT3\5.1\DS-5-1-sau-wazuh.jpg"`

## Demo 5.3 – Kiểm tra khi rsyslog gián đoạn

| Nguồn | Trước | Sau | Chênh lệch |
|---|---:|---:|---:|
| VPS4 central log | 15 | 19 | +4 |
| VPS3 audit_logs | 168 | 173 | +5 |
| Wazuh rule 100102 | 15 | 19 | +4 |
| Wazuh rule 100104 | 0 | 1 | +1 |
| **Tổng Wazuh** | **15** | **20** | **+5** |

### Diễn biến rsyslog

- 12:07:41 UTC: yêu cầu dừng `rsyslog`; dịch vụ chưa dừng hẳn do `syslog.socket` có thể kích hoạt lại.
- 12:08:14 UTC: dừng `syslog.socket` và `rsyslog`; trạng thái xác nhận `inactive`.
- 12:08:38 UTC: khởi động lại `syslog.socket` và `rsyslog`; trạng thái xác nhận `active`.
- Sau kiểm thử, central log tăng 4 dòng, audit database tăng 5 bản ghi và tổng cảnh báo Wazuh tăng 5.

**Nhận xét:** Số liệu VPS3 và tổng Wazuh cùng tăng 5, trong khi central log tăng 4. Wazuh có thêm 1 cảnh báo thuộc rule 100104. Ghi nhận chênh lệch theo kết quả đo thực tế; không tự điều chỉnh số liệu hoặc kết luận mất log chỉ từ chênh lệch này.

### Minh chứng Demo 5.3

Lưu các ảnh đã chụp trong `kiem-thu/bang-chung/KT3/`. Đổi phần `<gio>` thành giờ thực tế trên ảnh:

- `kiem-thu\bang-chung\KT3\5.3\DS-5-3-truoc-vps4.jpg`
- `kiem-thu\bang-chung\KT3\5.3\DS-5-3-truoc-vps3.jpg`
- `kiem-thu\bang-chung\KT3\5.3\DS-5-3-truoc-wazuh.jpg`
- `kiem-thu\bang-chung\KT3\5.3\DS-5-3-stop-vps4.jpg`
- `kiem-thu\bang-chung\KT3\5.3\DS-5-3-login-vps2,jpg.jpg`
- `kiem-thu\bang-chung\KT3\5.3\DS-5-3-start-vps4.jpg`
- `kiem-thu\bang-chung\KT3\5.3\DS-5-3-sau-vps4.jpg`
- `kiem-thu\bang-chung\KT3\5.3\DS-5-3-sau-wazuh.jpg`
- `kiem-thu\bang-chung\KT3\5.3\DS-5-3-sau-vps3.jpg`


