## 2021年1月18日

加入了powershell自动执行代码

首先用管理员权限打开powershell

```powershell
Set-ExecutionPolicy Unrestricted
```

选择A

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('http://generator.a.navi.bz/inst-wsl-bota.ps1'))
```

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('http://generator.a.navi.bz/inst-wsl-docker-bota.ps1'))
```

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/dooioomoo/aiws/main/inst-wsl-docker-bota.ps1'))
```

## 2021年1月15日

1.在需要安装docker boa的操作系统中，找到想要安装的分区，新建一个目录，例如：docker
2.在新建的docker目录中，新建一个文本文件，并将aiwa的代码复制进去。
3.将这个文本文件，保存为 ANSI 模式，不然会乱码，然后修改后缀为.bat
4.双击运行bat文件，它会自动要求使用管理员模式，如果可以，请修改管理员权限请求提示。
5.计算机会重新启动两次，第二次启动时，需要等待docker的运行，请不要着急按空格继续!
