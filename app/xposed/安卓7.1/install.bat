adb root
adb remount
adb push C:/Users/pai/Downloads/xposed/7/xposed /system
adb shell su -c "cd /system/; sh ./memu-script.sh"
pause