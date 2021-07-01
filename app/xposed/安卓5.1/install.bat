adb root
adb remount
adb push ./xposed /system
adb shell su -c "cd /system/;sh memu-script.sh"
pause