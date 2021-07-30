### Frida

> [https://Frida.com](https://Frida.com)

### 设备
模拟器或真机

### Python库

`pip install frida-tools`

`frida-ps` 验证命令

### frida-server
[https://github.com/frida/frida/releases](https://github.com/frida/frida/releases)

### adb 连接模拟器
```
adb root
adb push frida-server /data/local/tmp/ 
adb shell "chmod 755 /data/local/tmp/frida-server"
adb shell "/data/local/tmp/frida-server &"
```
上传  `frida-server` 到模拟器并运行服务

> frida-ps -U  查看设备正在运行的进程

### Hook代码

