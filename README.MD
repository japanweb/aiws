## 2021年1月18日

加入了powershell自动执行代码

首先用管理员权限打开powershell

```powershell
Set-ExecutionPolicy Unrestricted
```

选择A

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/japanweb/aiws/main/inst-wsl-bota.ps1'))
```
需要把CentOS7.zip、inst-wsl-bota.ps1、inst-wsl-hiroichi.ps1、systemctl.py 等文件上传到hiroichi.co.jp/aws上
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://hiroichi.co.jp/aws/inst-wsl-hiroichi.ps1'))
```

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/japanweb/aiws/main/inst-wsl-docker-bota.ps1'))
```

## 2021年1月15日

1.在需要安装docker boa的操作系统中，找到想要安装的分区，新建一个目录，例如：docker
2.在新建的docker目录中，新建一个文本文件，并将aiwa的代码复制进去。
3.将这个文本文件，保存为 ANSI 模式，不然会乱码，然后修改后缀为.bat
4.双击运行bat文件，它会自动要求使用管理员模式，如果可以，请修改管理员权限请求提示。
5.计算机会重新启动两次，第二次启动时，需要等待docker的运行，请不要着急按空格继续!

## 要确认Hyper-V有没有成功被打开
在Windows专业版（如Windows10、Windows11），Hyper-V管理器中，“Hyper-V平台”子目录“Hyper-V虚拟机监控程序”为灰色，无法选中。以华硕B85M-GAMER主板为例，要解决Hyper-V虚拟机监控程序被禁用问题，可以按如下步骤操作：
一、CMOS设置里语言为“English”状态下：
1、重启计算机，开机瞬间按键盘“DEL”或“F2”键进入CMOS设置；
2、接着按键盘“F7”键，进入“Advanced Mode”，接着找到“Advanced”选项；
3、然后点击“CPU Configuration”，右边白色竖条往下拉，找到“Intel Virtualization”，把“Disabled”改为“Enabled”。
4、接着按键盘“→”直到找到“Exit”选项，选择“Save Changes & Reset”，在弹出的对话框中，回车键。电脑重启后设置完成。

参考：
https://zhuanlan.zhihu.com/p/675412359
https://zhidao.baidu.com/question/1576193524233246780.html
