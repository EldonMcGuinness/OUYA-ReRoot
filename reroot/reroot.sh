#!/bin/sh
# OUYA-0 Reroot script

SYSTEMID="ouya-0"
RRVER="1.2.3"

function show_notice {
	while true;
	do
		
		echo "###############################################################################"
		echo "###                           Start Rooting Install                         ###"
		echo "###############################################################################"
		echo "###                                                                         ###"
		echo "###  Notice: This little bit of script-fu allows you to enable an number of ###"
		echo "###  'hacks', including superuser access. This script is provided as is and ###"
		echo "###  comes with absoluteyly no warranty or guarantee.                       ###"
		echo "###############################################################################"
		echo ""
		read "inputagree?Do you wish to release your OUYA's inner awesomeness? (y/n): "
		case $inputagree in
			[Yy] )
				show_install_choice
				break
				;;
			[Nn] )
				break
				;;
		esac
	done
}

function show_install_choice {
	while true; do
		
		echo "###############################################################################"
		echo "###                          What do you want to do?                        ###"
		echo "###############################################################################"
		echo "###  1) Install Root                                                        ###"
		echo "###  2) Install Init.d (Requires Root)                                      ###"
		echo "###  3) Install Cron.d (Requires Root & Init.d)                             ###"
		echo "###  4) Install Google Play Store (Requires Root)                           ###"
		echo "###  5) Permanently Enable Network ADB (Requires Root)                      ###"
		echo "###  6) Download the latest OTA to /sdcard (Requires Root)                  ###"
		echo "###  7) Setup cleanup script to run every hour (Requires Crond)             ###"
		echo "###  8) Setup cache cleaner and reboot to run every week (Requires Crond)   ###"
		echo "###  9) Setup swap on USB (Requires Init.d)                                 ###"
		echo "###  r) Reboot                                                              ###"
		echo "###  x) Exit                                                                ###"
		echo "###############################################################################"
		echo ""
		read "inputinstallchoice?What do you want to install? (1-8,r,x): "
		case $inputinstallchoice in
			[1] )
				do_install_root
				;;
			[2] )
				do_install_initd
				;;
			[3] )
				do_install_crond
				;;
			[4] )
				do_install_gp
				;;
			[5] )
				do_install_netadb
				;;
			[6] )
				do_download_ota
				;;
			[7] )
				do_schedule_flush
				;;
			[8] )
				do_schedule_sclean
				;;
			[9] )
				do_setup_swap
				;;
			[Rr] )
				do_show_thanks
				reboot
				break
				;;
			[Xx] )
				break
				;;
		esac
	done
}

