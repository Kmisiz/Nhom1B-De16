import json
import getpass
import urllib.request
import urllib.error
from http.cookies import SimpleCookie

BASE = "http://10.10.10.20:8080"

username = input("Customer username: ").strip()
password = getpass.getpass("Password before @: ") + chr(64) + getpass.getpass("Password after @: ")

def call_api(path, data=None, token=None):
    headers = {}
    if data is not None:
        headers["Content-Type"] = "application/json"
    if token:
        headers["Authorization"] = "Bearer " + token

    body = json.dumps(data).encode() if data is not None else None
    req = urllib.request.Request(BASE + path, data=body, headers=headers)

    try:
        with urllib.request.urlopen(req, timeout=10) as res:
            return res.status, res.read().decode(), res.headers
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode(), e.headers

status, body, headers = call_api(
    "/api/login",
    {"username": username, "password": password}
)

print("\nLOGIN HTTP:", status)

if status != 200:
    print("Khong dang nhap duoc.")
    raise SystemExit(1)

cookie = SimpleCookie()
cookie.load(headers.get("Set-Cookie", ""))
token = cookie.get("kn_session")

if not token:
    print("Khong tim thay token.")
    raise SystemExit(1)

status, body, _ = call_api(
    "/api/admin/audit-logs",
    token=token.value
)

print("ADMIN AUDIT LOGS HTTP:", status)
print("Response:", body)

if status == 403:
    print("\nKT1.2 DAT - RBAC CHAN KHACH HANG.")
else:
    print("\nKT1.2 CHUA DAT.")
