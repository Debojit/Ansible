#!/bin/bash

if [ $# -eq 0 ]
then
	echo "Usage: raspi-sd.sh [PathToImageFile]"
	exit 1
elif [ ! -f $1 ]
then
	echo "Image file "$1 " not found."
	exit 1
else
	disk_img=$1
fi

echo 'Locating drives for Raspberry PI SD Card:'
disk_str=`df -h | grep disk | awk '{print $1}'`
disk_str=`echo $disk_str | sed 's|s1||g'`
read -a disk_arr <<< $disk_str
num_disks=${#disk_arr[@]}

echo $num_disks" disks found."
echo 'Pick a disk to install Raspberry PI SD:'

for index in "${!disk_arr[@]}"
do
	echo "$(($index+1)) : ${disk_arr[index]}"
done
read -p "Pick a drive:" disk_idx

case $disk_idx in
[0-9]*) 
	if [ $disk_idx -le 0 ] || [ $disk_idx -gt $num_disks ]
	then
		echo "ERROR: Invalid choice:"$disk_idx". Exiting."
		exit 1
	fi
	;;
*)
	echo "ERROR: Input must be a number."
	exit 1
	;;
esac

tgt_disk=${disk_arr[(($disk_idx-1))]}

echo "Raspbian will be installed at the following disk:"$tgt_disk
read -p "Please Confirm[y/n]:" confirm_flag

if [ $confirm_flag == 'y' ] || [ $confirm_flag == 'Y' ]
then
	echo "Formatting disk "$tgt_disk" as MS-DOS FAT32.."
	sudo diskutil eraseDisk FAT32 RASPY MBRFormat $tgt_disk
	sudo diskutil unmountDisk $tgt_disk
	
	echo "Format complete. Installing Raspbian Image "$disk_img" to disk "$tgt_disk
	sudo dd if=$disk_img of=$tgt_disk
	echo "Image installed. Enabling SSH."
	sudo touch /Volumes/boot/ssh
	echo "SSH enabled. Please eject."
	exit 0
elif [ $confirm_flag == 'n' ] || [ $conirm_flag == 'N' ]
then
	echo "User elected to discontinue formatting. Script will now exit."
	exit 0
else
	echo "ERROR: Invalid input:"$confirm_flag"."
	exit 1
fi