function do_install_root {
	
	echo "###############################################################################"
	echo "###                               Installing Root                           ###"
	echo "###############################################################################"
	echo ""

	do_system_rw

	echo "Installing su binary"
	cat bin/su/su > /system/xbin/su
	ln -s /system/xbin/su /system/bin/su
	chmod 6755 /system/xbin/su

	echo "Installing apks"
	for APP in apks/root/*.apk; do
		if [ "$APP" == "*" ]; then
			continue;
		fi
		echo "Installing $APP"
		pm install -r "$APP"
	done
	
	do_system_ro
	
	echo Done, make sure in run and install the busybox app in the MAKE section of your
	echo OUYA before you install anything else with this script!
	read "cont?Press the [Enter] key to continue..."
}

function do_install_initd {
	
	echo "###############################################################################"
	echo "###                              Installing Init.d                          ###"
	echo "###############################################################################"
	echo ""
	
	do_system_rw
	
	mkdir -p /system/etc/init.d
	
	do_system_ro
	
	pm install -r apks/universal.init.d.apk
	
	echo Done!
	echo Do not forget to run the Universal Init.d application and turn it "ON"
	read "cont?Press the [Enter] key to continue..."
}

function do_install_crond {
	
	echo "###############################################################################"
	echo "###                              Installing Cron.d                          ###"
	echo "###############################################################################"
	echo ""
	
	do_system_rw
	
	mkdir -p /system/etc/cron.d
	touch /etc/cron.d/root

	echo What timezone are you in? Please use the following site to figure it out:
	echo http://en.wikipedia.org/wiki/List_of_tz_database_time_zones
	echo ""
	read "inputtz?if you are not sure then just hit enter [America/New_York]: "

	if [ "$inputtz" == "" ]; then
		inputtz=America/New_York
	fi
	
	cat bin/crond/S99crond > /system/xbin/S99crond
	cat bin/crond/flush > /system/xbin/flush
	cat bin/crond/sclean > /system/xbin/sclean
	chmod 744 /system/xbin/flush
	chmod 744 /system/xbin/sclean
	chmod 744 /system/xbin/S99crond

	sed -i "s@###TZ###@${inputtz}@" /system/xbin/S99crond
	
	TZ=$inputtz
	export TZ
	setprop persist.sys.timezone $inputtz
	
	rm /etc/init.d/S99crond 2> /dev/null
	ln -s /system/xbin/S99crond /etc/init.d/S99crond
	
	do_system_ro
	
	echo Done, please reboot your OUYA now.
	read "cont?Press the [Enter] key to continue..."
}

function do_install_gp {
	
	echo "###############################################################################"
	echo "###                     Installing Google Play Store                        ###"
	echo "###############################################################################"
	echo ""
	
	pm install -r apks/xposed_installer.apk
	pm install -r apks/mod_collection4ouya.apk
	pm install -r apks/com.bda.pivot.mogapgp.apk
	
	echo Please make sure you install the xposed framework on the OUYA now, additionally
	echo you will want to enable Mod Collection For OUYA under the modules section too.
	read "cont?Press the [Enter] key to continue..."
	
	do_system_rw
	
	cat ps4ouya/com.android.vending.apk > /system/app/com.android.vending.apk
	cat ps4ouya/com.google.android.gms.apk > /system/app/com.google.android.gms.apk
	cat ps4ouya/GoogleLoginService.apk > /system/app/GoogleLoginService.apk
	cat ps4ouya/GoogleServicesFramework.apk > /system/app/GoogleServicesFramework.apk
	cat ps4ouya/NetworkLocation.apk > /system/app/NetworkLocation.apk
	#chmod 644 /system/com.android.vending.apk
	#chmod 644 /system/com.google.android.gms.apk
	#chmod 644 /system/GoogleLoginService.apk
	#chmod 644 /system/GoogleServicesFramework.apk
	#chmod 644 /system/NetworkLocation.apk
	
	do_system_ro
	
	echo Done, please reboot your OUYA now.
	read "cont?Press the [Enter] key to continue..."
}

function do_install_netadb {
	
	echo "###############################################################################"
	echo "###                   Enabling Permanent Network ADB                        ###"
	echo "###############################################################################"
	echo ""

	adbnettest=$(grep -hoE 'service.adb.tcp.port=' /system/build.prop)
	
	if [ "$adbnettest" != "service.adb.tcp.port=" ]; then
		do_system_rw
	
		echo service.adb.tcp.port=5555 >> /system/build.prop
		
		do_system_ro
		echo Done!
	else
		echo Already Enabled...
	fi
	
	read "cont?Press the [Enter] key to continue..."
	
}

function do_download_ota {
	echo "###############################################################################"
	echo "###                              Downloading OTA                            ###"
	echo "###############################################################################"
	echo ""
	
	otaurl=$(wget -q -O - http://devs.ouya.tv/api/firmware_builds | grep -hoE 'http://.+/RC\-OUYA-.+_ota.zip')
	
	wget -P /sdcard/ $otaurl

	echo "Remember to pull/save this file to your computer, you will need it if you"
	echo "ever need to sideload the rom via the recovery console!"
	read "cont?Press the [Enter] key to continue..."
}

function do_schedule_flush {
	echo "###############################################################################"
	echo "###                            Scheduling Flush                             ###"
	echo "###############################################################################"
	echo ""

	do_system_rw
	
	echo "0 */1 * * * /system/xbin/flush" >> /system/etc/cron.d/root;
	
	do_system_ro
	
	echo Done, please reboot your OUYA now.
	read "cont?Press the [Enter] key to continue..."
}

function do_schedule_sclean {
	echo "###############################################################################"
	echo "###                           Scheduling Sclean                             ###"
	echo "###############################################################################"
	echo ""

	do_system_rw
	
	echo "0 4 * * 1 /system/xbin/sclean" >> /system/etc/cron.d/root;
	
	do_system_ro
	
	echo Done, please reboot your OUYA now.
	read "cont?Press the [Enter] key to continue..."
}

function do_restore {
	
	echo "###############################################################################"
	echo "###                        Restoring Saved Settings                         ###"
	echo "###############################################################################"
	echo ""
	
	do_system_rw
	
	echo "Extracting Backup from /sdcard/${SYSTEMID}.tar"
	tar -xf "/sdcard/${SYSTEMID}.tar" -C / 
	
	do_system_ro
	
	echo Done, please reboot your OUYA now.
	read "Press the [Enter] key to continue..."
}

