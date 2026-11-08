# SPDX-License-Identifier: GPL-3.0-or-later
# API method adapted from phiTool, Copyright (C) 2026 Chnynnya.
# TapTap Phigros APK link resolver for Windows PowerShell 5.1+.
# Based on the TapTap API method documented by kckc7887/phiTool.
# Prints the link only. This script never downloads an APK.

$ErrorActionPreference = "Stop"

try {
    $uid = [guid]::NewGuid().ToString()
    $xua = "V=1&PN=TapTap&VN=2.40.1-rel.100000&VN_CODE=240011000&LOC=CN&LANG=zh_CN&CH=default&UID=$uid&NT=1&SR=1080x2030&DEB=Xiaomi&DEM=Redmi+Note+5&OSV=9"
    $encoded = [uri]::EscapeDataString($xua)

    $info = Invoke-RestMethod -Uri "https://api.taptapdada.com/app/v2/detail-by-id/165287?X-UA=$encoded" -UserAgent "okhttp/3.12.1" -TimeoutSec 30
    $apkId = $info.data.download.apk_id
    $version = $info.data.download.apk.version_name
    if ($null -eq $apkId -or [string]::IsNullOrWhiteSpace($version)) {
        throw "TapTap did not return APK metadata. The API may have changed."
    }

    $nonce = -join ('abcdefghijklmnopqrstuvwxyz0123456789'.ToCharArray() | Get-Random -Count 5)
    $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $param = "abi=arm64-v8a,armeabi-v7a,armeabi&id=$apkId&node=$uid&nonce=$nonce&sandbox=1&screen_densities=xhdpi&time=$timestamp"
    $source = "X-UA=$xua&${param}PeCkE6Fu0B10Vm9BKfPfANwCUAn5POcs"
    $md5 = [Security.Cryptography.MD5]::Create()
    try {
        $sign = [BitConverter]::ToString($md5.ComputeHash([Text.Encoding]::UTF8.GetBytes($source))).Replace("-", "").ToLowerInvariant()
    } finally {
        $md5.Dispose()
    }

    $result = Invoke-RestMethod -Uri "https://api.taptapdada.com/apk/v1/detail?X-UA=$encoded" -Method Post -UserAgent "okhttp/3.12.1" -ContentType "application/x-www-form-urlencoded" -Body "$param&sign=$sign" -TimeoutSec 30
    $url = [string]$result.data.apk.download
    if (-not $url.StartsWith("https://", [StringComparison]::OrdinalIgnoreCase)) {
        throw "TapTap did not return an HTTPS download URL."
    }

    Write-Output "Version: $version"
    Write-Output "APK URL: $url"
} catch {
    Write-Error "Failed: $($_.Exception.Message)"
    exit 1
}
