#!/bin/bash 
function validate_backup_param () 
{
	if [ -d "$1" ] | [ -d "$2" ]
	then
		directory_source="$1"
		directory_target="$2"
	else
		echo "please enter valid directories"
	fi
	if [ -z "$1" ] | [ -z "$2" ] | [ -z "$3" ]
	then
		echo "enter a valid input": Not enough parameters""
	else 
		encryption_key="$3"
	fi
}
function backup ()
{

	date_now=$(date +'%d:%m_%Y' | sed s/\:/_/g | sed s/\ /_/g)
	echo "$date_now"
	mkdir "$directory_target/$date_now"
	cd folders
	for d in $1/*; do

		if [ -d "$d" ]; then
			d=${d##*/}
			cd /root/folders/$1
			tar -cvzf /root/folders/second/$date_now/$d"_"$date_now.tar.gz $d
			gpg --pinentry-mode loopback --passphrase $encryption_key --symmetric /root/folders/$2/$date_now/$d"_"$date_now.tar.gz
			rm /root/folders/$directory_target/$date_now/$d"_"$date_now.tar.gz
			cd ..
		
		fi 
	done

	cd $directory_target
	cd $date_now
	tar -cvf secured_storage.tar $d"_"$date_now.tar.gz.gpg
	rm /root/folders/$directory_target/$date_now/$d"_"$date_now.tar.gz.gpg

	for a in *.gpg; do
		clearr=$(basename $a)
		echo "$clearr"
		tar -uvf secured_storage.tar $clearr
		rm "$clearr"
	done

	gzip secured_storage.tar
	gpg --pinentry-mode loopback --passphrase $encryption_key --symmetric /root/folders/$2/$date_now/secured_storage.tar.gz 
	rm secured_storage.tar.gz
}

function validate_restore_param ()
{
	
	if [ -d "$1" ] | [ -d "$2" ]
	then
		restore_source="$1"
		restore_target="$2"
	else	
		echo "please enter valid directories"
	fi
	if [ -z "$1" ] | [ -z "$2" ] | [ -z "$3" ]
	then
		echo "enter a valid input": Not enough parameters""
	else 
		decryption_key="$3"
	fi
}
function restore ()
{
	decryption_key=$3
	date_now=$(date +'%d:%m_%Y' | sed s/\:/_/g | sed s/\ /_/g)
	cd ~
	mkdir "folders/second/temp"
	echo "ready"
	gpg --batch --output folders/second/temp/secured_storage.tar.gz --passphrase $decryption_key --decrypt folders/second/$date_now/secured_storage.tar.gz.gpg 
	echo "before"
	cd folders
	cd second
	cd temp
	echo "eeeeeh"
	tar -xf secured_storage.tar.gz
	cd ~
	echo "out"
	cd folders
	cd second
	cd temp
	v=0
	for e in *.gpg; do
		echo "$e"
		echo "done names"
		gpg --batch --output $date_now"_"$v.tar.gz --passphrase $decryption_key --decrypt $e
		echo "here encryption" 
		gunzip $date_now"_"$v.tar
		mkdir "Recovered"
		tar -xf $date_now"_"$v.tar -C Recovered
		v=$((v+1))
	done
}

