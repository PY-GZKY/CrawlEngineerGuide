
Frida 是一个强大的跨平台的动态插桩工具，可以用来hook各种函数，修改函数参数，修改函数返回值等等。Frida支持Windows、macOS、Linux、iOS、Android等多个平台，支持多种语言，如JavaScript、Python、Swift、Objective-C等。

### 模拟器或真机

### 安装 Frida

```
pip install frida
pip install frida-tools
```

### 下载 frida-server

[https://github.com/frida/frida/releases](https://github.com/frida/frida/releases)

### adb 连接模拟器并上传 frida-server

上传 `frida-server` 到模拟器/手机并运行服务

```
adb shell && su
adb push ./frida-server /data/local/tmp/ 
adb shell "chmod 755 /data/local/tmp/frida-server"
adb shell "/data/local/tmp/frida-server &"
```

`frida-ps -U` 可以查看设备正在运行的进程：

```text
➜  frida-ps -Ua
  PID  Name       Identifier
5  ---------  -----------------------
27692   Sileo  org.coolstar.SileoStore
23650   微信     com.tencent.xin
11941   日历     com.apple.mobilecal
19641   设置     com.apple.Preferences
```

### 开始Hook代码

frida 分客户端环境和服务端环境。在客户端我们可以编写Python代码，用于连接远程设备，提交要注入的代码到远程，接受服务端的发来的消息等。在服务端，我们需要用Javascript代码注入到目标进程，操作内存数据，给客户端发送消息等操作。我们也可以把客户端理解成控制端，服务端理解成被控端。
假如我们要用PC来对Android设备上的某个进程进行操作，那么PC就是客户端，而Android设备就是服务端。

frida hook有两种模式

- attach模式
  attach到已经存在的进程，核心原理是ptrace修改进程内存。如果此时进程已经处于调试状态(比如做了反调试)，则会attach失败。

- spawn模式
  启动一个新的进程并挂起，在启动的同时注入frida代码，适用于在进程启动前的一些hook，比如hook RegisterNative函数，注入完成后再调用resume恢复进程。

#### 编写实现hook逻辑的JS脚本

我们可以编写Python代码来配合Javascript代码注入。下面我们来看看，怎么使用，先看一段代码

```python
# -*- coding: UTF-8 -*-

import frida, sys

jscode = """
if(Java.available){
    Java.perform(function(){
        var MainActivity = Java.use("com.luoyesiqiu.crackme.MainActivity");
        MainActivity.isExcellent.overload("int","int").implementation=function(chinese,math){
            console.log("[javascript] isExcellent be called.");
            send("isExcellent be called.");
            return this.isExcellent(95,96);      
        }
    });

}
"""


def on_message(message, data):
    if message['type'] == 'send':
        print("[*] {0}".format(message['payload']))
    else:
        print(message)


# 查找USB设备并附加到目标进程
session = frida.get_usb_device().attach('com.luoyesiqiu.crackme')
# 在目标进程里创建脚本
script = session.create_script(jscode)
# 注册消息回调
script.on('message', on_message)
print('[*] Start attach')
# 加载创建好的javascript脚本
script.load()
# 读取系统输入
sys.stdin.read()
```

上面是一段Python代码，我们来分析它的步骤：

- 通过调用frida.get_usb_device()方法来得到一个连接中的USB设备（Device类）实例
- 调用Device类的attach()
  方法来附加到目标进程并得到一个会话（Session类）实例，该方法有一个参数，参数是需要注入的进程名或者进程pid。如果需要Hook的代码在App的启动期执行，那么在调用attach方法前需要先调用Device类的spawn()
  方法，这个方法也有一个参数，参数是进程名，该方法调用后会重启对应的进程，并返回新的进程pid。得到新的进程pid后，我们可以将这个进程pid传递给attach()方法来实现附加。
- 接着调用Session类的create_script()方法创建一个脚本，传入需要注入的javascript代码并得到Script类实例
- 调用Script类的on()方法添加一个消息回调，第一个参数是信号名，乖乖传入message就行，第二个是回调函数
- 最后调用Script类的load()方法来加载刚才创建的脚本。

如何运行：

- 将上面的代码，保存为exp3.py
- 执行adb shell 'su -c /data/local/tmp/frida-server'启动服务端
- 运行目标App
- 执行python exp3.py注入代码
- 按返回键，再重新打开App,发现达到预期
- 按Ctrl+C停止脚本和停止注入代码

除了 get_usb_device 方法，还有 get_remote_device 方法，可以用来连接远程设备，比如连接到局域网内的某个设备。

```python
import frida, sys


def on_message(message, data):
    print("[%s] => %s" % (message, data))


session = frida.get_remote_device().attach('com.shizhuang.duapp')

js_code1 = """
Java.perform(function(){
    console.log("1 start hook");
    var ba = Java.use('com.shizhuang.duapp.common.helper.net.interceptor.HttpRequestInterceptor').$new();
    if (ba){
        console.log("2 find class");
        ba.intercept.implementation = function(a1){
            console.log("3 find method");
            console.log(a1);
            return ba.intercept(a1)
        }
    }
})
"""

script = session.create_script(js_code1)
script.on('message', on_message)
script.load()
sys.stdin.read()
```

frida 工具的意义就是可以让我们在不修改源码的情况下，对程序进行动态的调试和修改，这对于一些黑盒测试来说是非常有用的。

### 如何解决frida抓包时frida.ServerNotRunningError: unable to connect to remote frida-server: closed的报错问题

- 这种情况可能是因为你用的是模拟器,没有自带frida-server，你需要去下载一个:https://github.com/frida/frida/releases
- 忘记开启端口转发 `adb forward tcp:27042 tcp:27042`（这个命令窗口不要关，不然服务端就关闭了）

相关文档：https://book.crifan.org/books/reverse_debug_frida/website/frida_overview