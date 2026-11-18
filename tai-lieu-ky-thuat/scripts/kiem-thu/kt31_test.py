import json
import urllib.request
import urllib.error
from datetime import datetime, timezone

URL = "http://10.10.10.20:8080/api/login"
USERNAME = "user1"
WRONG_PASSWORD = "SV4_WRONG_PASSWORD_TEST"

print("===== KT3.1 - THREE FAILED LOGINS =====")
print("TIME:", datetime.now(timezone.utc).isoformat())
print("HOST: vps2-app-api")

passed = 0

for i in range(1, 4):
    data = json.dumps({
        "username": USERNAME,
        "password": WRONG_PASSWORD
    }).encode()

    req = urllib.request.Request(
        URL,
        data=data,
        headers={"Content-Type": "application/json"}
    )

    try:
        with urllib.request.urlopen(req, timeout=10) as res:
            status = res.status
    except urllib.error.HTTPError as e:
        status = e.code

    print(f"Attempt {i}: HTTP {status}")

    if status == 401:
        passed += 1

print(f"RESULT: {passed}/3 failed-login responses returned HTTP 401")
print("KT3.1 PASS" if passed == 3 else "KT3.1 FAIL")
raise SystemExit(0 if passed == 3 else 1)
