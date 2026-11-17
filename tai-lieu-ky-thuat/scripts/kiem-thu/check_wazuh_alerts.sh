#!/bin/bash
# SIEM - Doc alert Wazuh cua cac bai W1, W2, W3/W3b
# Chay tren: vps4-mgmt-log (Wazuh manager)
# Quyen    : sudo (doc /var/ossec/logs/alerts/alerts.json), can jq
# Cach chay: sudo bash scripts/check_wazuh_alerts.sh 2026-11-15T13:40:00 | tee W-alerts-$(date -u +%Y%m%dT%H%M%SZ).log
#            Tham so la moc thoi gian UTC bat dau tim (mac dinh: 15 phut truoc).
# Chi lay alert cua dung kich ban de khong lan su kien khac:
#   W1 : rule 554/550/553, tep /var/www/muoisau/kt-fim-test.html
#   W2 : rule 5710/5712, user kt_attacker
#   W3 : rule 100102/100104, IP 203.0.113.16
set -euo pipefail
SINCE="${1:-$(date -u -d '15 min ago' +%Y-%m-%dT%H:%M:%S)}"
ALERTS=/var/ossec/logs/alerts/alerts.json

echo "===== KIEM TRA ALERT WAZUH W1-W3b tren $(hostname) ====="
echo "TIME: $(date -Is)"
echo "TU  : $SINCE (UTC)"
echo
echo "--- Trang thai agent (agent_control -l) ---"
/var/ossec/bin/agent_control -l | grep "ID:"

show() {
  local ten="$1" loc="$2"
  echo
  echo "--- $ten ---"
  printf '%-24s  %-11s  %-6s  %-3s  %s\n' "THOI GIAN (UTC)" "AGENT" "RULE" "LV" "MO TA"
  jq -r --arg s "$SINCE" "select(.timestamp >= \$s) | select($loc)
        | [.timestamp[0:23], .agent.name, .rule.id, (.rule.level|tostring), .rule.description] | @tsv" "$ALERTS" \
    | awk -F'\t' '{printf "%-24s  %-11s  %-6s  %-3s  %s\n", $1, $2, $3, $4, $5}'
}

dem() { jq -r --arg s "$SINCE" "select(.timestamp >= \$s) | select($1) | .rule.id" "$ALERTS" | grep -cx "$2" || true; }

W1='(.rule.id|IN("554","550","553")) and ((.syscheck.path // "")|test("kt-fim-test"))'
W2='(.rule.id|IN("5710","5712")) and (.data.srcuser // "") == "kt_attacker"'
W3='(.rule.id|IN("100102","100104")) and (.data.srcip // "") == "203.0.113.16"'

show "W1 FIM (vps0 /var/www/muoisau)" "$W1"
show "W2 SSH brute force (vps0, user kt_attacker)" "$W2"
show "W3/W3b Dang nhap API sai (IP 203.0.113.16)" "$W3"

ket() { if [ "$2" -gt 0 ]; then echo "[PASS] $1 (so alert: $2)"; else echo "[FAIL] $1 (khong co alert)"; fi; }
echo
echo "--- Ket luan ---"
ket "W1 them tep, rule 554"            "$(dem "$W1" 554)"
ket "W1 sua tep, rule 550"             "$(dem "$W1" 550)"
ket "W1 xoa tep, rule 553"             "$(dem "$W1" 553)"
ket "W2 brute force SSH, rule 5712"    "$(dem "$W2" 5712)"
ket "W3 dang nhap sai, rule 100102"    "$(dem "$W3" 100102)"
ket "W3b tuong quan brute force, 100104" "$(dem "$W3" 100104)"
echo
echo "END : $(date -Is)"
