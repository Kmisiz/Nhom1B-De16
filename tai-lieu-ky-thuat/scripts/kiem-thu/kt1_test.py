import json
import getpass
import urllib.request
import urllib.error
from http.cookies import SimpleCookie

BASE = "http://10.10.10.20:8080"

username = input("Username customer: ").strip()
password = getpass.getpass("Password truoc @: ") + chr(64) + getpass.getpass("Password sau @: ")

def call_api(url, data=None, token=None):
    headers = {}
    if data is not None:
        headers["Content-Type"] = "application/json"
    if token:
        headers["Authorization"] = "Bearer " + token

    body = json.dumps(data).encode() if data is not None else None
    req = urllib.request.Request(url, data=body, headers=headers)

    try:
        with urllib.request.urlopen(req, timeout=10) as res:
            return res.status, res.read().decode(), res.headers
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode(), e.headers

status, body, headers = call_api(
    BASE + "/api/login",
    {"username": username, "password": password}
)

print("\nLOGIN HTTP:", status)
print(body)

if status != 200:
    print("KT1.1 CHUA DAT")
    raise SystemExit

cookie = SimpleCookie()
cookie.load(headers.get("Set-Cookie", ""))
token = cookie.get("kn_session")

if not token:
    print("Khong tim thay JWT cookie.")
    raise SystemExit

status, body, _ = call_api(
    BASE + "/api/my-account",
    token=token.value
)

print("\nMY-ACCOUNT HTTP:", status)
print(body)

if status == 200:
    print("\nKT1.1 DAT")
else:
    print("\nKT1.1 CHUA DAT")
