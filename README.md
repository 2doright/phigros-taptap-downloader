# Phigros TapTap APK downloader

直接从 TapTap 的接口获取 **Phigros 中国版（App ID `165287`）** 的 APK 下载链接，无须安装 TapTap、登录账号或连接手机。

## 用法

| 系统 | 获取直链 | 直接下载 APK |
| --- | --- | --- |
| Windows (PowerShell 5.1+) | `./get-phigros-windows.ps1` | `./get-phigros-windows.ps1 -Download` |
| Linux (Python 3.10+) | `sh get-phigros-linux.sh` | `sh get-phigros-linux.sh --download` |
| macOS (Python 3.10+) | `sh get-phigros-macos.sh` | `sh get-phigros-macos.sh --download` |

运行后会打印最新版本号及 APK 的 HTTPS 下载地址。使用下载参数时，文件将保存到**当前目录**，文件名为 `Phigros-TapTap-版本号.apk`。

指定已有的下载目录：

- Windows: `./get-phigros-windows.ps1 -Download -OutputDirectory "C:\Downloads"`
- Linux/macOS: `sh get-phigros-linux.sh --download --output-dir "$HOME/Downloads"`

Windows 如果阻止脚本执行，可以在 PowerShell 中运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\get-phigros-windows.ps1
```

## 说明

- 默认只获取链接，添加 `-Download` 或 `--download` 才开始下载约 2 GB 的游戏包。
- 脚本不会覆盖已有的同名文件。若下载中断，可能留下未完成的文件；请检查文件大小。
- 使用的是社区研究的 **非官方接口**。TapTap 修改接口后，脚本可能失效。
- TapTap 版与 Google Play 版的签名不同，不能直接互相覆盖升级。
- 请以 TapTap 游戏页显示的版本号为准，勿把过时仓库中的示例版本当作当前版本。

## 来源与许可

下载接口的实现参考了以下开源项目：

- [kckc7887/phiTool](https://github.com/kckc7887/phiTool)（GPL-3.0）
- [7aGiven/Phigros_Resource](https://github.com/7aGiven/Phigros_Resource)

此项目以 GPL-3.0-or-later 许可发布。游戏及资源版权归 Pigeon Games 所有；本仓库不托管任何游戏安装包。
