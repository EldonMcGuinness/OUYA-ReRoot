#!/bin/sh
# If no swapfile is found then continue
# checking every 10 seconds for up to 15 minutes
# Version 1.1

LOGGER="/mnt/sdcard/swapon.log"
echo "" > $LOGGER

if [ ! -e "/mnt/usbdrive/swapfile1" ]; then
    echo "SwapFile not found!" >> $LOGGER
    LOOPCOUNT=0

    while [ $LOOPCOUNT -lt 90 ]; do
        sleep 10;

        # Exit the loop if the drive is found
        if [ -e "/mnt/usbdrive/swapfile1" ]; then
            echo "SwapFile found!" >> $LOGGER
            break;
        fi

        LOOPCOUNT=$((LOOPCOUNT + 1))
    done

    # If there is still no Android folder then exit
    if [ ! -e "/mnt/usbdrive/swapfile1" ]; then
        echo "SwapFile still not found, giving up" >> $LOGGER
        exit
    fi
fi

sysctl -w vm.swappiness=50
swapon /mnt/usbdrive/swapfile1