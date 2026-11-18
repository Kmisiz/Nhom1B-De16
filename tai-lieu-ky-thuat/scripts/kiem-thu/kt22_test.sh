#!/bin/bash
echo "===== KT2.2 - KIEM TRA KET NOI POSTGRESQL ====="
echo "TIME: $(date -Is)"
echo "HOST: $(hostname)"
if nc -zv -w 3 10.10.10.30 5432; then
    echo "KT2.2 PASS - VPS2 DUOC PHEP KET NOI VPS3:5432"
    exit 0
else
    echo "KT2.2 FAIL - KHONG KET NOI DUOC VPS3:5432"
    exit 1
fi
