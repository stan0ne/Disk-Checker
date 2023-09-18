#!/bin/bash
# 'disk' kontrol edilecek disk, disk kapasitesi %90 seviyesine ulaşınca e-posta gönderir. sendmail gerektirir. 'declare:14-22,30' yorumu kapatılarak ek eklenebilir.
 
from="Logsign Server<bilgiislem@stano.ne>"
to="stan.one@stano.ne"
subject="LogSign Disk Uyarisi"
disk="/dev/mapper/disk--vg-root" # disk to monitor
current_usage=$(df -h | grep ${disk} | awk {'print $5'}) # get disk usage from monitored disk
toplam_disk=$(df -h | grep ${disk} | awk {'print $4'}) # get disk usage from monitored disk
kullanilan_diskalan=$(df -h | grep ${disk} | awk {'print $3'})
max_usage="90%" # max 90% disk usage
body="<html>Logsign Sunucu diski dolmak üzere. Diskin <b>${current_usage}</b> alanı doldu. Disk kullanımı bilgisi <b>${kullanilan_diskalan}/${toplam_disk}</b></html>"

# declare -a attachments
# #attachments=( "ek-ekle.zip" ) // ek varsa "#attachments" kare yorum kaldırılır.

# declare -a attargs
# for att in "${attachments[@]}"; do
  # attargs+=( "-a"  "$att" )  
# done
 
# mail -s "$subject" -r "$from" "${attargs[@]}" "$to" <<< "$body"


function doludisk() {
    type mail > /dev/null 2>&1 || { 
        echo >&2 "Mail does not exist. Install it and run script again. Aborting script..."; exit; 
    }

    #mail -s "$subject" -r "$from" "${attargs[@]}" "$to" <<< "$body"
	(
	echo "From:$from"
	echo "To:$to"
	echo "Subject: "$subject""
	echo "Content-Type: text/html"
	echo
	echo "$body"
	echo
	) | /usr/sbin/sendmail -t
	

}

function no_problems() {

    echo "Problem Yok"
}

function main() {

    if [ ${current_usage} ]; then
        if [ ${current_usage%?} -ge ${max_usage%?} ]; then 
            doludisk
        else
            no_problems
        fi
    else
        echo "Kullanılabilir uygun diski seçin ve scripti tekrar başlatın. Diskler:"
        df -h
    fi
}

main