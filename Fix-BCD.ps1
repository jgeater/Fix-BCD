#This script will remove all but the current boot Firmware.
#Mutiple boot firmware entries has been known to cause slow boots and failure to boot from a USB drive
#This script requires admin rights.



Function Get-BCDObject()
{
	$bcdEntries = bcdedit /enum firmware
	$bcdObject = @()
	
	foreach ($bcdEntry in $bcdEntries)
	{
		
		if ($bcdEntry -eq "Windows Boot Loader" -or $bcdEntry -eq "Windows Boot Manager" -or ($bcdEntry -eq "") -or $bcdEntry.Contains("-----"))
		{
			if ($bcdEntry.Contains("-----"))
			{
				$object1 = New-Object PSObject
				$bcdObject += $object1
                Write-host $object1
			}
		}
		else
		{
			$bcdsplit = $bcdEntry.Split(" ")
			$property = $bcdsplit[0]
			$value = ($bcdEntry.Substring($bcdsplit[0].length)).trim()
			
			$object1 | Add-Member -MemberType NoteProperty -Name $($property) -Value $value
		}
	}
	return $bcdObject
}

$bcdObjs = Get-BCDObject # Store bcdedit output in a Powershell object


#Cleanup the extra entries and import the cleanup data
foreach ($bcdObj in $bcdObjs)
{
	$BootIdentifier = $bcdObj.identifier
	$BootDescription = $bcdObj.description
	If ($BootDescription -eq "Windows Boot Loader" -or $BootDescription -eq "Windows Boot Manager" -and $BootIdentifier -ne "{bootmgr}")
	{
		bcdedit /delete $BootIdentifier /cleanup /f
	}
}