#
# Script Name: Win-DelFiles.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   2.12.2014



#Get files based on lastwrite, filter, and specified folder.  Remove matching files and output results to text file.  Activity log files are named as datestamp and activity log files older than 30 days are removed.

##### MAIN #####

$Now = Get-Date
$Days = "30"
$Extension = "*.log"
$LastWrite = $Now.AddDays(-$Days)


$TargetFolder1 = "D:\inetpub\logs\LogFiles\W3SVC1"
$TargetFolder2 = "D:\inetpub\logs\LogFiles\W3SVC1851132491"
$TargetFolder3 = "C:\Windows\System32\LogFiles\HTTPERR"

$Targets = $TargetFolder1,$TargetFolder2,$TargetFolder3


forEach ($Target in $Targets) {

$Files = Get-ChildItem $Target -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}

    foreach ($File in $Files) 
        {
        if ($File -ne $NULL)
            {
            Write-Output "$Now Deleting File $File"  >> D:\Scripts\LogCleanup\LogDelete.log
            Remove-Item $File.FullName | Out-Null
            }
        else
            {
            Write-Output "$Now No Files to Delete!"  >> D:\Scripts\LogCleanup\LogDelete.log
            }
        }
}


##### Log Cleanup #####

Get-ChildItem C:\Scripts\LogCleanup\LogDelete* | Rename-Item -NewName "$(get-date -f yyyy-MM-dd).log"

$Now = Get-Date
$Days = "30"
$LogFolder = "D:\scripts\LogCleanup"
$Extension = "*.log"
$LastWrite = $Now.AddDays(-$Days)

$LogFiles = Get-ChildItem $LogFolder -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}

foreach ($LogFile in $LogFiles) 
    {
    if ($LogFile -ne $NULL)
        {
        Write-Output "$Now Deleting File $LogFile"  >> D:\scripts\LogCleanup\LogCleanup.txt
        Remove-Item $LogFile.FullName | Out-Null
        }
    else
        {
        Write-Output "$No New Files to Delete!"  >> D:\scripts\LogCleanup\LogCleanup.txt
        }
    }