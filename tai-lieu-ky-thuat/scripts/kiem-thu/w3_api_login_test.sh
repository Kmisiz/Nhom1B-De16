#!/bin/bash
# SIEM W3/W3b - Dang nhap API sai lien tiep qua WAF
# Chay tren: vps4-mgmt-log (10.10.10.40), dich la WAF vps1-dmz-fw (10.10.10.10:8080)
# Quyen    : user thuong
# Cach chay: bash scripts/w3_api_login_test.sh | tee W3-API-$(date -u +%Y%m%dT%H%M%SZ).log
# Ghi chu  : X-Real-IP co dinh 203.0.113.16 (dai IP tai lieu RFC 5737) de WAF va Wazuh
#            tinh theo mot nguon duy nhat, khong lo IP that cua may quan tri.
# Mong doi : 4 lan dau HTTP 401 (WAF cho qua: rate=5r/m, burst=3), tu lan 5 HTTP 429.
#            Wazuh (agent app-server) sinh 100102 cho moi lan 401 va 100104
#            (4 lan that bai trong 60 giay, level 10).
set -u
WAF=http://10.10.10.10:8080/api/login
IP_GIA=203.0.113.16

echo "===== SIEM W3/W3b - Dang nhap API sai tu $(hostname) ====="
echo "TIME: $(date -Is)"
echo "DICH: $WAF   X-Real-IP: $IP_GIA   user: admin, mat khau sai"
echo

for i in $(seq 1 8); do
  code=$(curl -s -o /dev/null -w "%{http_code}" -m 5 -X POST "$WAF" \
    -H "Content-Type: application/json" \
    -H "X-Real-IP: $IP_GIA" -H "X-Forwarded-For: $IP_GIA" \
    -d '{"username":"admin","password":"sai_mat_khau_kt"}')
  echo "[$(date -Is)] Lan $i: HTTP $code"
done

echo
echo "END : $(date -Is)"
