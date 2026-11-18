#!/bin/bash

LOG="/var/log/central-bank/vps2-app-api/bank-app.log"

echo "=================================================="
echo "SV4 - KIEM TRA BANG CHUNG KT1 VA KT3.1"
echo "Thoi gian: $(date -Is)"
echo "May chu: $(hostname)"
echo "=================================================="

if [ ! -r "$LOG" ]; then
    echo "[FAIL] Khong doc duoc file log: $LOG"
    exit 1
fi

check() {
    LABEL="$1"
    PATTERN="$2"
    MIN="$3"

    COUNT=$(grep -c "$PATTERN" "$LOG" || true)

    if [ "$COUNT" -ge "$MIN" ]; then
        echo "[$(date -Is)] [PASS] $LABEL | So dong: $COUNT"
    else
        echo "[$(date -Is)] [FAIL] $LABEL | So dong: $COUNT | Can: $MIN"
    fi
}

check "KT1.1 LOGIN SUCCESS" \
    'USER=user1 | ACTION=LOGIN | STATUS=SUCCESS' 1

check "KT1.1 VIEW_ACCOUNT SUCCESS" \
    'USER=user1 | ACTION=VIEW_ACCOUNT | STATUS=SUCCESS' 1

check "KT1.2 RBAC DENIED" \
    'USER=user1 | ACTION=RBAC | STATUS=DENIED' 1

check "KT3.1 LOGIN FAILED" \
    'USER=user1 | ACTION=LOGIN | STATUS=FAILED' 3

echo "=================================================="
echo "KET THUC KIEM TRA: $(date -Is)"
echo "=================================================="
