#!/bin/bash

# set -x
# set -e

if [[ $# -gt 0 ]]
then
	echo "this script doesn't need any arguements."
	echo ""
	echo "Usage: ./${0}"
	exit 1
fi


function checkSudo {
	echo "checking sudo permissions"
	sudo -l

	if [[ $? != 0 ]]
	then
		echo ""
		echo "user doesn't have sudo permissions"
		echo ""
	else
		echo "user have sudo permissions"
	fi
}

function checkNetwork {
	echo "checking network information"
	local ip=$(ip a | grep "eth0" | grep "inet" | awk '{print $2}') || exit 1
	local defaultGateway=$(route | grep "default" | awk '{print $2}') || exit 1
	echo ""
	echo "IP address: $ip"
	echo "Default Gateway: $defaultGateway"
	echo ""
}

function readPasswd {
	echo ""
	echo "checking /etc/passwd file"
	local passwd=$(cat /etc/passwd 2>/dev/null)|| exit 1
	touch report/passwd.txt
	echo "$passwd" >> report/passwd.txt || exit 1

}

function suidFiles {
	echo "checking suid files."
	local suid=$(find / -perm -u=s -type f 2>/dev/null)
	touch report/suid.txt
	echo "$suid" >> report/suid.txt || exit 1
}

function enumUser {
	echo ""
	echo "enumerating user information"
	if [[ $UID -eq 0 ]]
	then
		echo "this is root user, you have all permissions"
	fi

	echo "username: $(whoami)" || exit 1
	echo ""
	id || exit 1
	echo ""

}

function enumSystem {
	echo ""
	echo "enumerating system information"
	local arch=$(lscpu | grep "Architecture" | awk '{print $2}') || exit 1
	echo "Architecture: $arch" 
	local kernal=$(uname -a | awk '{print $3}') || exit 1
	echo "kernal version: $kernal" || exit 1
	echo "hostname: $(hostname)"
}

function writableDirs {
	echo ""
	echo "checking writable files"
	local file=$(find / -writable -type d 2>/dev/null) || exit 1
	local dir=$(find / -writable -type f 2>/dev/null) || exit 1

	touch report/writable_file.txt
	touch report/writable_dirs.txt
	echo "$file" >> report/writable_file.txt
	echo "$dir" >> report/writable_dirs.txt
}

function fileSystem {
	echo ""
	echo "enumerating File System"
	local devices=$(df -h 2>/dev/null) || exit 1
	touch report/filesystem.txt
	echo "$devices" >> report/filesystem.txt || exit 1
	echo ""
}

currentDir=$(pwd)

if [[ ! -d "$currentDir/report" ]]
then
	echo "creating /report"
	mkdir report
	echo ""
fi


# calling functions
enumUser
checkSudo
enumSystem
checkNetwork
writableDirs
fileSystem
suidFiles
readPasswd
