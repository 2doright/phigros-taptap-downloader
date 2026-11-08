# Phigros TapTap APK URL Resolver

在电脑上获取 **Phigros TapTap 中国版（App ID `165287`）** 的最新 APK 直链。

**仅查询并打印版本号和 APK 直链。没有下载功能、文件保存功能或命令行选项。**

## 使用方法

### Windows

在脚本所在目录打开 PowerShell：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\get-phigros-windows.ps1
```

系统要求：Windows PowerShell 5.1 或更新版本，无需其他软件。

### Linux

```sh
sh get-phigros-linux.sh
```

依赖：`curl`、`openssl`、`perl`（包含 `JSON::PP`）。无 Python 依赖。

### macOS

```sh
sh get-phigros-macos.sh
```

依赖：`curl`、`openssl`、`perl`、`uuidgen`。无 Python 依赖。

## 输出示例

```text
Version: 4.0.1.2
APK URL: https://example.com/example.apk
```

## 说明

- 脚本使用社区研究的 TapTap **非官方接口**。接口变更后可能失效。
- 仅查询链接，不发起 APK 文件请求，也不创建本地文件。
- TapTap 版与 Google Play 版签名不同，不能互相覆盖升级。
- 输出示例不代表当前版本，请以实际查询结果为准。

## 来源与许可

接口调用方法参考：

- [kckc7887/phiTool](https://github.com/kckc7887/phiTool)（GPL-3.0）
- [7aGiven/Phigros_Resource](https://github.com/7aGiven/Phigros_Resource)

本项目采用 GPL-3.0-or-later 许可证。Phigros 游戏版权归 Pigeon Games 所有；本仓库不提供 APK 文件。
