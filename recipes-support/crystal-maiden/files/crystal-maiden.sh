#!/bin/sh
### BEGIN INIT INFO
# Provides:
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO


scriptName="cristal-maiden"

case "$1" in
    start)
        # probe g_serial -> usb to uart
        echo "["$scriptName"]...probe g_serial"
        modprobe g_serial

        # remount RO FS to RW during first boot
        if [ ! -e /rofs.lock ] ; then
            echo "["$scriptName"]...remount FS to RW"
            mount -f -o remount,rw /dev/root
            if [ -e /dev/mmcblk0p3 ] ; then
                mkdir /data
                sed -i '/\/data/c\/dev/mmcblk0p3     /data          auto       defaults  0  0' /etc/fstab
            fi
            if [ -e /dev/mmcblk1p3 ] ; then
                mkdir /data
                sed -i '/\/data/c\/dev/mmcblk1p3     /data          auto       defaults  0  0' /etc/fstab
            fi
            touch /rofs.lock
            sync
            reboot
        fi

    ;;
    stop)
        echo "["$scriptName"]...Nothing to do"
    ;;
    restart)
        echo "["$scriptName"]...Nothing to do"
    ;;
    status)
        echo "["$scriptName"]...Nothing to do"
    ;;
    *)
    echo "Usage: $0 {start|stop|restart|status}}"
    exit 1
    ;;
esac

exit 0
