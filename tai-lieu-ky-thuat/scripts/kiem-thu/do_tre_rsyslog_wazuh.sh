#!/bin/bash
# SIEM B5 - Do do tre: rsyslog (log tho) va Wazuh (alert) cho cung mot su kien
# Chay tren: vps4-mgmt-log (10.10.10.40)
# Quyen    : sudo (doc /var/log/central-bank va /var/ossec/logs/alerts/alerts.json), can bc
# Cach chay: sudo bash do_tre_rsyslog_wazuh.sh
# Cach do  : moi lan gui 1 dang nhap sai voi ten user duy nhat qua WAF vps1:8080, roi cu
#            0,1 giay kiem tra ten do da xuat hien chua o:
#              - rsyslog: /var/log/central-bank/vps2-app-api/bank-app.log (log tho tu vps2)
#              - Wazuh  : /var/ossec/logs/alerts/alerts.json (alert 100102 cua agent app-server)
#            Do tre = thoi diem thay dong log/alert tru thoi diem gui request.
#            Moi lan dung mot X-Real-IP rieng (dai 203.0.113.0/24, RFC 5737) de khong bi
#            gioi han tan suat cua WAF va khong kich hoat rule 100104.
set -u
WAF=http://10.10.10.10:8080/api/login
RAW=/var/log/central-bank/vps2-app-api/bank-app.log
ALERTS=/var/ossec/logs/alerts/alerts.json
SO_LAN=5

echo "===== SIEM B5 - Do tre rsyslog va Wazuh tren $(hostname) ====="
echo "TIME: $(date -Is)"
echo

for i in $(seq 1 "$SO_LAN"); do
  ip="203.0.113.$((30 + i))"
  u="kt_tre_$(date +%s%N | cut -c1-13)"
  t0=$(date +%s.%N)
  code=$(curl -s -o /dev/null -w "%{http_code}" -m 5 -X POST "$WAF" \
    -H "Content-Type: application/json" -H "X-Real-IP: $ip" -H "X-Forwarded-For: $ip" \
    -d "{\"username\":\"$u\",\"password\":\"sai_mat_khau_kt\"}")
  tr=""; tw=""
  for _ in $(seq 1 150); do
    [ -z "$tr" ] && grep -qs "$u" "$RAW" && tr=$(date +%s.%N)
    [ -z "$tw" ] && tail -n 500 "$ALERTS" | grep -q "$u" && tw=$(date +%s.%N)
    [ -n "$tr" ] && [ -n "$tw" ] && break
    sleep 0.1
  done
  r=$( [ -n "$tr" ] && printf "%.2f s" "$(echo "$tr - $t0" | bc)" || echo "khong thay (>15 s)")
  w=$( [ -n "$tw" ] && printf "%.2f s" "$(echo "$tw - $t0" | bc)" || echo "khong thay (>15 s)")
  echo "[$(date -Is)] Lan $i: HTTP $code | rsyslog: $r | Wazuh: $w"
  sleep 2
done

echo
echo "END : $(date -Is)"
