@echo off

SET FILE_URL=https://github.com/wsldl-pg/CentWSL/releases/download/7.0.1907.3/CentOS7.zip
SET FILE_NAME=baota.zip
SET CENTOS_EXE=CentOS7.exe
SET WSL_FILE=baota
SET DOCKERBOTA=https://github.com/dooioomoo/docker-bota.git


echo 现在开始准备安装系统环境
echo .
echo 主要用于基于Centos和docker的前端开发和后台开发环境
echo .
echo 其中包括WSL2\DOCKER\VSCODE\GIT\COMPOSER\BOTA...等
echo .
echo 它需要使用到管理员权限以安装来自微软的官方补丁
echo 及下载必要的系统组件，请使用或同意脚本的管理身份请求！

if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%~dp0
bcdedit >nul
if '%errorlevel%' NEQ '0' (goto UACPrompt) else (goto UACAdmin)
:UACPrompt
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
exit /B
:UACAdmin
cd /d "%~dp0"
echo 当前运行路径是：%CD%
echo 已获取管理员权限
echo .
echo .
echo .
call :Resume
goto %current%
goto :eof

setlocal
:one


SET /P AREYOUSURE=是否开始安装 (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END
echo.
echo.
echo.
echo.
echo 正在安装 choco ...
powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
choco feature enable -n=allowGlobalConfirmation
echo.
echo.
echo.
echo.
echo 正在安装 PHP 7.4 ...

powershell choco install --yes php --version=7.4.14
echo.
echo.
echo.
echo.
echo 正在安装 git ...

powershell choco install --yes git
echo.
echo.
echo.
echo.
echo 正在安装 wget ...

powershell choco install --yes wget
echo.
echo.
echo.
echo.
echo 正在安装 composer ...

powershell choco install --yes composer
echo.
echo.
echo.
echo.
echo 正在安装 Nodejs ...

powershell choco install --yes nodejs --version=14.15.4
echo.
echo.
echo.
echo.
echo 正在安装 VSCODE ...

powershell choco install --yes vscode
echo.
echo.
echo.
echo 开始启用WINDOWS功能组件
echo ===============================
echo.
echo 开启虚拟机功能 ...
powershell dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
echo.
echo 开启Hyper-V ...
powershell dism.exe /online /enable-feature /featurename:HypervisorPlatform /all /norestart
echo.
echo 开启WSL ...
powershell dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
echo.
echo.
echo 开始启用WINDOWS功能组件
echo ===============================
echo.
echo 开始启用虚拟平台 ...
powershell Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
echo.
echo.
echo 开始启用WSL ...
powershell Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

::Add script to Run key
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v %~n0 /d %~dpnx0 /f
echo two >%~dp0current.txt
echo -- Section one --

shutdown -r -t 0

goto :eof


:two
echo.
echo.
if not exist wsl_update_x64.msi (
echo 升级WSL2 ...
wget  --no-check-certificate https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -O wsl_update_x64.msi
powershell msiexec /i wsl_update_x64.msi /qn
echo.
echo.
)
echo 设置wsl默认版本为2
powershell wsl --set-default-version 2
echo.
if not exist %FILE_NAME% (
echo 下载 CENTOS FOR WSL 7.0 ...
echo.
wget --no-check-certificate "%FILE_URL%" -O "%FILE_NAME%"
echo.
)
if not exist %WSL_FILE%.exe (
echo 解压缩 ...
echo.
powershell Expand-Archive -Force %FILE_NAME% "./" && powershell Rename-Item %CENTOS_EXE% %WSL_FILE%.exe
)

If not exist DockerDesktopInstaller.exe (
echo 下载 DOCKER DESKTOP ...
echo.
wget  --no-check-certificate "https://desktop.docker.com/win/stable/Docker Desktop Installer.exe" -O "DockerDesktopInstaller.exe"
echo.
echo.
echo.
)

If exist DockerDesktopInstaller.exe (
echo 开始安装docker桌面运行程序 ...
start /wait DockerDesktopInstaller.exe
)

echo.
echo 开始安装centos到WSL中 ...
echo.
powershell .\%WSL_FILE%.exe < nul
powershell wsl -s %WSL_FILE%
echo.
echo.
echo 开始创建docker基础文件环境 ...[%WSL_FILE%.exe]
echo.
powershell .\%WSL_FILE%.exe run \"[ -d /%WSL_FILE% ] || mkdir /%WSL_FILE% && cd /%WSL_FILE% && yum install git -y && git clone %DOCKERBOTA%  ./ && cp .env-example .env && mv build.bat build.sh && source instsys.sh \"
echo.
echo.
echo.

::Add script to Run key
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v %~n0 /d %~dpnx0 /f
echo finish >%~dp0current.txt
echo -- Section two --
goto :finish
goto :eof

:finish
powershell wsl -l -v
echo.
echo 请务必等待docker服务运行后再继续!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo.
echo 请在docker中将Settings\Resources\WSL INTEGRATION\%WSL_FILE%镜像设定为打开状态并应用修改后继续 ...
echo.
echo.
pause
echo.
echo 运行 wsl -d %WSL_FILE%,并进入/%WSL_FILE%目录中运行 sh build.sh
echo.
echo.
echo 进入baota CENTOS环境 ...
powershell .\%WSL_FILE%.exe run \"cd /baota && sh build.sh\"
echo.
echo.
echo 完成宝塔的安装!
pause
::Remove script from Run key
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v %~n0 /f
del %~dp0current.txt
goto :eof

:resume
if exist %~dp0current.txt (
    set /p current=<%~dp0current.txt
) else (
    set current=one
)
:END
endlocal