function do_backup {
	
	echo "###############################################################################"
	echo "###                        Backing up Saved Settings                        ###"
	echo "###############################################################################"
	echo ""

	tar -cf "/sdcard/${SYSTEMID}.tar"  /etc/init.d /system/xbin /etc/cron.d  /system/usr/keylayout
	
	echo Done, settings saved to /sdcard/${SYSTEMID}.tar
	read "cont?Press the [Enter] key to continue..."
}

function do_clone {
	while true; do
		
		echo "###############################################################################"
		echo "###                          What do you want to do?                        ###"
		echo "###############################################################################"
		echo "###  1) Create Image                                                        ###"
		echo "###  2) Restore Image                                                       ###"
		echo "###  x) Return to main menu                                                 ###"
		echo "###                                                                         ###"
		echo "###  NOTE: Pleast make sure you do not have any mountpoint from a USB drive ###"
		echo "###        or network location active as it make become part of the backup! ###"
		echo "###############################################################################"
		echo ""
		read "inputinstallchoice?What do you want to do (1,2,x): "
		case $inputinstallchoice in
			[1] )
				do_createimage
				;;
			[2] )
				do_restoreimage
				;;
			[Xx] )
				break
				;;
		esac
	done
}

function do_createimage {
	
	echo "###############################################################################"
	echo "###                             Cloning Device                              ###"
	echo "###############################################################################"
	echo ""

	tar -cf "/sdcard/${SYSTEMID}.tar"  /etc/init.d /system/xbin /etc/cron.d  /system/usr/keylayout /mnt/sdcard /data/data
	
	echo Done, image saved to /mnt/usbdrive/${SYSTEMID}.tar
	read "cont?Press the [Enter] key to continue..."
}

function do_restoreimage {
	
	echo "###############################################################################"
	echo "###                         Restoring Device Image                          ###"
	echo "###############################################################################"
	echo ""
	
	do_system_rw
	
	echo "Extracting Backup from /mnt/usbdrive/${SYSTEMID}.tar"
	tar -xf "/mnt/usbdrive/${SYSTEMID}.tar" -C / 
	
	do_system_ro
	
	echo Done, please reboot your OUYA now.
	read "Press the [Enter] key to continue..."
}

function do_setup_swap {
	
	echo "###############################################################################"
	echo "###                             Setup Swap on USB                           ###"
	echo "###############################################################################"
	echo ""

	echo Creating a 500MB swapfile! Please be patient this can take a few minutes!
	
	while [ "$(mount | grep /mnt/usbdrive)" == "" ]; do
		echo USB Drive not mounted, please try to plug in the device again.

		read "cont?Cancel swap setup? (y/n): "
		case $cont in
			[Yy] )
				return
				;;
		esac
	done
	
	dd if=/dev/zero of=/mnt/usbdrive/swapfile1 bs=1024 count=524288
	mkswap /mnt/usbdrive/swapfile1
	swapon /mnt/usbdrive/swapfile1
	
	do_system_rw
	cat bin/swap/swapon.sh > /system/xbin/swapon.sh
	ln -s /system/xbin/swapon.sh /etc/init.d/S01swapon
	chmod 744 /etc/init.d/S01swapon
	do_system_ro
	
	echo Done, settings saved to /sdcard/${SYSTEMID}.tar
	read "cont?Press the [Enter] key to continue..."
}

function do_system_rw {
	mount -orw,remount /system
}

function do_system_ro {
	mount -oro,remount /system
}

function do_show_thanks {
	echo "###############################################################################"
    echo "###                                                                         ###"
	echo "###  If you found this script helpful then please consider buying me        ###"
	echo "###  a pint! Eldon.McGuinness@Outlook.com                                   ###"
	echo "###                                                                         ###"
	echo "###############################################################################"

}

echo "Running ReRoot $RRVER"

id=`id`; id=`echo ${id#*=}`; id=`echo ${id%%\(*}`; id=`echo ${id%% *}`
if [ "$id" != "0" ] && [ "$id" != "root" ]; then
	echo "###############################################################################"
	echo "###                                                                         ###"
	echo "###                               ***ROOT REQUIRED***                       ###"
	echo "###                         Please run as root and try again!               ###"
	echo "###                         example: $ su                                   ###"
	echo "###                                                                         ###"
	echo "###############################################################################"
	echo ""
	exit 1
fi

case "$1" in
	install)
		show_notice
		;;
	restore)
		do_restore
		;;
	backup)
		do_backup
		;;
	clone)
		do_clone
		;;
	*)
		echo "Usage: $0 {install|restore|backup|clone}";
		exit 1
esac

do_show_thanks
exit 0