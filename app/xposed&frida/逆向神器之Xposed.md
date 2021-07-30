### 模拟器上安装`xposed`总是提示缺少一个`ZIP`包
> 解决: 找到模拟器的目录，`adb`所在目录，把文档内的`xposed`文件夹和`install.bat`文件放到目录下面

### 双击执行 `install.bat`

```
adb root
adb remount
adb push ./xposed /system
adb shell su -c "cd /system/;sh memu-script.sh"
pause
```

如果 `adb shell su -c "cd /system/;sh memu-script.sh` 执行是缺少权限，可以直接通过 `adb shell` 进去模拟器对应目录执行 `sh memu-script.sh` 脚本


### 重启模拟器

即可看到 `Xposed`已经激活，无视`缺少一个ZIP包`的提示即可