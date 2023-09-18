[string] $smtpServer  = "smtp.stano.ne"; 
[string] $sender      = "bilgiislem@stano.ne"; 
[string] $receiver    = "Stan0ne <stan.one@stano.ne"; 
[string] $subject     = "Disk usage report"; 
[bool]   $asHtml      = $true; 
 
IPMO ActiveDirectory

$computers = (Get-ADComputer -Filter 'operatingsystem -like "*server*"').Name

$Datum = get-Date;
 
$Title = "Diskspace report " + $Datum;
 
$head = @" 
<style type="text/css">
body { font-family:Verdana; font-size: 11px; font-weight: normal;}
</style>
<Title>$Title</Title> 
<br> 
"@  
 
$fragments=@() 

ForEach ($computer in $computers)
{
echo $computer
$data= Get-WmiObject -Class Win32_logicaldisk -filter "drivetype=3" -computer $computers 

}

$groups=$Data | Group-Object -Property SystemName 
 

$gg = "||" 

         
ForEach ($computer in $groups) { 

    $fragments+="<h3>$($computer.Name)</h3>" 
     
    $Drives=$computer.group 
     
    $html=$drives | Where {$_.volumename -ne "page"} |  Select @{Name="Drive";Expression={$_.DeviceID}}, 
    @{Name="Label";Expression={$_.volumename}},
    @{Name="SizeGB";Expression={$_.Size/1GB  -as [int]}}, 
    @{Name="UsedGB";Expression={"{0:N2}" -f (($_.Size - $_.Freespace)/1GB) }}, 
    @{Name="FreeGB";Expression={"{0:N2}" -f ($_.FreeSpace/1GB) }}, 
    @{Name="Usage";Expression={ 
      $UsedPer= (($_.Size - $_.Freespace)/$_.Size)*100 
      $UsedGraph=$gg * ($UsedPer/2) 
      $FreeGraph=$gg * ((100-$UsedPer)/2) 
      "xopenFont color=#FF0000xclose{0}xopen/FontxclosexopenFont Color=#7FFF00xclose{1}xopen/fontxclose" -f $usedGraph,$FreeGraph 
    }}, 
    @{Name="Status";Expression={
      $UsedPer= ((($_.Size - $_.Freespace)/$_.Size)*100 -as [int])
      $StatusStr = switch -regex ($UsedPer)
      {
        { $_ -lt 85}  {"xopenFont Color=greenxcloseHEALTHYxopen/fontxclose"; break;} 
        { $_ -lt 95}  {"xopenFont Color=orangexcloseWARNINGxopen/fontxclose"; break;}
        { $_ -lt 100} {"xopenFont color=redxcloseDANGERxopen/Fontxclose"; break;}
        { $_ -eq 100} {"xopenFont color=redxcloseDANGERxopen/Fontxclose"; break;}
        default       {"-NULL-"}
      }
      "{0} ({1}% used)" -f $StatusStr, $UsedPer 
    }} | ConvertTo-Html -Fragment  
     
    $html=$html -replace "xopen","<" 
    $html=$html -replace "xclose",">" 
     
    $Fragments+=$html 
     
    $fragments+="<br>" 
     
} 
$footer=("<br><I>Report run {0} by {1}\{2} on {3}<I>" -f (Get-Date -displayhint date),$env:userdomain,$env:username,$env:COMPUTERNAME) 
$fragments+=$footer 

$smtpClient = New-Object Net.Mail.SmtpClient($smtpServer); 
$emailFrom  = New-Object Net.Mail.MailAddress $sender, $sender; 
$emailTo    = New-Object Net.Mail.MailAddress $receiver , $receiver; 
$mailMsg    = New-Object Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $fragments); 
 
$mailMsg.IsBodyHtml = $asHtml; 
$smtpClient.Send($mailMsg) 