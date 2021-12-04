$hello = "现在开始准备安装系统环境`nAIWS主要用于基于Centos和docker的前端开发和后台开发环境`n其中包括WSL2\DOCKER\VSCODE\GIT\COMPOSER\BOTA...等`n它需要使用到管理员权限以安装来自微软的官方补丁`n及下载必要的系统组件，请使用或同意脚本的管理身份请求!`n"
$centosFile = "https://github.com/wsldl-pg/CentWSL/releases/download/7.0.1907.3/CentOS7.zip"
$centosExe = "CentOS7.exe"
$installDev = "C"
$wsl = "baota"
$param = $args[0]
$regrun = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$restartkey = "RestartAndResume"
$runPath = ""
$runscript = $MyInvocation.MyCommand.Scriptblock -match '(http(.*)\.ps1)'
$runscript = $matches[1]
if ($matches.count -le 0) {
    exit;
}
# Write-Output $runscript
function Set-Key([string]$path, [string]$key, [string]$value) {
    Set-ItemProperty -Path $path -Name $key -Value $value
}
function Get-key([string]$path, [string]$key) {
    return (Get-ItemProperty $path).$key
}
function Test-key([string]$path, [string] $key) {
    return ((Test-Path $path) -and ((Get-Key $path $key) -ne $null))
}
function Remove-key([string] $path, [string] $key) {
    Remove-ItemProperty -Path $path -Name $key
}
function ClearAnyRestart([string]$key = $restartkey) {
    If (Test-key $regrun $key) {
        Remove-key $regrun $key
    }
}


#powershell "start-process PowerShell -verb runas -argument 'D:\bota\inst-wsl-bota.ps1 B'"
function RestartandRun([string]$run) {
    Set-Key $regrun $restartkey "powershell -ExecutionPolicy AllSigned start-process PowerShell -verb runas -argument '$run'"
    Restart-Computer
    exit

}

function downloadFile($url) {
    Start-Process wget -wait -NoNewWindow -PassThru -ArgumentList $url
}
function startInst() {
    Write-Output $hello
    # $confirmation = Read-Host "是否继续安装程序？[y(默认)/n]"
    # if ($confirmation -eq 'n') {
    #     Exit;
    # }
    $dvs = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty 'Name' | Select-String -Pattern '^[a-z]$'
    $driveLetter = Read-Host "输入要安装的盘符 ($dvs/quit(默认))"
    if ($driveLetter -eq '' -or $driveLetter -eq 'quit') {
        Exit;
    }
    if ((@($dvs) -like $driveLetter).Count -eq 0) {
        Write-Output "盘符不存在,将退出安装程序！"
        Exit;
    }
    else {
        $installDev = $driveLetter
    }

    $instFolder = Read-Host "输入安装目录名 (合法目录名/quit(默认))"
    if ($instFolder -eq '' -or $instFolder -eq 'quit') {
        Exit;
    }
    else {
        $installDev += ":\$instFolder"
    }

    if (Test-Path $installDev) {
        cd $installDev
        Write-Output "`n已进入安装路径$installDev"
    }
    else {
        mkdir $installDev
        cd $installDev
        Write-Output "`n已创建安装路径$installDev"
    }
    if ($PSCommandPath -eq $null) { function GetPSCommandPath() { return $MyInvocation.PSCommandPath; } $PSCommandPath = GetPSCommandPath; }
    # Write-Output $PSCommandPath
    if (Test-Path ".\inst-wsl-bota.ps1") {
        del ".\inst-wsl-bota.ps1"
    }
    # Invoke-WebRequest -Uri "$PSCommandPath" -OutFile ".\inst-wsl-bota.ps1"
    Invoke-WebRequest -Uri "$runscript" -OutFile ".\inst-wsl-bota.ps1"
    # Write-Output $runscript | Out-File -FilePath ".\inst-wsl-bota.ps1"
    $installDev += "\inst-wsl-bota.ps1"
    # Write-Output $installDev | Out-File -FilePath ".\inst-wsl-bota.txt"
    setChoco;
}
function setChoco {
    Write-Output "`n正在安装 choco ...`n"
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    $env:Path += $env:ALLUSERSPROFILE + "\chocolatey\bin"
    choco feature enable -n=allowGlobalConfirmation

    Write-Output "`n正在安装 PHP 7.4 ...`n"
    choco install --yes php --version=7.4.14

    Write-Output "`n正在安装 git ...`n"
    choco install --yes git

    Write-Output "`n正在安装 wget ...`n"
    choco install --yes wget

    Write-Output "`n正在安装 composer ...`n"
    choco install --yes composer

    Write-Output "`n正在安装 Nodejs ...`n"
    choco install --yes nodejs --version=14.15.4

    Write-Output "`n正在安装 VSCODE ...`n"
    choco install --yes vscode

    Write-Output "`n开始启用WINDOWS功能组件`n=============================================="
    Write-Output "`n开启虚拟机功能 ...`n"
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    Write-Output "开启Hyper-V ...`n"
    dism.exe /online /enable-feature /featurename:HypervisorPlatform /all /norestart
    Write-Output "开启WSL ...`n"
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

    Write-Output "`n开始启用WINDOWS功能组件`n=============================================="
    Write-Output "`n开始启用虚拟平台 ...`n"
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    Write-Output "`n开始启用WSL ...`n"
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

    RestartandRun "$installDev step2"
}

