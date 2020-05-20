$filename = $PSSCriptRoot + "\subnetsurvey.csv"
#Class A Prefix
$ClassA = "192"
#Class B prefix
$ClassB = "168"
#Class C subnets - Split between Data & Management
$Data=@("1","222","33","44","5")
$Management=@("127","234","11")
$results = "IP,Hostname,Connected`n"

foreach ($subnet in $Data){
    for ($i=1;$i -le 255; $i++){
        $ip = "$($ClassA).$($ClassB).$($subnet).$($i)"
        $connected = $false
        $hostname = ""
        if (Test-NetConnection $ip -InformationLevel Quiet -ErrorAction SilentlyContinue -WarningAction SilentlyContinue){
            $connected = $true
            $hostname = Resolve-DnsName $ip -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | select -ExpandProperty NameHost   
        }
        if ($connected) {Write-Host "$ip,$hostname,$connected" -ForegroundColor Green}
        else {Write-Host "$ip,$hostname,$connected" -ForegroundColor Red}
        $results += "$ip,$hostname,$connected`n"
    }
}

foreach ($subnet in $Management){
    for ($i=1;$i -le 255; $i++){
        $ip = "$($ClassA).$($ClassB).$($subnet).$($i)"
        $connected = $false
        $hostname = ""
        if (Test-NetConnection $ip -InformationLevel Quiet -ErrorAction SilentlyContinue -WarningAction SilentlyContinue){
            $connected = $true
            $hostname = Resolve-DnsName $ip -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | select -ExpandProperty NameHost   
        }
        $results += "$ip,$hostname,$connected`n"
    }
}

Write-Output $results | Out-File -FilePath $filename
Send-MailMessage -To "admins@domain.com" -From "powershell@domain.com" -Subject "Subnet Survey" -Body "See attached.Q" -SmtpServer "smtp.domain.com" -port 587 -Attachments $filename
