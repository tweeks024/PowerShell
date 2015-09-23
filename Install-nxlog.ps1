#
# Script Name: Install-nxlog.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   9.23.2015


#Import list of servers from CSV and install nxlog on them.

#Uses Microsoft Technet Function for Write-Log from https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0

. c:\scripts\Function-Write-Log.ps1

##### MAIN #####


$List = Import-CSV c:\scripts\nxlog.CSV

forEach ($item in $List) {
 
    $ComputerName = $item.computer

    Invoke-Command -ComputerName $ComputerName -ScriptBlock { New-Item c:\nxlog -type directory }
    Invoke-Command -ComputerName $ComputerName -ScriptBlock { Invoke-WebRequest http://pki.umassmed.edu/pki/nxlog-ce-2.9.1347.msi -Outfile "c:\nxlog\nxlog-ce-2.9.1347.msi" }
    Invoke-Command -ComputerName $ComputerName -ScriptBlock { Invoke-WebRequest http://pki.umassmed.edu/pki/nxlog.bat.txt -Outfile "c:\nxlog\nxlog.bat" }
    Invoke-Command -ComputerName $ComputerName -ScriptBlock { Invoke-WebRequest http://pki.umassmed.edu/pki/globalsignroot.crt -Outfile "c:\nxlog\globalsignroot.crt" }
    Invoke-Command -ComputerName $ComputerName -ScriptBlock { Invoke-WebRequest http://pki.umassmed.edu/pki/nxlog.conf.txt -Outfile "C:\nxlog\nxlog.conf" }
    Invoke-Command -ComputerName $ComputerName -ScriptBlock { c:\nxlog\nxlog.bat }
    Invoke-Command -ComputerName $ComputerName -ScriptBlock { net start nxlog }


    $ConfStatus = Invoke-Command -ComputerName $ComputerName -ScriptBlock { Test-Path "C:\Program Files (x86)\nxlog\conf\nxlog.conf" }  
    $CertStatus = Invoke-Command -ComputerName $ComputerName -ScriptBlock { Test-Path "C:\Program Files (x86)\nxlog\cert\globalsignroot.crt" }

    Write-Log -Message "$ComputerName,ConfCopied=$ConfStatus,CertCopied=$CertStatus" -Path C:\Scripts\NXlog\output.log
}

##### Logging #####

#Rename log to yyyy-MM-dd.log
        
Get-ChildItem C:\Scripts\NXlog\out* | Rename-Item -NewName "$(get-date -f yyyy-MM-dd).log"