function step2() {
    $runPath = $PSCommandPath | Split-Path -Parent;
    cd $runPath
    Write-Output "`n升级WSL2 ..."
    if (!(Test-Path ".\wsl_update_x64.msi")) {
        $downfile = "--no-check-certificate https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -O .\wsl_update_x64.msi"
        downloadFile($downfile);
    }
    msiexec /i wsl_update_x64.msi /qn
    Write-Output "升级WSL2完成！"
    Write-Output "`n设置wsl默认版本为2 ..."
    powershell wsl --set-default-version 2
    if (!(Test-Path ".\$wsl.zip")) {
        Write-Output "`n下载 CENTOS FOR WSL 7.0 ..."
        $downfile = "--no-check-certificate $centosFile -O $wsl.zip"
        downloadFile($downfile);
    }
    if ((Test-Path ".\$wsl.zip") -and !(Test-Path ".\$wsl.exe")) {
        Write-Output "`n解压缩 ..."
        Expand-Archive -Force "$wsl.zip" "$runPath"
        Rename-Item "$centosExe" "$wsl.exe"
        Write-Output "`n开始安装centos到WSL中 ...`n==========================================="
        "`n" | & ".\$wsl"
        Write-Output "`n`n设置默认WSL镜像为 [$wsl] ...`n"
        wsl -s $wsl
    }

    clearFile
}

function init() {

    ClearAnyRestart

    switch ($param) {
        "step2" {
            Write-Output "`n WSL安装第二阶段 `n====================="
            Write-Output $runPath
            step2
            # $SecureInput = Read-Host -Prompt "`n安装完成，按任意键进入第三阶段..." -AsSecureString
        }
        "step3" {
            clearFile
        }
        default {
            startInst;
        }
    }
}

function clearFile() {
    Write-Output "`n WSL安装第三阶段 `n====================="
    Write-Output $runPath

    $runPath = $PSCommandPath | Split-Path -Parent;
    cd $runPath

    Write-Output "`n`n安装宝塔系统 ...`n"
    wsl sh -c "yum install git -y && yum install -y wget && wget -O install.sh http://download.bt.cn/install/install_6.0.sh && yes y | sh install.sh"

    Write-Output "`n`n清除残余文件 ...`n"
    Remove-Item -Path ".\wsl_update_x64.msi" -Force
    Remove-Item -Path ".\$wsl.zip" -Force
    Remove-Item -Path ".\inst-wsl-bota.ps1" -Force
    Remove-Item -Path ".\install.sh" -Force
    wsl sh -c "rm -f /www/server/panel/data/admin_path.pl && mv /www/server/panel/data/bind.pl /www/server/panel/data/bind.pl.bak"
    wsl sh -c "sed -i 's/set_panel_username()/set_panel_username(sys.argv[2])/' /www/server/panel/tools.py && cd /www/server/panel && python tools.py username baota && cd /www/server/panel && python tools.py panel 123456"
    wsl sh -c "yum install openssh-server -y | sshd-keygen"
    wsl sh -c "mv /usr/bin/systemctl /usr/bin/systemctl.old -f"
    wsl sh -c "curl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py > /usr/bin/systemctl"
    wsl sh -c "echo '[network]' > /etc/wsl.conf | echo 'generateResolvConf=false' >> /etc/wsl.conf"
    wsl sh -c "mv /etc/resolv.conf /etc/resolv.conf.wsl"
    wsl sh -c "echo '[nameserver]' > /etc/resolv.conf | echo 'nameserver 8.8.8.8' >> /etc/resolv.conf | echo 'nameserver 8.8.4.4' >> /etc/resolv.conf"
    wsl sh -c "sudo chmod +x /usr/bin/systemctl"
    wsl sh -c "systemctl restart sshd"
    wsl sh -c "echo '#! /bin/bash' > /etc/init.wsl | echo 'systemctl start bt' >> /etc/init.wsl | echo 'systemctl start nginx' >> /etc/init.wsl | echo 'systemctl start mysqld' >> /etc/init.wsl | echo 'systemctl start pure-ftpd' >> /etc/init.wsl | echo 'systemctl start sshd' >> /etc/init.wsl | echo 'systemctl start dbus' >> /etc/init.wsl | echo 'sudo bash -c \""echo \\\""nameserver 8.8.8.8\\\"" > /etc/resolv.conf\""' >> /etc/init.wsl | echo 'sudo bash -c \""echo \\\""nameserver 8.8.4.4\\\"" >> /etc/resolv.conf\""' >> /etc/init.wsl"
    wsl sh -c "chmod +x /etc/init.wsl"
    Write-Output "Set ws = CreateObject(`"Wscript.Shell`")" "ws.run `"wsl -d baota -u root /etc/init.wsl`", vbhide" | Out-File -FilePath "$($env:USERPROFILE)\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\startwsl.vbs"
    Write-Output "localhostForwarding=True" | Out-File -FilePath "$($env:USERPROFILE)\.wslconfig"

    <#
    if (!(Test-Path ".\autorunwsl.zip")) {
        Write-Output "`n`n下载 WSL自动运行脚本 ..."
        $downfile = "--no-check-certificate https://github.com/troytse/wsl-autostart/archive/master.zip -O .\autorunwsl.zip"
        downloadFile($downfile);
    }
    if (Test-Path ".\autorunwsl.zip") {
        Write-Output "`n脚本解压缩 ..."
        Expand-Archive -Force "autorunwsl.zip" "$runPath"
    }

    if (Test-Path ".\wsl-autostart-master\start.vbs") {
        Write-Output "`n自动设置启动项 ..."
        Set-Key $regrun "WSLAutostart" "$runPath\wsl-autostart-master\start.vbs"
        Write-Output "/etc/init.d/bt" "/etc/init.d/mysqld" "/etc/init.d/nginx" "/etc/init.d/php-fpm-74" "/etc/init.d/mount" "/etc/init.d/sshd" | Out-File -FilePath ".\wsl-autostart-master\commands.txt"
    }
    
    Remove-Item -Path ".\autorunwsl.zip" -Force
    #>
    Write-Host -NoNewLine "`n安装完成，按任意键结束..."
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

init
