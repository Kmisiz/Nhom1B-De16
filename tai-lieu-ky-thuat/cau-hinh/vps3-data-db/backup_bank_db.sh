#!/bin/bash
set -euo pipefail
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ENC_FILE="/var/backups/postgres/digital_bank_${TIMESTAMP}.sql.gz.enc"
sudo -u postgres pg_dump --clean --if-exists digital_bank | gzip | \
  openssl enc -aes-256-cbc -salt -pbkdf2 -pass file:/root/.backup_passphrase -out "${ENC_FILE}"
chmod 600 "${ENC_FILE}"
logger -t BANK_BACKUP "BACKUP_SUCCESS: Created encrypted backup ${ENC_FILE}"
echo "[OK] Da tao ban sao luu ma hoa: ${ENC_FILE}"
