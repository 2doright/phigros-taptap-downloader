#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
# API method adapted from phiTool, Copyright (C) 2026 Chnynnya.
"""Get the latest Phigros TapTap APK URL, optionally download the APK.

Requires only Python 3's standard library. TapTap app/login is not required.
Based on the public API method used by kckc7887/phiTool.
"""

import argparse
import hashlib
import json
import re
import secrets
import sys
import time
import uuid
from pathlib import Path
from urllib.parse import quote
from urllib.request import Request, urlopen


API = "https://api.taptapdada.com"
APP_ID = 165287
USER_AGENT = "okhttp/3.12.1"
SIGNING_SUFFIX = "PeCkE6Fu0B10Vm9BKfPfANwCUAn5POcs"


def fetch_json(url: str, body: bytes | None = None) -> dict:
    headers = {"User-Agent": USER_AGENT}
    if body is not None:
        headers["Content-Type"] = "application/x-www-form-urlencoded"
    request = Request(url, data=body, headers=headers)
    with urlopen(request, timeout=30) as response:
        return json.load(response)


def get_apk_info() -> dict:
    uid = str(uuid.uuid4())
    xua = (
        "V=1&PN=TapTap&VN=2.40.1-rel.100000&VN_CODE=240011000&"
        f"LOC=CN&LANG=zh_CN&CH=default&UID={uid}&NT=1&"
        "SR=1080x2030&DEB=Xiaomi&DEM=Redmi+Note+5&OSV=9"
    )
    encoded_xua = quote(xua, safe="")
    metadata = fetch_json(f"{API}/app/v2/detail-by-id/{APP_ID}?X-UA={encoded_xua}")
    apk_id = metadata["data"]["download"]["apk_id"]
    version = metadata["data"]["download"]["apk"]["version_name"]

    alphabet = "abcdefghijklmnopqrstuvwxyz0123456789"
    nonce = "".join(secrets.choice(alphabet) for _ in range(5))
    timestamp = int(time.time())
    params = (
        f"abi=arm64-v8a,armeabi-v7a,armeabi&id={apk_id}&node={uid}&"
        f"nonce={nonce}&sandbox=1&screen_densities=xhdpi&time={timestamp}"
    )
    signature = hashlib.md5(
        f"X-UA={xua}&{params}{SIGNING_SUFFIX}".encode("utf-8")
    ).hexdigest()
    body = f"{params}&sign={signature}".encode("utf-8")
    detail = fetch_json(f"{API}/apk/v1/detail?X-UA={encoded_xua}", body=body)
    apk = detail["data"]["apk"]
    link = apk["download"]
    if not isinstance(link, str) or not link.startswith("https://"):
        raise ValueError("TapTap did not return an HTTPS download link")

    return {"version": version, "url": link, "size": apk.get("size")}


def download_apk(info: dict, output_directory: Path) -> Path:
    if not output_directory.is_dir():
        raise ValueError(f"Output directory does not exist: {output_directory}")
    safe_version = re.sub(r"[^0-9A-Za-z._-]", "_", str(info["version"]))
    destination = output_directory / f"Phigros-TapTap-{safe_version}.apk"
    # Exclusive creation: existing files are never overwritten.
    with urlopen(Request(info["url"], headers={"User-Agent": USER_AGENT}), timeout=60) as source:
        with destination.open("xb") as target:
            total = 0
            while chunk := source.read(1024 * 1024):
                target.write(chunk)
                total += len(chunk)
                if total % (64 * 1024 * 1024) < len(chunk):
                    print(f"Downloaded {total // (1024 * 1024)} MiB", flush=True)
    return destination


def main() -> int:
    parser = argparse.ArgumentParser(description="Get Phigros APK from TapTap without the TapTap client")
    parser.add_argument("--download", action="store_true", help="Download the APK instead of printing only its URL")
    parser.add_argument("--output-dir", type=Path, default=Path.cwd(), help="Existing download directory")
    args = parser.parse_args()
    try:
        info = get_apk_info()
        print(f"Version: {info['version']}")
        print(f"APK URL: {info['url']}")
        if args.download:
            destination = download_apk(info, args.output_dir)
            print(f"Saved: {destination}")
        return 0
    except Exception as exc:
        print(f"Failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
