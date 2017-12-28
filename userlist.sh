#!/bin/bash
echo "---------------------------------------------"
echo "No.  USERNAME        STATUS       EXP DATE   "
echo "---------------------------------------------"
C=1
ON=0
OFF=0
while read mumetndase
do
        AKUN="$(echo $mumetndase | cut -d: -f1)"
        ID="$(echo $mumetndase | grep -v nobody | cut -d: -f3)"
        exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
        online="$(cat /etc/openvpn/log.log | grep -Eom 1 $AKUN | grep -Eom 1 $AKUN)"
        if [[ $ID -ge 500 ]]; then
        if [[ -z $online ]]; then
        printf "%-4s %-15s %-10s %-3s\n" "$C." "$AKUN" "OFFLINE" "$exp"
        OFF=$((OFF+1))
        else
        printf "%-4s %-15s %-10s %-3s\n" "$C." "$AKUN" "ONLINE" "$exp"
        ON=$((ON+1))
        fi
        C=$((C+1))
        fi
JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
done < /etc/passwd
echo "--------------------------------------------------"
echo " ONLINE : $ON     OFFLINE : $OFF     TOTAL USER : $JUMLAH "
echo "--------------------------------------------------"
