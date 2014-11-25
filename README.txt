ReRoot Script

**Inroduction**
This little bit of script-fu allows you to enable an number of 'hacks', including
superuser access. This script is provided as is and comes with absolutely no warranty
or guarantee.

**What the script can do**
Install Root
Install Init.d (Requires Root)
Install Cron.d (Requires Root & Init.d)
Install Google Play Store (Requires Root)
Permanently Enable Network ADB
Download the latest OTA to /sdcard (Requires Root)
Setup cleanup script to run every hour (Crond)
Setup cache cleaner and reboot to run every week (Crond)
Setup swap on USB (Requires Init.d)
	
**What is inlcuded in this package**
Aside from the reroot script this archive also includes the drivers and sofware to make
an ADB connection to your ouya via usb or network. If you need help setting up the USB
ADB connection then please check:

Windows:
http://www.youtube.com/watch?feature=player_embedded&v=454JFvFTxww

Mac:
http://www.youtube.com/watch?feature=player_embedded&v=5LSBiNfMq8A

This pakcage also includes the files needed to run and install the CWM Recovery software
if you need it. This should not be needed unless there is an issue with the OUYA
application.

**HELP**

- I need to get into recovery mode how can I do this?
  The easiest way to get into this mode requires a USB keyboard (not bluetooth).
  1)  Plug the keyboard in to the OUYA

  2)  Turn on the OUYA and press and hold the (Alt. + PrtScn + i) keys, in that order.
      On each press hold all three for 5 seconds then release, do this over and over 
      for 30 seconds or until the device restarts.

  3)  Once the device restarts you should see the OUYA name with a red exclamation mark.
      Press the home button to show the recovery options.
	
  4)  You can then 'sideload' the latest OTA from your computer to the ouya using the ADB	
      option. You can get the latest OTA url from the link below, just look for the url
      that has the RC-OUYA-X.X.XXXX-r1_ota.zip naming scheme.
      https://devs.ouya.tv/api/firmware_builds 

      Alternatively, if you still can access adb on your ouya and run the reroot.sh script
      it has an option to download the latest OTA file in it.

- Google Play is not working or crashing when I enter it
  If you experience this then you need to make sure you have version 2.5.1 of the Xposed framework installed.
	
- The Moga controller is not working
  Make sure you enabled it in the Mod Collection 4 OUYA for the game in question "App list"
	