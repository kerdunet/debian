#!/bin/bash

function create_user() {
	read -p "Username : " kerdunet
  read -p "Password : " Pass
  read -p "Expired (hari): " masaaktif

   IP=`curl icanhazip.com`
   useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $kerdunet
   exp="$(chage -l $kerdunet | grep "Account expires" | awk -F": " '{print $2}')"
   echo -e "$Pass\n$Pass\n"|passwd $kerdunet &> /dev/null
   echo -e ""
   echo -e "----------------------------"
   echo -e "Data Login:"
   echo -e "----------------------------"
   echo -e "Host: $IP"
   echo -e "PortSSH: 22,143,443,109,110,80"
   echo -e "Squid: 8000,8080,3128"
   echo -e "Username: $kerdunet "
   echo -e "Password: $Pass"
   echo -e "Config OpenVPN: $IP:81/1194-client.ovpn"
   echo -e "Aktif Sampai: $exp"
   echo -e "----------------------------"
}

function renew_user() {
	read -p "Username : " Login
  read -p "Password Baru : " Pass
  read -p "Penambahan Masa Aktif (hari): " masaaktif
  userdel $Login
  useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
  exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
  echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
  echo -e "--------------------------------"

  echo -e "Akun Sudah Diperpanjang Hingga $exp"
  echo -e "Password telah diganti dengan $Pass"
  echo -e "==========================="
}

function delete_user(){
	userdel $uname
}

function expired_users(){
	cat /etc/shadow | cut -d: -f1,8 | sed /:$/d > /tmp/expirelist.txt
	totalaccounts=`cat /tmp/expirelist.txt | wc -l`
	for((i=1; i<=$totalaccounts; i++ )); do
		tuserval=`head -n $i /tmp/expirelist.txt | tail -n 1`
		username=`echo $tuserval | cut -f1 -d:`
		userexp=`echo $tuserval | cut -f2 -d:`
		userexpireinseconds=$(( $userexp * 86400 ))
		todaystime=`date +%s`
		if [ $userexpireinseconds -lt $todaystime ] ; then
			echo $username
		fi
	done
	rm /tmp/expirelist.txt
}

function not_expired_users(){
    cat /etc/shadow | cut -d: -f1,8 | sed /:$/d > /tmp/expirelist.txt
    totalaccounts=`cat /tmp/expirelist.txt | wc -l`
    for((i=1; i<=$totalaccounts; i++ )); do
        tuserval=`head -n $i /tmp/expirelist.txt | tail -n 1`
        username=`echo $tuserval | cut -f1 -d:`
        userexp=`echo $tuserval | cut -f2 -d:`
        userexpireinseconds=$(( $userexp * 86400 ))
        todaystime=`date +%s`
        if [ $userexpireinseconds -gt $todaystime ] ; then
            echo $username
        fi
    done
	rm /tmp/expirelist.txt
}

function used_data(){
	myip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1`
	myint=`ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}'`
	ifconfig $myint | grep "RX bytes" | sed -e 's/ *RX [a-z:0-9]*/Received: /g' | sed -e 's/TX [a-z:0-9]*/\nTransfered: /g'
}

clear
PS3='Please enter your choice: '
options=("Add User" "Renew User" "Delete User" "Cek Userlogin" "User List" "Ram Status" "User Yg Belum Exp" "User Yg Sudah Exp" "Autokill" "Cek Kecepatan Server" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Add User")
	    create_user
	    break
            ;;
        "Renew User")
            renew_user
            break
            ;;
        "Delete User")
            read -p "Masukan username: " uname
            delete_user
            break
            ;;
		"Cek Userlogin")
            monssh
            break
            ;;		
		"User List")
            userlist
            break
            ;;	
		"Ram Status")
		    free -h | grep -v + > /tmp/ramcache
            cat /tmp/ramcache | grep -v "Swap"
            break
            ;;	
		"User Yg Belum Exp")
			not_expired_users
			break
			;;
		"User Yg Sudah Exp")
			expired_users
			break
			;;
		"Autokill")
			userlimit 2
			break
			;;
		"Cek Kecepatan Server")
		        speedtest --share
			break
			;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done
