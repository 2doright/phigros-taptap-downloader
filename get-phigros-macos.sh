#!/bin/sh
# SPDX-License-Identifier: GPL-3.0-or-later
# TapTap Phigros APK URL resolver (macOS). Query and print only.
# API method: https://github.com/kckc7887/phiTool
set -eu

if [ "$#" -ne 0 ]; then
    printf 'No command-line options are supported. This script only prints the APK URL.\n' >&2
    exit 2
fi

for tool in curl perl openssl uuidgen tr sed date; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'Missing required command: %s\n' "$tool" >&2
        exit 1
    fi
done

uid=$(uuidgen | tr '[:upper:]' '[:lower:]')
xua="V=1&PN=TapTap&VN=2.40.1-rel.100000&VN_CODE=240011000&LOC=CN&LANG=zh_CN&CH=default&UID=$uid&NT=1&SR=1080x2030&DEB=Xiaomi&DEM=Redmi+Note+5&OSV=9"
encoded=$(printf '%s' "$xua" | perl -pe 's/([^A-Za-z0-9_.~-])/sprintf("%%%02X", ord($1))/ge')

metadata=$(curl -fSs --max-time 30 -A 'okhttp/3.12.1' "https://api.taptapdada.com/app/v2/detail-by-id/165287?X-UA=$encoded")
apk_id=$(printf '%s' "$metadata" | perl -MJSON::PP -0777 -ne 'my $j=decode_json($_); print $j->{data}{download}{apk_id} // ""')
version=$(printf '%s' "$metadata" | perl -MJSON::PP -0777 -ne 'my $j=decode_json($_); print $j->{data}{download}{apk}{version_name} // ""')
if [ -z "$apk_id" ] || [ -z "$version" ]; then
    printf 'TapTap did not return APK metadata.\n' >&2
    exit 1
fi

nonce=$(openssl rand -hex 3)
nonce=${nonce%?}
timestamp=$(date +%s)
params="abi=arm64-v8a,armeabi-v7a,armeabi&id=$apk_id&node=$uid&nonce=$nonce&sandbox=1&screen_densities=xhdpi&time=$timestamp"
source="X-UA=$xua&${params}PeCkE6Fu0B10Vm9BKfPfANwCUAn5POcs"
sign=$(printf '%s' "$source" | openssl dgst -md5 | sed 's/^.*= //')

detail=$(curl -fSs --max-time 30 -A 'okhttp/3.12.1' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data-raw "$params&sign=$sign" \
    "https://api.taptapdada.com/apk/v1/detail?X-UA=$encoded")
url=$(printf '%s' "$detail" | perl -MJSON::PP -0777 -ne 'my $j=decode_json($_); print $j->{data}{apk}{download} // ""')
case "$url" in
    https://*) ;;
    *) printf 'TapTap did not return an HTTPS APK URL.\n' >&2; exit 1 ;;
esac

printf 'Version: %s\nAPK URL: %s\n' "$version" "$url"
