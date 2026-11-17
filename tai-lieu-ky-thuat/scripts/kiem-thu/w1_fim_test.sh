#!/bin/bash
# SIEM W1 - Giam sat toan ven tep (FIM) tren giao dien web
# Chay tren: vps0-web-public (10.10.10.5), agent Wazuh "web-server", nhom "web"
# Quyen    : sudo (ghi vao /var/www/muoisau)
# Cach chay: sudo bash scripts/w1_fim_test.sh | tee W1-FIM-$(date -u +%Y%m%dT%H%M%SZ).log
# Mong doi : Wazuh sinh alert 554 (them tep), 550 (doi checksum), 553 (xoa tep)
#            cho /var/www/muoisau/kt-fim-test.html, agent web-server.
#            Kiem tra bang scripts/check_wazuh_alerts.sh tren vps4.
set -euo pipefail
F=/var/www/muoisau/kt-fim-test.html

echo "===== SIEM W1 - FIM tren $(hostname) ====="
echo "TIME: $(date -Is)"
echo "TEP : $F"
echo

echo "[$(date -Is)] Buoc 1: tao tep moi"
echo "<p>KT FIM test</p>" > "$F"
sleep 5

echo "[$(date -Is)] Buoc 2: sua noi dung tep"
echo "<p>KT FIM test - da sua</p>" >> "$F"
sleep 5

echo "[$(date -Is)] Buoc 3: xoa tep"
rm -f "$F"

echo
echo "END : $(date -Is)"
