#
# Script Name: Win-MoveFailoverCluster.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   8.28.2015


#Get passive node and move cluster to it.

#Uses Microsoft Technet Function for Write-Log from https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0

. c:\scripts\Function-Write-Log.ps1

##### MAIN #####

Import-Module FailoverClusters 

$ClusterGroup = Get-ClusterGroup

forEach ($Cluster in $ClusterGroup) {

$ClusterName = $Cluster | Select -ExpandProperty Name
$OldOwner = $Cluster.OwnerNode | Select -ExpandProperty Name

	if $OldOwner -eq "chcfdb17a" {
		$NewOwner = "chcfdb17b" }
	else {
   		$NewOwner = "chcfdb17a" }

Move-ClusterGroup "$ClusterName" –Node $NewOwner

Start-Sleep 120

$TestClusterGroup = Get-ClusterGroup $ClusterName
$TestClusterOwner = $TestClusterGroup.OwnerNode | Select -ExpandProperty Name

	if $OldOwner -eq $TestClusterOwner {
		Write-Log -Message "$ClusterName,OldOwner=$OldOwner,NewOwner=$TestClusterOwner,Failed" -Path C:\Scripts\ClusterGroup\output.log }
	else {
	    Write-Log -Message "$ClusterName,OldOwner=$OldOwner,NewOwner=$TestClusterOwner,Successful" -Path C:\Scripts\ClusterGroup\output.log }
}

##### Alerting #####

$LogOuput = Get-Content C:\Scripts\ClusterGroup\output.log
$Body = Write-Output $LogOuput | Out-String
	if ($LogOuput -like "*Failed*") {
		Send-MailMessage -to tom.weeks@corp.com -from "NTAlerts <ntalerts@corp.com>" -subject "Cluster Failover FAILED" -body $Body -priority High -smtpServer mail.corp.com }
	else {
		Send-MailMessage -to tom.weeks@corp.com -from "NTAlerts <ntalerts@corp.com>" -subject "Cluster Failover Successful" -body $Body -smtpServer mail.corp.com }

##### Logging #####

#Rename log to yyyy-MM-dd.log and then remove .log files older than 180 logs.  Log removed files to LogCleanup.txt.
		
Get-ChildItem C:\Scripts\ClusterGroup\out* | Rename-Item -NewName "$(get-date -f yyyy-MM-dd).log"

$Now = Get-Date
$Days = "180"
$TargetFolder = "C:\Scripts\ClusterGroup"
$Extension = "*.log"
$LastWrite = $Now.AddDays(-$Days)

$Files = Get-ChildItem $TargetFolder -Include $Extension -Recurse | Where {$_.LastWriteTime -le "$LastWrite"}

foreach ($File in $Files) 
    {
    if ($File -ne $NULL)
        {
        Write-Output "$Now Deleting File $File"  >> C:\Scripts\ClusterGroup\LogCleanup.txt
        Remove-Item $File.FullName | Out-Null
        }
    else
        {
        Write-Output "$No New Files to Delete!"  >> C:\Scripts\ClusterGroup\LogCleanup.txt
        }
    }
