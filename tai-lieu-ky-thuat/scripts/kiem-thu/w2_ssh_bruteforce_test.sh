#!/bin/bash
# SIEM W2 - Do mat khau SSH bang user khong ton tai
# Chay tren: vps4-mgmt-log (10.10.10.40), dich la vps0-web-public (10.10.10.5)
# Quyen    : user thuong
# Cach chay: bash scripts/w2_ssh_bruteforce_test.sh | tee W2-SSH-$(date -u +%Y%m%dT%H%M%SZ).log
# Mong doi : agent web-server sinh 5710 cho tung lan (user kt_attacker khong ton tai),
#            sau 8 lan trong 120 giay sinh them 5712 (brute force, level 10).
set -u
TARGET=10.10.10.5
USER_GIA=kt_attacker
SO_LAN=10

echo "===== SIEM W2 - SSH brute force tu $(hostname) vao $TARGET ====="
echo "TIME: $(date -Is)"
echo "USER: $USER_GIA (khong ton tai tren $TARGET)"
echo

for i in $(seq 1 "$SO_LAN"); do
  ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      -o ConnectTimeout=5 -o PreferredAuthentications=password,keyboard-interactive \
      "$USER_GIA@$TARGET" true >/dev/null 2>&1
  rc=$?
  echo "[$(date -Is)] Lan $i: ssh $USER_GIA@$TARGET -> bi tu choi (exit $rc)"
done

echo
echo "END : $(date -Is)"
