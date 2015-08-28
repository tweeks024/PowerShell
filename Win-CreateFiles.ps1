#
# Script Name: PoSH-CreateFiles.ps1
#
# Author: Tom Weeks
# Email:  tom.m.weeks@gmail.com
# Date:   08.18.2015


##### MAIN #####

# Create number of files equal to ($i –lt 11)


$i = 0
while ($i –lt 150) {
$i++
New-Item D:\MigTest\$i.txt -type file
Add-Content D:\MigTest\$i.txt "This is file $i"
}
