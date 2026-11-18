#!/bin/bash

DB="digital_bank"

echo "===== KT3.2 - KIEM TRA BAO VE AUDIT_LOGS ====="
echo "TIME: $(date -Is)"
echo "HOST: $(hostname)"
echo "DATABASE: $DB"

DELETE_BLOCKED=$(sudo -u postgres psql -d "$DB" -Atc \
"SELECT NOT has_table_privilege('bank_app','public.audit_logs','DELETE');")

DROP_BLOCKED=$(sudo -u postgres psql -d "$DB" -Atc \
"SELECT NOT (
    c.relowner = r.oid
    OR pg_has_role('bank_app', c.relowner, 'MEMBER')
)
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
JOIN pg_roles r ON r.rolname = 'bank_app'
WHERE n.nspname = 'public' AND c.relname = 'audit_logs';")

echo "DELETE_BLOCKED: $DELETE_BLOCKED"
echo "DROP_BLOCKED: $DROP_BLOCKED"

if [ "$DELETE_BLOCKED" = "t" ] && [ "$DROP_BLOCKED" = "t" ]; then
    echo "KT3.2 PASS - bank_app KHONG CO QUYEN DELETE/DROP audit_logs"
    exit 0
else
    echo "KT3.2 FAIL - CAN KIEM TRA LAI QUYEN"
    exit 1
fi
