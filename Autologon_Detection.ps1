$Network=gwmi Win32_NetworkAdapterConfiguration | select DNSDomain
if (($Network -like "*gopas*") -or ($Network -like "*skola*")) 
	{
		$password="D:\Password.txt"
		if(!(Test-Path -path $password))
			{
				$password = Read-Host "Zadej heslo pro pripojeni na blavaimage"
			}	
		else
			{
				$password=Get-Content $password
			}

		net use w: \\blavaimage\Startup_WinPE$ /user:ghostinstall $password /persistent:no
                
		$MacAddress=(Get-WmiObject win32_NetworkAdapterConfiguration | where {($_.dnsdomain -like "*skola*") -or ($_.dnsdomain -like "*gopas*")}).MACAddress
		$Database=(import-csv -path "w:\deployment\Database.csv" | where {$_.mac1 -eq $MacAddress -or $_.mac2 -eq $MacAddress})
		$Name=($Database).Office
		$outfile = "w:\deployment\classroom"
		$LogName=($Database).Office + "_LOG"
		$StateName=($Database).Office + "_State"
		$Ucebna=($Database).Ucebna

		if (($Ucebna -eq $null) -or ($Ucebna -eq ""))
			{
				$Ucebna="temporary"
			}
		else
			{
				$Ucebna=$Ucebna
			}

        $cas = get-date 
        Write-Host "Autologon founded..." -ForegroundColor Green
		$LogString = "$cas" + ": Starting Autologon" | Out-File "$outfile\$ucebna\$LogName.txt" -encoding ascii -Append
		$String = "Starting Autologon" | Out-File "$outfile\$ucebna\$Name.txt" -encoding ascii -force
		write-host "Deleting map network shares..." -foregroundcolor green
		net use * /y /d
        Write-Host "Starting Autologon..." -ForegroundColor Green
        $Autologon=Get-Content D:\Autologon.txt
        Remove-Item D:\Autologon.txt -Force
        start $Autologon
    }
else
    {
        Write-Host "Autologon founded..." -ForegroundColor Green
        Write-Host "Starting Autologon..." -ForegroundColor Green
        $Autologon=Get-Content D:\Autologon.txt
        Remove-Item D:\Autologon.txt -Force
        start $Autologon
    }