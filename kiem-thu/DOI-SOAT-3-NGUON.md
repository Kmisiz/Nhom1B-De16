# ĐỐI SOÁT SỰ KIỆN ĐĂNG NHẬP SAI TỪ 3 NGUỒN

| Thời điểm đếm | Log thô VPS4 (grep -c) | Bảng audit_logs VPS3 (psql count) | Cảnh báo Wazuh (Từ SV1) | Độ lệch | Lý do lệch (nếu có) |
|---|---|---|---|---|---|
| **Trước khi thử**  | 0 | 105 | số wawuz từ sv1 | 0 | Không có |
| **Sau khi thử 3 lần** | 3 | 108 | [Số cũ + 3 từ SV1] | 0 | 3 nguồn đồng bộ, ghi nhận đủ 3 sự kiện |

**Kết luận:**
Số lượng sự kiện `ACTION=LOGIN` và `STATUS=FAILED` tăng đồng đều thêm 3 sự kiện ở cả 3 luồng (Log cục bộ -> vps4, Log Database -> vps3, và Wazuh Agent -> vps4 Wazuh Server), chứng tỏ luồng nhật ký hoạt động ổn định và chính xác.


