#!/bin/sh
sysctl -w vm.swappiness=50
swapon /mnt/usbdrive/swapfile1
