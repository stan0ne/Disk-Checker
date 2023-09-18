### Getting all domain-joined Server by Names
$servers=(Get-ADComputer -Filter 'operatingsystem -like "*server*"').Name
 
### Get only DriveType 3 (Local Disks) foreach Server
 
ForEach ($s in $servers)
 
{$Report=Get-WmiObject win32_logicaldisk -ComputerName $s -Filter "Drivetype=3" -ErrorAction SilentlyContinue | Where-Object {($_.freespace/$_.size) -le '0.1'}
$View=($Report.DeviceID -join ",").Replace(":","")
### Send Mail if $Report (<=10%) is true
 
If ($Report) {
 

$notificationto = "Stan0ne <stan.one@stano.ne>"
$notificationfrom = "Disk Kullanımı Uyarısı <bilgiislem@stano.ne>"
$smtpserver = "smtp.stano.ne"
$user = "stano.ne\bilgiislem"
$password = ConvertTo-SecureString -String "*zt4n0n3" -AsPlainText -Force
$credent = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $password
$Body = "<html><b>$s</b> sunucusunun <b>$View</b> bölümünde disk alanı <b>%10</b> seviyesinin altına düştü. Lütfen diskte alan açın.</html>"


Send-MailMessage -Body "$Body" -to $notificationto -from $notificationfrom -Subject "STAN0NE - Sunucu Diski Dolmak Üzere!" -SmtpServer $smtpserver -encoding UTF8 -BodyAsHtml -Credential $credent
}

 
}