$ErrorActionPreference = "SilentlyContinue"
$ScreenWidth = (Get-WmiObject -Class Win32_DesktopMonitor).ScreenWidth
if($ScreenWidth -is [array])
{
    $ScreenWidth = $ScreenWidth[0]/8
}
else
{
    if($ScreenWidth -eq $null)
    {
        $ScreenWidth = 120
    }
    else
    {
        $ScreenWidth = $ScreenWidth/8
    }
}
$BufferWidth = $ScreenWidth-30
$BufferHeight = 600
$bUpdateSize = $false
$RawUI = (Get-Host).UI.RawUI
$BufferSize = $RawUI.BufferSize

if ($BufferSize.Width -lt $BufferWidth) {$BufferSize.Width = $BufferWidth; $bUpdateSize = $true}
if ($BufferSize.Height -lt $BufferHeight) {$BufferSize.Height = $BufferHeight; $bUpdateSize = $true}
if ($bUpdateSize -eq $true) {$RawUI.BufferSize = $BufferSize}

Remove-Variable bUpdateSize

##**Global Premenna
#Nastavenia konzoly
$Global:fgColor = "DarkYellow"
$Global:bgColor = "DarkCyan"
$Global:Title = "Selmostroj"
$Global:UserInputColor = "Yellow"
$Global:OnScreenMsgColor = "Green"
$Global:ErrorColor = "Red"

#Detekcia informacii o operacnom systeme
$OS = Get-WmiObject Win32_OperatingSystem
$Global:OSMajorVersion = $OS.version.substring(0,3)
$Global:OSSKU = $OS.OperatingSystemSKU
$Global:OSCaption = $OS.Caption
$Global:OldCSName = $OS.CSName
$Global:OSArchitecture = $OS.OSArchitecture

#Detekcia Hardwerovej zostavy
$HW = Get-WmiObject Win32_ComputerSystem
$Global:HWVendor = $HW.Manufacturer
$Global:HWModel = (Get-WmiObject -ComputerName $Global:OldCSName  Win32_BaseBoard  |  Select Product).Product	
$Global:HWRAM = ([math]::round($HW.TotalPhysicalMemory /1024/1024)).tostring() + " MB"
$Global:HWCPUCount = $HW.NumberOfProcessors
$Global:HWUserName = $HW.UserName
$Global:UserName = $env:UserName
$Global:WorkGroup = $HW.Workgroup


#Detekcia procesoru
$Processor = Get-WmiObject -class Win32_processor
$Global:ProcName = $Processor.Name
$Global:ProcCores = $Processor.NumberOfCores
$Global:ProcLogicals = $Processor.NumberOfLogicalProcessors

#System locale
$Global:LCID = (Get-Culture).LCID
$Global:CultureName = (Get-Culture).Name

#Time Zone
$Global:CurrentTZName = (Get-WmiObject win32_timezone).Description

#Nastavenie Titlu
$RawUI.WindowTitle = $Global:Title

if(Test-Path "Z:\_scripts")
{
	$TempDrive = "Z:"
}
elseif(Test-Path "W:\_scripts")
{
	$TempDrive = "W:"
}

Function Write-Header
{	
	##**Hlavicka**
	Clear-Host
    Write-Host ""
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Write-Host ""
	Write-Host "Basic System Information:" -ForegroundColor $Global:OnScreenMsgColor
	Write-Host "*************************" -ForegroundColor $Global:OnScreenMsgColor
	Write-Host ""
	Write-Host "Computer Name:        " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:OldCSName -ForegroundColor $Global:UserInputColor
	Write-Host "System Manufacturer:  " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:HWVendor -ForegroundColor $Global:UserInputColor
	Write-Host "System Model:         " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:HWModel -ForegroundColor $Global:UserInputColor
	Write-Host "Operating System:     " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:OSCaption -ForegroundColor $Global:UserInputColor
	Write-Host "OS Architecture:      " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:OSArchitecture -ForegroundColor $Global:UserInputColor
	Write-Host "Physical Memory:      " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:HWRAM -ForegroundColor $Global:UserInputColor
   #Write-Host "Physical CPU Count:   " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:HWCPUCount -ForegroundColor $Global:UserInputColor
	Write-Host "Processor Name:       " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:ProcName -ForegroundColor $Global:UserInputColor
	Write-Host "Cores:                " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:ProcCores -ForegroundColor $Global:UserInputColor
	Write-Host "Logical Cores:        " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:ProcLogicals -ForegroundColor $Global:UserInputColor
	Write-Host "System Locale:        " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:CultureName -ForegroundColor $Global:UserInputColor
	Write-Host "Current Time Zone:    " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:CurrentTZName -ForegroundColor $Global:UserInputColor
	Write-Host "Current User Name:    " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:HWUserName -ForegroundColor $Global:UserInputColor	
    Write-Host "WorkGroup:            " -ForegroundColor $Global:OnScreenMsgColor -NoNewline; Write-Host $Global:WorkGroup -ForegroundColor $Global:UserInputColor	
	Write-Host ""
}

Function Help
{
	<#

	.SYNOPSIS

	Retrieve specific information about one or more folders

	.DESCRIPTION

	This function can be used to read information about folder properties.

	Some of the properties this function can read include size, when created,

	last modified and many more.

	.PARAMETER Path

	This parameter contains the full path to the folder you wish to

	display information for.

	.EXAMPLE

	Get-FolderData -Path "c:\temp\test1"

	This command returns information for the folder c:\temp\test1

	#>
	 
	Write-Host "Hello World!"
}

Function GhostClientInstall($Path)
{
	<#
	.SYNOPSIS
	Nakopiruje a spusti clienta.
	
	.DESCRIPTION
	Copy adn run Client.
	Example: 
	GhostClientOn
	 
	.EXAMPLE
	GhostClientOn
	#>
    if(Test-Path $Path)
	{			
		& cmd /c "$Path /passive /norestart"
        Write-Host "Instalation of GhostClient is found." -ForegroundColor Yellow 
	}
	else
	{
		Write-Host "Instalation of GhostClient is not found." -ForegroundColor Yellow 
	}
}

Function Get-ScriptDirectory
{
	<#
	.SYNOPSIS
	Script na zistenie Pracovneho adresara.
	
	.DESCRIPTION
	Return Work Directory.
	Example: 
	$Path = Get-ScripDirectory
	 
	.EXAMPLE
	$Path = Get-ScripDirectory
	#>	
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
	$Path = Split-Path $Invocation.MyCommand.Path	
	if($Path.Length -le 3)
	{
		$Path = $Path.Substring(0,2)
	}	
	return $Path
}

Function Set-DefaultWebPage($Name)
{
	<#
	.SYNOPSIS
	Script na Nastavenie defaultnej stranky v Internet Explorery.
	
	.DESCRIPTION	
	Set Default Web Page in Internet Explorer.
	Example: 
	Set-DefaultWebPage("http://www.gopas.sk")
	 
	.EXAMPLE
	$Path = Get-ScripDirectory
	#>	
	
	Set-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Internet Explorer\main' -Name "Start Page" -Value $Name >> $null
	Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Internet Explorer\main' -Name "Start Page" -Value $Name >> $null
	Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Internet Explorer\main' -Name "Default_Page_URL" -Value $Name >> $null
	
	Write-Host -ForegroundColor Green "Zmenena domovska stranka IE"
}


Function Set-Credential($Site, $LoginName, $LoginPassword)
{
	<#
	.SYNOPSIS
	Script na nastavenie prihlasovacych udajov pre jednotlive domeny.
	
	.DESCRIPTION	
	Set Credential for domains.
	Example: 
	Set-Credential "dc.skola.cz" "Student02" 'Pa$$w0rd' 
	 
	.EXAMPLE
	Set-Credential "dc.skola.cz" "Student02" 'Pa$$w0rd'
	#>
	cmdkey.exe /add:$Site /user:$LoginName /pass:$LoginPassword
}

Function Set-CredentialGeneric($Site, $LoginName, $LoginPassword)
{
	<#
	.SYNOPSIS
	Script na nastavenie prihlasovacych udajov pre jednotlive domeny.
	
	.DESCRIPTION	
	Set CredentialGeneric for domains.
	Example: 
	Set-CredentialGeneric 'MS.Outlook.15:Student02@sps.skola.cz:PUT' "Student02" 'Pa$$w0rd'
	 
	.EXAMPLE
	Set-CredentialGeneric 'MS.Outlook.15:Student02@sps.skola.cz:PUT' "Student02" 'Pa$$w0rd'
	#>
	cmdkey.exe /Generic:$Site /user:$LoginName /pass:$LoginPassword
}

Function Set-IntranetSites($Domain, $Sites)
{
	<#
	.SYNOPSIS
	Script na nastavenie Localnych Intranet Sites pre domenu.
	
	.DESCRIPTION	
	Set Intranet Sites for domain.
	Example: 
	Set-IntranetSites "skola.cz" ("shrp0210","shrp0110")
	Set-IntranetSites "skola.cz" ("shrp0210")
	 
	.EXAMPLE
	Set-IntranetSites "skola.cz" ("shrp0210","shrp0110")
	Set-IntranetSites "skola.cz" ("shrp0210")
	#>
	
	If (!(Test-Path -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\$Domain")) {
		New-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains" -Name $Domain
	}
	foreach ($Site in $Sites) {
		Write-Host "Adding to Intranet Sites $Site" -ForegroundColor Yellow
		If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\$Domain\""{$Site}NOSPACES")) {New-Item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\$Domain" -Name $Site | New-ItemProperty -Name http -PropertyType DWord -Value 1 | out-null }
	}
}

Function Proxy-OFF
{
	<#
	.SYNOPSIS
	Script na vypnutie proxy.
	
	.DESCRIPTION	
	Turn Off Proxy.
	Example: 
	Proxy-OFF
	 
	.EXAMPLE
	Proxy-OFF
	#>
	$reg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
	Set-ItemProperty -Path $reg -Name ProxyEnable -Value 0
	$rtn = Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 0
	Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyOverride -Value '*.local;<local>'
	if($rtn) 
	{
	   Write-Host -ForegroundColor Green "Vypnute Proxy"
	}
}

Function SetRunAsAdmin($FilePath)
{
	New-Item "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" -Name $FilePath -Value "~ RUNASADMIN"	
}

Function Proxy-Praha
{
	write-host "GOPAS network detected..." -foregroundcolor green
	write-host "Disabling proxy server..." -foregroundcolor green
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value "1"
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyServer -Value "prahaproxy.gopas.cz:8080"
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyOverride -Value "<local>"
}

Function Proxy-ON
{
	<#
	.SYNOPSIS
	Script na zapnutie proxy.
	
	.DESCRIPTION	
	Turn ON Proxy.
	Example: 
	Proxy-ON
	 
	.EXAMPLE
	Proxy-ON
	#>
	$rtn = Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 1
	if($rtn) 
	{
	   Write-Host -ForegroundColor Green "Zapnutie Proxy"
	}
}

Function Set-DNS4ALL($DNS_IP)
{
	<#
	.SYNOPSIS
	Script na Nastavenie DNS.
	
	.DESCRIPTION	
	SET DNS IP.
	Example: 
	Set-DNS4ALL("10.2.1.10")
	Set-DNS4ALL("10.2.1.10","10.2.1.30")
	 
	.EXAMPLE
	Set-DNS4ALL("10.2.1.10")
	Set-DNS4ALL("10.2.1.10","10.2.1.30")
	#>
	$NICs = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName . | where{$_.IPEnabled -eq $true}
	If ($NICs -eq $null) 
	{		
		Write-Host 'Nemohu nalezt zadnou aktivni sitovku' -ForegroundColor Yellow
	}
	Foreach ($NIC in $NICs) 
	{
		Write-Host "Setting DNS IP.. $$DNS_IP" -ForegroundColor Yellow
		$NIC.SetDNSServerSearchOrder($DNS_IP)
	}
}

Function AppendToFile($Name, $String)
{
	Add-Content $Name $String
}

Function CreateFile($Name)
{
	Write-Host "Creating New File $Name" -ForegroundColor Yellow
	New-Item $Name -Type file -Force
}


Function CreatePRF1($Login, $Student, $Domain, $Path)
{
	<#
	.SYNOPSIS
	Script na Vytvorenie PRF1 suboru pre konfiguraciu Outlooku.
	
	.DESCRIPTION	
	Script na Vytvorenie PRF1 suboru pre konfiguraciu Outlooku.
	Example: 
	CreatePRF1 "sps.skola.cz"
	 
	.EXAMPLE
	CreatePRF1 "sps.skola.cz"
	#>	
	$Path = $Path+"\PRFcomplete.prf"
	$Password = 'Pa$$w0rd'
	CreateFile $Path
	
	if($Domain -like "gopasskola*")
	{
		AppendToFile $Path "[General]
Custom=1
ProfileName=Outlook
DefaultProfile=Yes
OverwriteProfile=Yes
ModifyDefaultProfileIfPresent=false

[Service List]
ServiceEGS1=Exchange Global Section
Service1=Microsoft Exchange Server

[Internet Account List]

[ServiceEGS1]
MailboxName=$Login
HomeServer=$Domain
AccountName=$Student
ConfigFlags=0x00000000

[Service1]
OverwriteExistingService=Yes
UniqueService=No
MailboxName=$Login
HomeServer=$Domain

[Microsoft Exchange Server]
ServiceName=MSEMS
MDBGUID=5494A1C0297F101BA58708002B2A2517
MailboxName=PT_STRING8,0x6607
HomeServer=PT_STRING8,0x6608
OfflineAddressBookPath=PT_STRING8,0x660E
OfflineFolderPathAndFilename=PT_STRING8,0x6610

[Exchange Global Section]
SectionGUID=13dbb0c8aa05101a9bb000aa002fc45a
MailboxName=PT_STRING8,0x6607
HomeServer=PT_STRING8,0x6608
ConfigFlags=PT_LONG,0x6601
RPCoverHTTPflags=PT_LONG,0x6623
RPCProxyServer=PT_UNICODE,0x6622
RPCProxyPrincipalName=PT_UNICODE,0x6625
RPCProxyAuthScheme=PT_LONG,0x6627
AccountName=PT_UNICODE,0x6620

[Microsoft Mail]
ServiceName=MSFS
ServerPath=PT_STRING8,0x6600
Mailbox=PT_STRING8,0x6601
Password=PT_STRING8,0x67f0
RememberPassword=PT_BOOLEAN,0x6606
ConnectionType=PT_LONG,0x6603
UseSessionLog=PT_BOOLEAN,0x6604
SessionLogPath=PT_STRING8,0x6605
EnableUpload=PT_BOOLEAN,0x6620
EnableDownload=PT_BOOLEAN,0x6621
UploadMask=PT_LONG,0x6622
NetBiosNotification=PT_BOOLEAN,0x6623
NewMailPollInterval=PT_STRING8,0x6624
DisplayGalOnly=PT_BOOLEAN,0x6625
UseHeadersOnLAN=PT_BOOLEAN,0x6630
UseLocalAdressBookOnLAN=PT_BOOLEAN,0x6631
UseExternalToHelpDeliverOnLAN=PT_BOOLEAN,0x6632
UseHeadersOnRAS=PT_BOOLEAN,0x6640
UseLocalAdressBookOnRAS=PT_BOOLEAN,0x6641
UseExternalToHelpDeliverOnRAS=PT_BOOLEAN,0x6639
ConnectOnStartup=PT_BOOLEAN,0x6642
DisconnectAfterRetrieveHeaders=PT_BOOLEAN,0x6643
DisconnectAfterRetrieveMail=PT_BOOLEAN,0x6644
DisconnectOnExit=PT_BOOLEAN,0x6645
DefaultDialupConnectionName=PT_STRING8,0x6646
DialupRetryCount=PT_STRING8,0x6648
DialupRetryDelay=PT_STRING8,0x6649

[Personal Folders]
ServiceName=MSPST MS
Name=PT_STRING8,0x3001
PathAndFilenameToPersonalFolders=PT_STRING8,0x6700 
RememberPassword=PT_BOOLEAN,0x6701
EncryptionType=PT_LONG,0x6702
Password=PT_STRING8,0x6703

[Unicode Personal Folders]
ServiceName=MSUPST MS
Name=PT_UNICODE,0x3001
PathAndFilenameToPersonalFolders=PT_STRING8,0x6700 
RememberPassword=PT_BOOLEAN,0x6701
EncryptionType=PT_LONG,0x6702
Password=PT_STRING8,0x6703

[Outlook Address Book]
ServiceName=CONTAB

[LDAP Directory]
ServiceName=EMABLT
ServerName=PT_STRING8,0x6600
UserName=PT_STRING8,0x6602
UseSSL=PT_BOOLEAN,0x6613
UseSPA=PT_BOOLEAN,0x6615
EnableBrowsing=PT_BOOLEAN,0x6622
DisplayName=PT_STRING8,0x3001
ConnectionPort=PT_STRING8,0x6601
SearchTimeout=PT_STRING8,0x6607
MaxEntriesReturned=PT_STRING8,0x6608
SearchBase=PT_STRING8,0x6603
CheckNames=PT_STRING8,0x6624
DefaultSearch=PT_LONG,0x6623

[Microsoft Outlook Client]
SectionGUID=0a0d020000000000c000000000000046
FormDirectoryPage=PT_STRING8,0x0270
WebServicesLocation=PT_STRING8,0x0271
ComposeWithWebServices=PT_BOOLEAN,0x0272
PromptWhenUsingWebServices=PT_BOOLEAN,0x0273
OpenWithWebServices=PT_BOOLEAN,0x0274
CachedExchangeMode=PT_LONG,0x041f
CachedExchangeSlowDetect=PT_BOOLEAN,0x0420

[Personal Address Book]
ServiceName=MSPST AB
NameOfPAB=PT_STRING8,0x001e3001
PathAndFilename=PT_STRING8,0x001e6600
ShowNamesBy=PT_LONG,0x00036601

[I_Mail]
AccountType=POP
AccountName=PT_UNICODE,0x0002
DisplayName=PT_UNICODE,0x000B
EmailAddress=PT_UNICODE,0x000C
POP3Server=PT_UNICODE,0x0100
POP3UserName=PT_UNICODE,0x0101
POP3UseSPA=PT_LONG,0x0108
Organization=PT_UNICODE,0x0107
ReplyEmailAddress=PT_UNICODE,0x0103
POP3Port=PT_LONG,0x0104
POP3UseSSL=PT_LONG,0x0105
SMTPServer=PT_UNICODE,0x0200
SMTPUseAuth=PT_LONG,0x0203
SMTPAuthMethod=PT_LONG,0x0208
SMTPUserName=PT_UNICODE,0x0204
SMTPUseSPA=PT_LONG,0x0207
ConnectionType=PT_LONG,0x000F
ConnectionOID=PT_UNICODE,0x0010
SMTPPort=PT_LONG,0x0201
SMTPSecureConnection=PT_LONG,0x020A
ServerTimeOut=PT_LONG,0x0209
LeaveOnServer=PT_LONG,0x1000

[IMAP_I_Mail]
AccountType=IMAP
AccountName=PT_UNICODE,0x0002
DisplayName=PT_UNICODE,0x000B
EmailAddress=PT_UNICODE,0x000C
IMAPServer=PT_UNICODE,0x0100
IMAPUserName=PT_UNICODE,0x0101
IMAPUseSPA=PT_LONG,0x0108
Organization=PT_UNICODE,0x0107
ReplyEmailAddress=PT_UNICODE,0x0103
IMAPPort=PT_LONG,0x0104
IMAPUseSSL=PT_LONG,0x0105
SMTPServer=PT_UNICODE,0x0200
SMTPUseAuth=PT_LONG,0x0203
SMTPAuthMethod=PT_LONG,0x0208
SMTPUserName=PT_UNICODE,0x0204
SMTPUseSPA=PT_LONG,0x0207
ConnectionType=PT_LONG,0x000F
ConnectionOID=PT_UNICODE,0x0010
SMTPPort=PT_LONG,0x0201
SMTPSecureConnection=PT_LONG,0x020A
ServerTimeOut=PT_LONG,0x0209
CheckNewImap=PT_LONG,0x1100
RootFolder=PT_UNICODE,0x1101
Account=PT_UNICODE,0x0002
HttpServer=PT_UNICODE,0x0100
UserName=PT_UNICODE,0x0101
Organization=PT_UNICODE,0x0107
UseSPA=PT_LONG,0x0108
TimeOut=PT_LONG,0x0209
Reply=PT_UNICODE,0x0103
EmailAddress=PT_UNICODE,0x000C
FullName=PT_UNICODE,0x000B
Connection Type=PT_LONG,0x000F
ConnectOID=PT_UNICODE,0x0010
"
}
else
{
	AppendToFile $Path "[General]
Custom=1
ProfileName=Outlook
DefaultProfile=Yes
OverwriteProfile=Yes
ModifyDefaultProfileIfPresent=false

[Service List]
ServiceEGS1=Exchange Global Section
Service1=Microsoft Exchange Server

[ServiceEGS1]
HomeServer=$Domain
ConfigFlags=0x00000000
RPCoverHTTPflags=0x002f
RPCProxyServer=exserver.$Domain
RPCProxyPrincipalName=msstd:$Domain
RPCProxyAuthScheme=0x0002
MailboxName=$Login
AccountName=$Student

[Service1]
MailboxName=$Login
OverwriteExistingService=Yes
UniqueService=Yes
HomeServer=$Domain
Password=$Password

[Microsoft Exchange Server]
ServiceName=MSEMS
MDBGUID=5494A1C0297F101BA58708002B2A2517
MailboxName=PT_STRING8,0x6607
HomeServer=PT_STRING8,0x6608
OfflineAddressBookPath=PT_STRING8,0x660E
OfflineFolderPathAndFilename=PT_STRING8,0x6610

[Exchange Global Section]
SectionGUID=13dbb0c8aa05101a9bb000aa002fc45a
MailboxName=PT_STRING8,0x6607
HomeServer=PT_STRING8,0x6608
ConfigFlags=PT_LONG,0x6601
RPCoverHTTPflags=PT_LONG,0x6623
RPCProxyServer=PT_UNICODE,0x6622
RPCProxyPrincipalName=PT_UNICODE,0x6625
RPCProxyAuthScheme=PT_LONG,0x6627
AccountName=PT_UNICODE,0x6620

[Microsoft Mail]
ServiceName=MSFS
ServerPath=PT_STRING8,0x6600
Mailbox=PT_STRING8,0x6601
Password=PT_STRING8,0x67f0
RememberPassword=PT_BOOLEAN,0x6606
ConnectionType=PT_LONG,0x6603
UseSessionLog=PT_BOOLEAN,0x6604
SessionLogPath=PT_STRING8,0x6605
EnableUpload=PT_BOOLEAN,0x6620
EnableDownload=PT_BOOLEAN,0x6621
UploadMask=PT_LONG,0x6622
NetBiosNotification=PT_BOOLEAN,0x6623
NewMailPollInterval=PT_STRING8,0x6624
DisplayGalOnly=PT_BOOLEAN,0x6625
UseHeadersOnLAN=PT_BOOLEAN,0x6630
UseLocalAdressBookOnLAN=PT_BOOLEAN,0x6631
UseExternalToHelpDeliverOnLAN=PT_BOOLEAN,0x6632
UseHeadersOnRAS=PT_BOOLEAN,0x6640
UseLocalAdressBookOnRAS=PT_BOOLEAN,0x6641
UseExternalToHelpDeliverOnRAS=PT_BOOLEAN,0x6639
ConnectOnStartup=PT_BOOLEAN,0x6642
DisconnectAfterRetrieveHeaders=PT_BOOLEAN,0x6643
DisconnectAfterRetrieveMail=PT_BOOLEAN,0x6644
DisconnectOnExit=PT_BOOLEAN,0x6645
DefaultDialupConnectionName=PT_STRING8,0x6646
DialupRetryCount=PT_STRING8,0x6648
DialupRetryDelay=PT_STRING8,0x6649

[Personal Folders]
ServiceName=MSPST MS
Name=PT_STRING8,0x3001
PathAndFilenameToPersonalFolders=PT_STRING8,0x6700 
RememberPassword=PT_BOOLEAN,0x6701
EncryptionType=PT_LONG,0x6702
Password=PT_STRING8,0x6703

[Unicode Personal Folders]
ServiceName=MSUPST MS
Name=PT_UNICODE,0x3001
PathAndFilenameToPersonalFolders=PT_STRING8,0x6700 
RememberPassword=PT_BOOLEAN,0x6701
EncryptionType=PT_LONG,0x6702
Password=PT_STRING8,0x6703

[Outlook Address Book]
ServiceName=CONTAB

[LDAP Directory]
ServiceName=EMABLT
ServerName=PT_STRING8,0x6600
UserName=PT_STRING8,0x6602
UseSSL=PT_BOOLEAN,0x6613
UseSPA=PT_BOOLEAN,0x6615
EnableBrowsing=PT_BOOLEAN,0x6622
DisplayName=PT_STRING8,0x3001
ConnectionPort=PT_STRING8,0x6601
SearchTimeout=PT_STRING8,0x6607
MaxEntriesReturned=PT_STRING8,0x6608
SearchBase=PT_STRING8,0x6603
CheckNames=PT_STRING8,0x6624
DefaultSearch=PT_LONG,0x6623

[Microsoft Outlook Client]
SectionGUID=0a0d020000000000c000000000000046
FormDirectoryPage=PT_STRING8,0x0270
WebServicesLocation=PT_STRING8,0x0271
ComposeWithWebServices=PT_BOOLEAN,0x0272
PromptWhenUsingWebServices=PT_BOOLEAN,0x0273
OpenWithWebServices=PT_BOOLEAN,0x0274
CachedExchangeMode=PT_LONG,0x041f
CachedExchangeSlowDetect=PT_BOOLEAN,0x0420

[Personal Address Book]
ServiceName=MSPST AB
NameOfPAB=PT_STRING8,0x001e3001
PathAndFilename=PT_STRING8,0x001e6600
ShowNamesBy=PT_LONG,0x00036601

[I_Mail]
AccountType=POP3
AccountName=PT_UNICODE,0x0002
DisplayName=PT_UNICODE,0x000B
EmailAddress=PT_UNICODE,0x000C
POP3Server=PT_UNICODE,0x0100
POP3UserName=PT_UNICODE,0x0101
POP3UseSPA=PT_LONG,0x0108
Organization=PT_UNICODE,0x0107
ReplyEmailAddress=PT_UNICODE,0x0103
POP3Port=PT_LONG,0x0104
POP3UseSSL=PT_LONG,0x0105
SMTPServer=PT_UNICODE,0x0200
SMTPUseAuth=PT_LONG,0x0203
SMTPAuthMethod=PT_LONG,0x0208
SMTPUserName=PT_UNICODE,0x0204
SMTPUseSPA=PT_LONG,0x0207
ConnectionType=PT_LONG,0x000F
ConnectionOID=PT_UNICODE,0x0010
SMTPPort=PT_LONG,0x0201
SMTPSecureConnection=PT_LONG,0x020A
ServerTimeOut=PT_LONG,0x0209
LeaveOnServer=PT_LONG,0x1000

[IMAP_I_Mail]
AccountType=IMAP
AccountName=PT_UNICODE,0x0002
DisplayName=PT_UNICODE,0x000B
EmailAddress=PT_UNICODE,0x000C
IMAPServer=PT_UNICODE,0x0100
IMAPUserName=PT_UNICODE,0x0101
IMAPUseSPA=PT_LONG,0x0108
Organization=PT_UNICODE,0x0107
ReplyEmailAddress=PT_UNICODE,0x0103
IMAPPort=PT_LONG,0x0104
IMAPUseSSL=PT_LONG,0x0105
SMTPServer=PT_UNICODE,0x0200
SMTPUseAuth=PT_LONG,0x0203
SMTPAuthMethod=PT_LONG,0x0208
SMTPUserName=PT_UNICODE,0x0204
SMTPUseSPA=PT_LONG,0x0207
ConnectionType=PT_LONG,0x000F
ConnectionOID=PT_UNICODE,0x0010
SMTPPort=PT_LONG,0x0201
SMTPSecureConnection=PT_LONG,0x020A
ServerTimeOut=PT_LONG,0x0209
CheckNewImap=PT_LONG,0x1100
RootFolder=PT_UNICODE,0x1101
Account=PT_UNICODE,0x0002
HttpServer=PT_UNICODE,0x0100
UserName=PT_UNICODE,0x0101
Organization=PT_UNICODE,0x0107
UseSPA=PT_LONG,0x0108
TimeOut=PT_LONG,0x0209
Reply=PT_UNICODE,0x0103
EmailAddress=PT_UNICODE,0x000C
FullName=PT_UNICODE,0x000B
Connection Type=PT_LONG,0x000F
ConnectOID=PT_UNICODE,0x0010"
}
}

function asciiToHex($SourceString, $Nulls = 0)
{
    $SourceCharArray = $SourceString.ToCharArray();
    Foreach ($element in $SourceCharArray) 
    {
        if($Nulls -eq 0)
        {
            $ReturnString = $ReturnString + [System.String]::Format("{0:X}", [System.Convert]::ToUInt32($element)) + ','
        }
        else
        {
            $ReturnString = $ReturnString + [System.String]::Format("{0:X}", [System.Convert]::ToUInt32($element)) + ',00,'
        }
    }
    $ReturnString = $ReturnString.Substring(0,$ReturnString.Length -1)   
    $ReturnString
}

Function Outlook2016Temp()
{
	$AsciiHexWithoutNulls = asciiToHex -SourceString $Student
	$AsciiHexWithNulls = asciiToHex -SourceString $Student -Nulls 1

	$ContentRegFile=[IO.File]::ReadAllText("D:\Temp\OutlookProfile2016.reg")
	$ContentByLine=$ContentRegFile.Split("`n")
	$Content=""
	foreach($line in $ContentByLine)
	{      
		if(!($line -like "*HKEY_CURRENT_USER*"))
		{                
			$line=$line.Replace("\","")
			$line=$line.Replace("  ","")
		}
		$line=$line.Replace("`n","")
		if($line.Length -ne 0)
		{
			$line=$line.Substring(0,$line.Length -1)          
		}
		$Content+=$line  
	}
	$Content=$Content.Replace("53,00,74,00,75,00,64,00,65,00,6e,00,74,00,53,00,4b,00,31,00,30,00,2d,00,30,00,38,00", $AsciiHexWithNulls)
	$Content=$Content.Replace("53,00,54,00,55,00,44,00,45,00,4e,00,54,00,53,00,4b,00,31,00,30,00,2d,00,30,00,39,00", $AsciiHexWithNulls)
	$Content=$Content.Replace("53,00,54,00,55,00,44,00,45,00,4e,00,54,00,53,00,4b,00,31,00,30,00,2d,00,30,00,38,00", $AsciiHexWithNulls)
	$Content=$Content.Replace("73,00,74,00,75,00,64,00,65,00,6e,00,74,00,73,00,6b,00,31,00,30,00,2d,00,30,00,38,00", $AsciiHexWithNulls)
	$Content=$Content.Replace("53,74,75,64,65,6e,74,53,4b,31,30,2d,30,38", $AsciiHexWithoutNulls)
	$Content=$Content.Replace("73,74,75,64,65,6e,74,73,6b,31,30,2d,30,38", $AsciiHexWithoutNulls)
	$Content=$Content.Replace("STUDENTSK10-08", $Student)
	$ContentOutput=""
	$TempSplitters='[','"' 
	$TempDoEnter=1
	foreach($char in $Content.ToCharArray())
	{    
		if($TempDoEnter -eq 1 -and $TempSplitters -contains $char)
		{        
			if($char -eq '"')
			{
				$ContentOutput+="`r`n$char"
				$TempDoEnter = 0
			}
			else
			{
				$ContentOutput+="`r`n`r`n$char"
			}
		}
		else
		{
			if($char -eq '"')
			{
				$TempDoEnter = 1
			}
			$ContentOutput+=$char
		}
	}
	if(Test-Path "D:\Temp\OutlookProfile2016_Actual.reg")
	{
		Remove-Item "D:\Temp\OutlookProfile2016_Actual.reg" -Force
	}
	Add-Content "D:\Temp\OutlookProfile2016_Actual.reg" $ContentOutput
	regedit /s "D:\Temp\OutlookProfile2016_Actual.reg"
	& $OutPath 
	Start-Sleep -s 5
	[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
	$a = Get-Process | Where-Object {$_.Name -eq "Outlook"}
	[Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)		
	Start-Sleep -s 3
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")    
    [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
	[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
	Start-Sleep -s 3
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")    
    [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
	[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
	Start-Sleep -s 3
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")    
    [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
	[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")	
	Start-Sleep -s 3
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")    
    [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
	[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")	
	Start-Sleep -s 3	
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
    [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
	[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
	Start-Sleep -s 3
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")    
    [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
	[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
	Start-Sleep -s 3
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")    
    [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
	[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
	Start-Sleep -s 3	
	Stop-Process -name outlook
}


Function ConfigureOutlookProfile($Student,$Domain, $SourcePath, $LoginDomain="class.skola.cz")
{
	<#
	.SYNOPSIS
	Script na Nastavenie Outlookoveho profilu.
	
	.DESCRIPTION	
	Configure Outlook Profile for Office.
	Example: 
	ConfigureOutlookProfile "Student02" "sps.skola.cz" "C:\Windows\Temp\SHRP0110" "sps.skola.cz"
	 
	.EXAMPLE
	ConfigureOutlookProfile "Student02" "sps.skola.cz" "C:\Windows\Temp\SHRP0110" "sps.skola.cz"
	#>	
	$Login = $Student+"@"+$LoginDomain
	$DestPath = $Home
	CreatePRF1 $Login $Student $Domain $SourcePath

	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

	If (!($OutPath -eq $null)) {
		Remove-Variable OutPath -Force
	}
	If (Test-Path -path 'C:\Program Files (x86)\Microsoft Office\Office16\outlook.exe') {
		$OutPath = 'C:\Program Files (x86)\Microsoft Office\Office16\outlook.exe'
	}
	If (Test-Path -path 'C:\Program Files\Microsoft Office\Office16\outlook.exe') {
		$OutPath = 'C:\Program Files\Microsoft Office\Office16\outlook.exe'
	}	
	If (Test-Path -path 'C:\Program Files (x86)\Microsoft Office\Office15\outlook.exe') {
		$OutPath = 'C:\Program Files (x86)\Microsoft Office\Office15\outlook.exe'
	}
	If (Test-Path -path 'C:\Program Files\Microsoft Office\Office15\outlook.exe') {
		$OutPath = 'C:\Program Files\Microsoft Office\Office15\outlook.exe'
	}	
	If (Test-Path -path 'C:\Program Files (x86)\Microsoft Office\Office14\outlook.exe') {
		$OutPath = 'C:\Program Files (x86)\Microsoft Office\Office14\outlook.exe'
	}
	If (Test-Path -path 'C:\Program Files\Microsoft Office\Office14\outlook.exe') {
		$OutPath = 'C:\Program Files\Microsoft Office\Office14\outlook.exe'
	}
	If ($OutPath -eq $null) {
		Clear-Host
		Write-Host 'Nepovedlo se najit Outlook- pravdepodobne neni nainstalovan Office' -ForegroundColor Red
		Read-host
	}
	if($OutPath -like "*Office16*")
	{
		& $OutPath        
		Start-Sleep -s 10
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
		$a = Get-Process | Where-Object {$_.Name -eq "Outlook"}
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
		[Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)              
		Start-Sleep -s 5                
		[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")	    
	    [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("$Student")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("$Login")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("password")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("password")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
		Start-Sleep -s 5 
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait(" ")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")       
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
		Start-Sleep -s 5
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("password")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
		Start-Sleep -s 2                
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait(" ")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
		Start-Sleep -s 20       
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)                       
		[System.Windows.Forms.SendKeys]::SendWait("%{F4}")
		Start-Sleep -s 2
	}
	else
	{
		& $OutPath /importprf $Path'\PRFcomplete.prf'	
		Start-Sleep -s 40
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
		$a = Get-Process | Where-Object {$_.Name -eq "Outlook"}
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
		[Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		Start-Sleep -s 5	
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")	    
	    [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait(" ")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")	    
	    [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
		Start-Sleep -s 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")        
        [Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
		[System.Windows.Forms.SendKeys]::SendWait("%{F4}")
		Start-Sleep -s 2		
	}
}

Function ConfigureOutlookProfile2($Student,$Domain, $SourcePath, $LoginDomain="skola.cz")
{
	<#
	.SYNOPSIS
	Script na Nastavenie Outlookoveho profilu.
	
	.DESCRIPTION	
	Configure Outlook Profile for Office.
	Example: 
	ConfigureOutlookProfile "Student02" "sps.skola.cz" "C:\Windows\Temp\SHRP0110" "sps.skola.cz"
	 
	.EXAMPLE
	ConfigureOutlookProfile "Student02" "sps.skola.cz" "C:\Windows\Temp\SHRP0110" "sps.skola.cz"
	#>	
	
	$Login = $Student+"@"+$LoginDomain
	$DestPath = $Home
	CreatePRF1 $Domain $SourcePath
	CreatePRF2 $Domain $SourcePath
	If (!(Test-Path -Path $SourcePath\PRFpart1.txt)) {
		Clear-Host
		Write-Host 'Nemohu nalezt soubor' $SourcePath\PRFpart1.txt -ForegroundColor Red
		Read-Host
	}
	If (!(Test-Path -path $SourcePath\PRFpart2.txt)) {
		Clear-Host
		Write-Host 'Nemohu nalezt soubor' $SourcePath\PRFpart2.txt -ForegroundColor Red
		Read-Host
	}
	get-content $SourcePath\PRFpart1.txt | Out-File $DestPath\PRFcomplete.prf
	If (!(Test-Path -path $DestPath\PRFcomplete.prf)) {
		Clear-Host
		Write-Host 'Nemohu ukladat do adresare' $DestPath -ForegroundColor Red
		Read-Host
	}
	
	$PRFins1 = 'MailboxName='+$Login | Out-File $DestPath\PRFcomplete.prf -Append -NoClobber
	$PRFins2 = 'AccountName='+$Student | Out-File $DestPath\PRFcomplete.prf -Append -NoClobber
	$PRFins3 = '' | Out-File $DestPath\PRFcomplete.prf -Append -NoClobber
	$PRFins4 = '[Service1]' | Out-File $DestPath\PRFcomplete.prf -Append -NoClobber
	$PRFins5 = 'MailboxName='+$Login | Out-File $DestPath\PRFcomplete.prf -Append -NoClobber
	Get-Content $SourcePath\PRFpart2.txt | Out-File $DestPath\PRFcomplete.prf -Append -NoClobber

	If (!($OutPath -eq $null)) {
		Remove-Variable OutPath -Force
	}
	If (Test-Path -path 'C:\Program Files (x86)\Microsoft Office\Office15\outlook.exe') {
		$OutPath = 'C:\Program Files (x86)\Microsoft Office\Office15\outlook.exe'
	}
	If (Test-Path -path 'C:\Program Files\Microsoft Office\Office15\outlook.exe') {
		$OutPath = 'C:\Program Files\Microsoft Office\Office15\outlook.exe'
	}	
	If (Test-Path -path 'C:\Program Files (x86)\Microsoft Office\Office14\outlook.exe') {
		$OutPath = 'C:\Program Files (x86)\Microsoft Office\Office14\outlook.exe'
	}
	If (Test-Path -path 'C:\Program Files\Microsoft Office\Office14\outlook.exe') {
		$OutPath = 'C:\Program Files\Microsoft Office\Office14\outlook.exe'
	}
	If ($OutPath -eq $null) {
		Clear-Host
		Write-Host 'Nepovedlo se najit Outlook- pravdepodobne neni nainstalovan Office' -ForegroundColor Red
		Read-host
	}
	& $OutPath /importprf $DestPath'\PRFcomplete.prf'	
	Start-Sleep -s 40
	[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
	$a = Get-Process | Where-Object {$_.Name -eq "Outlook"}
	[Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
	Start-Sleep -s 5
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
	[Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
	[System.Windows.Forms.SendKeys]::SendWait('Pa$$w0rd')	
	Start-Sleep -s 2
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
	[Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
	[System.Windows.Forms.SendKeys]::SendWait("{TAB}")
	Start-Sleep -s 2
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")	
	[Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
	[System.Windows.Forms.SendKeys]::SendWait(" ")
	Start-Sleep -s 2	
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")	
	[Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
	[System.Windows.Forms.SendKeys]::SendWait("ENTER")
	Start-Sleep -s 10
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")	
	[Microsoft.VisualBasic.Interaction]::AppActivate($a.ID)
	[System.Windows.Forms.SendKeys]::SendWait("%{F4}")
	Start-Sleep -s 2
	#Get-Process outlook | Stop-Process
	
	Remove-Item $DestPath'\PRFcomplete.prf' -Force	
	Write-Host 'Konfigurace dokoncena uspesne' -ForegroundColor Green
}

Function Add-FirewallException($Path, $Description="")
{
	<#
	.SYNOPSIS
	Prida vynimku pre firewall.
	
	.DESCRIPTION	
	Add exception for firewall.
	Example: 
	Add-FirewallException "C:\WIndows\Temp\blabla.exe"
	 
	.EXAMPLE
	Add-FirewallException "C:\WIndows\Temp\blabla.exe"
	#>
	$rtn = netsh.exe advfirewall firewall add rule name=$Description dir=in action=allow description=$Description program=$Path enable=yes
	if($rtn) 
	{
		Write-Host -ForegroundColor Green "Nastavenie Firewall pre $Path."
	}	
}

Function Run($Path, $ArgList="")
{
	<#
	.SYNOPSIS
	Script na Spustenie instalacie alebo ineho suboru s argumentami.
	
	.DESCRIPTION	
	Start process with arguments.
	Example: 
	Run "C:\Install.exe" '/q /norestart'
	 
	.EXAMPLE
	Run "C:\Install.exe" '/q /norestart'
	#>
	Write-Host "Spustenie $Path..." -ForegroundColor Yellow -NoNewline
	if($ArgList -eq "")
	{
		Start-Process -FilePath $Path -Wait -Verb RunAs
	}
	else
	{
		Start-Process -FilePath $Path -ArgumentList $ArgList -Wait -Verb RunAs
	}	
	Write-Host -ForegroundColor Green "Success"
}

Function Set-Autologon($Setter, $UserName="", $Password='')
{
	<#
	.SYNOPSIS
	Script na nastavenie autologonu.
	
	.DESCRIPTION	
	Set autologon.
	Example: 
	Set-Autologon 0
	Set-Autologon 1 "StudentSK"
	Set-Autologon 1 "Student" 'Pa$$w0rd'
	 
	.EXAMPLE
	Set-Autologon 0
	Set-Autologon 1 "StudentSK"
	Set-Autologon 1 "Student" 'Pa$$w0rd'
	#>
	Write-Host "Setting Autologon $Setter $UserName $Password" -ForegroundColor Yellow
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value $Setter -Force >> $null	
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name ForceAutoLogon -Value $Setter -Force >> $null	
	if(!($UserName -eq ""))
	{		
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value $UserName -Force >> $null
	}
	if(!($Password -eq ''))
	{			
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value $Password -Force >> $null
	}	
}

Function Set-RunOncePS($Path, $Name="MultiScript")
{
	<#
	.SYNOPSIS
	Script na nastavenie RunOncu pre powershell.
	
	.DESCRIPTION	
	Set RunOnce for powershell.
	Example: 
	Set-RunOncePS "C:\DestinationFolder\Script.ps1"
	Set-RunOncePS "C:\DestinationFolder\Script.ps1" "Script"
	 
	.EXAMPLE
	Set-RunOncePS "C:\DestinationFolder\Script.ps1"
	Set-RunOncePS "C:\DestinationFolder\Script.ps1" "Script"
	#>	
	write-host "Setting RunOncePS $PSHOME\powershell.exe -Command `"& $Path`"" -ForegroundColor Yellow
	New-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Name $Name -Value "$PSHOME\powershell.exe -Command `"& $Path`"" >> $null
}

Function Set-RunPS($Path, $Name="MultiScript")
{
	<#
	.SYNOPSIS
	Script na nastavenie Run pre powershell.
	
	.DESCRIPTION	
	Set Run for powershell.
	Example: 
	Set-RunPS "C:\DestinationFolder\Script.ps1"
	Set-RunPS "C:\DestinationFolder\Script.ps1" "Script"
	 
	.EXAMPLE
	Set-RunPS "C:\DestinationFolder\Script.ps1"
	Set-RunPS "C:\DestinationFolder\Script.ps1" "Script"
	#>	
	write-host "Setting RunPS $PSHOME\powershell.exe -Command `"& $Path`"" -ForegroundColor Yellow
	New-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name $Name -Value "$PSHOME\powershell.exe -Command `"& $Path`"" >> $null
}

Function Set-Run($Path, $Name="MultiScript")
{
	<#
	.SYNOPSIS
	Script na nastavenie Run.
	
	.DESCRIPTION	
	Set Run.
	Example: 
	Set-Run "C:\DestinationFolder\Script.bat"
	Set-Run "C:\DestinationFolder\Script.bat" "Script"
	 
	.EXAMPLE
	Set-Run "C:\DestinationFolder\Script.bat"
	Set-RuS "C:\DestinationFolder\Script.bat" "Script"
	#>	
	write-host "Setting Run $Path" -ForegroundColor Yellow
	New-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name $Name -Value "$Path" >> $null
}

Function Set-RunOnce($Path, $Name="MultiScript")
{
	<#
	.SYNOPSIS
	Script na nastavenie RunOncu.
	
	.DESCRIPTION	
	Set RunOnce.
	Example: 
	Set-RunOnce "C:\DestinationFolder\Script.bat"
	Set-RunOnce "C:\DestinationFolder\Script.bat" "Script"
	 
	.EXAMPLE
	Set-RunOnce "C:\DestinationFolder\Script.bat"
	Set-RunOnce "C:\DestinationFolder\Script.bat" "Script"
	#>	
	write-host "Setting RunOnce $Path" -ForegroundColor Yellow
	New-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce -Name $Name -Value "$Path" >> $null
}

Function Extract($File, $Destination)
{	
		<#
	.SYNOPSIS
	Script na rozbalenie zip subora.
	
	.DESCRIPTION	
	Exctract zip file.
	Example: 
	Extract -File "C:\zipfile.zip" -Destination "C:\Temp\"
	 
	.EXAMPLE	
	Extract -File "C:\zipfile.zip" -Destination "C:\Temp\"
	#>
	$shell_app=new-object -com shell.application	
	$zip_file = $shell_app.namespace($File)
	$dest = $shell_app.namespace($Destination)			
	Write-Host "Start with extracting $File" -ForegroundColor Yellow  -NoNewline
	$dest.Copyhere($zip_file.items(), 0x14)
	Write-Host "Success" -ForegroundColor Green
}

Function Extract-ZIPFile($Path="", $File="", $Destination)
{
	<#
	.SYNOPSIS
	Script na rozbalenie zip suborov.
	
	.DESCRIPTION	
	Exctract zip files.
	Example: 
	Extract-ZIPFile -Path "C:\" -Destination "C:\Temp\"
	Extract-ZIPFile -File "C:\zipfile.zip" -Destination "C:\Temp\"
	 
	.EXAMPLE
	Extract-ZIPFile -Path "C:\" -Destination "C:\Temp\"
	Extract-ZIPFile -File "C:\zipfile.zip" -Destination "C:\Temp\"
	#>	
	Write-Host "Extract zip file $Path $File to $Destination" -ForegroundColor Yellow
	if(!($Path -eq ""))
	{
		$filelocation = dir $Path\*.zip
		foreach ($files in $filelocation)
		{
			$filename = $files.Name.ToString()
			$pom = $Path+'\'+$filename
			Extract -File $pom -Destination $Destination
		}
	}
	if(!($File -eq ""))
	{
		Extract -File $File -Destination $Destination
	}
}

Function Get-ComputerName()
{
	<#
	.SYNOPSIS
	Script zistenie nazvu pocitaca.
	
	.DESCRIPTION	
	Returns computer name.
	Example: 
	Get-ComputerName	
	 
	.EXAMPLE
	Get-ComputerName
	#>	
	return Get-WmiObject Win32_ComputerSystem
}

Function Create-CredentialPerson($UserName, $Password)
{
	<#
	.SYNOPSIS
	Script na vytvorenie osoby s opravneniami.
	
	.DESCRIPTION	
	Returns person with credential.
	Example: 
	Create-CredentialPerson	"class\technik" "password"
	 
	.EXAMPLE
	Create-CredentialPerson	"class\technik" "password"
	#>	
	Write-Host "Creating Credential Person $UserName $Password" -ForegroundColor Yellow
	$secstr = New-Object -TypeName System.Security.SecureString
	$Password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
	$cred = New-Object -TypeName System.Management.Automation.PSCredential `
			 -ArgumentList $UserName,  $secstr
	return $cred
}

Function To-WorkGroup($CredentialPerson)
{
	<#
	.SYNOPSIS
	Script na pridanie pocitaca do workgroupy.
	
	.DESCRIPTION	
	Add computer to workgroup.
	Example: 
	$Cred = Create-CredentialPerson "class\technik" "password" 
	To-WrokGroup $Cred
	
	.EXAMPLE
	$Cred = Create-CredentialPerson "class\technik" "password" 
	To-WrokGroup $Cred 
	#>
	Write-Host "Adding computer to WorkGroup" -ForegroundColor Yellow
	$dr = gwmi -Class win32_computersystem | select -ExpandProperty domainrole
	switch ($dr) 
	{
		3 {Remove-Computer -Credential $CredentialPerson -Force} 
		4 {Remove-Computer -Credential $CredentialPerson -Force}  
		5 {Remove-Computer -Credential $CredentialPerson -Force} 
		default {Write-Host -ForegroundColor Green "WorkGroup"} 
	}
}

Function RenamePC($PCName)
{
	<#
	.SYNOPSIS
	Script na premenovanie pocitaca.
	
	.DESCRIPTION	
	Rename computer name.
	Example: 
	RenamePC "StudentSK8"
	
	.EXAMPLE
	RenamePC "StudentSK8"
	#>
	
	$ComputerName = Get-WmiObject Win32_ComputerSystem
	Write-Host "Rename Computer $ComputerName to $PCName" -ForegroundColor Yellow -NoNewline
	$ComputerName.Rename($PCName)
	Write-Host "Success" -ForegroundColor Green
}

Function Get-WindowsVersion
{
    return $Global:OSCaption
}

Function Get-WindowsArchitecture
{
    return $Global:OSArchitecture
}

Function Get-OSAbrivation()
{
	<#
	.SYNOPSIS
	Script na zistenie skratky Operacneho systemu.
	
	.DESCRIPTION	
	Get abrivation of operating system.
	Example: 
	$OS = Get-OSAbrivation
	
	.EXAMPLE
	$OS = Get-OSAbrivation
	#>
	$Windows_version= Get-WindowsVersion
	$Bit_version= Get-WindowsArchitecture	
	switch -wildcard ($Windows_version) 
	{ 
		"*2012*" {$OS="w2k12_r2"}
		"*2016*" {$OS="w2k16"}
		"*2008 R2*" {$OS="w2k8_r2"}
		"*Windows 7*" 
		{
			if ($Bit_version -like "*64*") 
			{
				$OS="w7_x64"
			}
			else 
			{
				$OS="w7_x86"
			}
		}
		"*Windows 10*" 
		{
			if ($Bit_version -like "*64*") 
			{
				$OS="w10_x64"
			}
			else 
			{
				$OS="w10_x86"
			}
		}
		"*2008 Enterprise*" 
		{
			if ($Bit_version -like "*64*") 
			{
				$OS="w7_x64"
			}
			else 
			{
				$OS="w7_x86"
			}
		}
		"*Windows 8*" 
		{
			if ($Bit_version -like "*64*") 
			{
				$OS="w8.1_x64"
			}
			else 
			{
				$OS="w8.1_x86"
			}
		}	
	}
	return $OS
}

Function DirsEquals($DirName1, $DirName2)
{
	<#
	.SYNOPSIS
	Script, ktory porovna velkosti dvoch priecinkov.
	
	.DESCRIPTION	
	Equality of two folders.
	Example: 
	$Boolean = DirsEquals "C:\windows\temp\Drivers" " C:\Windows\Temp\Drivers2"
	
	.EXAMPLE
	$Boolean = DirsEquals "C:\windows\temp\Drivers" " C:\Windows\Temp\Drivers2"
	#>
	Write-Host "Compare directories $DirName1 and $DirName2" -ForegroundColor Yellow
    $SizeDir1 = Get-ChildItem $DirName1 -Recurse | Measure-Object -Property Length -Sum
    $SizeDir2 = Get-ChildItem $DirName2 -Recurse | Measure-Object -Property Length -Sum
    return $SizeDir1.Sum -eq $SizeDir2.Sum
}

Function DeleteLogs 
{	
	<#	
	.SYNOPSIS
	Zmaze logy na blavaimage.
	
	.DESCRIPTION	
	Delete to logs on blavaimage.
	Example: 
	DeleteLogs
	
	.EXAMPLE	
	DeleteLogs
	#>	
	$PCName = Get-ComputerName
	$Path = "\\blavaimage\LOGS\"+$PCName.name+".txt"
	if(Test-Path $Path)
	{
		write-host "Cleaning Logs ..." -ForegroundColor $Global:UserInputColor -BackgroundColor $Global:bgColor
		Remove-Item $Path >> $null
		Write-Host "Cleaning Logs: DONE" -ForegroundColor Green
	}
}

Function WriteToLogs($Log) 
{
	<#	
	.SYNOPSIS
	Zapise udalost do Logov na blavaimage.
	
	.DESCRIPTION	
	Write to logs on blavaimage.
	Example: 
	WriteToLogs "Failed on bla bla"
	
	.EXAMPLE	
	WriteToLogs "Failed on bla bla"
	#>	
	$PCName = Get-ComputerName
	$A = Get-Date
	$OS = Get-OSAbrivation
	$Log = "`n$A $OS "+$Log
	$Path = "\\blavaimage\LOGS\"+$PCName.name+".txt"
    Add-Content $Path $Log >> $null   
}

Function Get-Signature($pathOfFile)
{
	<#	
	.SYNOPSIS
	Zisti ci je podpisany ovladac.
	
	.DESCRIPTION	
	Check driver signature.
	Example: 
	Get-Signature "C:\Windows\Drivers\Net\oem56.inf"
	
	.EXAMPLE	
	Get-Signature "C:\Windows\Drivers\Net\oem56.inf"
	#>
	$FileName = Split-Path $pathOfFile -leaf -resolve
	Write-Host "Gettings Singature of $FileName driver" -ForegroundColor Yellow
    if(Test-Path $pathOfFile)
    {
        $CatalogFileName = ""
        $lines = Get-Content $pathOfFile         
        foreach($line in $lines)
        {
            if($line.Contains("CatalogFile"))
            {
                $CatalogFileName = $line.Split('=')[1].Replace(" ","")                
                break
            }
        }        
        if($CatalogFileName -eq "")
        {
            return $true
        }
        else
        {
            $Path = Split-Path $pathOfFile
            $CatalogFileName = $Path+"\"+$CatalogFileName            
            if(Test-Path $CatalogFileName)
            {
				$ErrorActionPreference = "SilentlyContinue"
				if(Test-Path "D:\SignTool.exe")
				{
					$Object = & "D:\SignTool.exe" verify -kp -c $CatalogFileName $pathOfFile 2>null
				}
				else
				{
					$Object = & "$Temp\SignTool.exe" verify -kp -c $CatalogFileName $pathOfFile 2>null
				}
                foreach($o in $Object)
                {
                    if($o.Contains("Successfully verified"))
                    {
                       return $true
                    }                
                }    
                return $false            
            }
            else
            {
                return $true
            }
        }
   }    
   return $false
}

Function AddDrivers($Driverpath)
{
	<#
	.SYNOPSIS
	Script na pridanie ovladacov z priecinka, s pomocnymi vypismi.
	
	.DESCRIPTION	
	Add drivers from path with error messages.
	Example: 
	AddDrivers "D:\Drivers"
	
	.EXAMPLE
	AddDrivers "D:\Drivers"
	#>
	
	$SetupFiles = Get-ChildItem $Driverpath -Recurse -Filter setup.bat
	$MaxCount = $SetupFiles.Count
	$ProgressCount = 0
	$Activity = "Starting setup which will add drivers"
	foreach($file in $SetupFiles)
	{	
			Kill-Process "rundll32"
			Kill-Process "rundll32"
			Kill-Process "rundll32"	
			$proc = Start-Process 'C:\windows\System32\WindowsPowershell\v1.0\powershell.exe' -ArgumentList 'D:\Controller.ps1' -Passthru -WindowStyle Minimized
			write-host "Starting $($File.FullName)" -foregroundcolor green
			Start-Process $File.FullName -wait
			Stop-Process $proc.ID
	}
	
    $InfFiles =  Get-ChildItem $Driverpath -Recurse | Where { $_ -like "*.inf" }
    $MaxCount = $InfFiles.Count
    $ProgressCount = 0
    $Activity = "Adding Drivers"	
    foreach($file in $InfFiles)
    {
		Write-Progress -Activity $Activity -Status $file.fullname -PercentComplete ($ProgressCount / $MaxCount*100)
        $ProgressCount += 1
        $ProcInf = ""
        $PubInf = ""
        $except = ""
		if($file.FullName -like "*Nepodpisane*")
		{
			#write-host "Skip Unsigned driver: $file" -ForeGround Yellow
		}
		else
		{	
			Kill-Process "rundll32"
			Kill-Process "rundll32"
			Kill-Process "rundll32"	
			$proc = Start-Process 'C:\windows\System32\WindowsPowershell\v1.0\powershell.exe' -ArgumentList 'D:\Controller.ps1' -Passthru -WindowStyle Minimized
			$Objects = PnPutil.exe -i -a $file.fullname
			foreach($Object in $Objects)
			{
				if($Object -like "Processing inf :*" -or $Object -like "ZpracovßnÝ informacÝ:*")
				{
					$Split = $Object.split(':')                
					$ProcInf = $Split[1].Replace(' ','')  
				}
				elseif($Object -like "Published name : *" -or $Object -like "PublikovanÚ jmÚno:*")
				{
					$Split = $Object.split(':')                
					$PubInf = $Split[1].Replace(' ','') 
				}					
				elseif($Object -like "*Failed*" -or $Object -like "*failed*" -or $Object -like "*nezda°ilo*" -or $Object -like "*nezda°ila:*")
				{
					$Split = $Object.split(':')                
					$except = $Split[1]
				}
				elseif($Object -like "Successfully *" -or $Object -like "*successfully.*" -or $Object -like "*nainstalovßn.")
				{
					$except = "DONE"
				}
			}
			Stop-Process $proc.ID
			if($except -eq "DONE")
			{
				Write-Host "$file $ProcInf $PubInf : $except" -ForegroundColor Green    
				Add-Content $Temp\Logs_Drivers_OK.txt "$file $ProcInf $PubInf : $except" >> $null
				#WriteToLogs "OK: $file $ProcInf $PubInf : $except"
			}
			else
			{
				Write-Host "$file $ProcInf $PubInf : $except" -ForegroundColor Yellow 
				Add-Content $Temp\Logs_Drivers_Fail.txt "$file $ProcInf $PubInf : $except" >> $null
				#WriteToLogs "FAIL: $file $ProcInf $PubInf : $except"
			}                			          
		}
    }
}

Function Get-MotherboardID
{
	<#
	.SYNOPSIS
	Script na detekovanie maticnej dosky.
	
	.DESCRIPTION
	Detect motherboard ID.
	Example: 
	$Motherboard = Get-MotherboardID
	
	.EXAMPLE
	$Motherboard = Get-MotherboardID
	#>
	Write-Host "Getting Motherboard ID" -ForegroundColor Yellow
	$name = (Get-Item env:\Computername).Value
	$info = Get-WmiObject -ComputerName $name  Win32_BaseBoard  |  Select Product
	return $info.Product
}

function Export-WLAN 
{ 
	<#
	.SYNOPSIS
	Exportne XML subory, kde su ulozene nastavenia o pripojeniach WLAN.
	
	.DESCRIPTION	
	Export WLAN profiles.
	Example: 
	Export-WLAN 
	
	.EXAMPLE
	Export-WLAN 
	#>
	Write-Host "Exporting WLAN profile" -ForegroundColor Yellow
	netsh.exe wlan export profile
} 
 
function Import-WLAN 
{ 
	<# 
	.SYNOPSIS 
	Imports all-user WLAN profiles based on Xml-files in the specified directory 
	.DESCRIPTION 
	Imports all-user WLAN profiles based on Xml-files in the specified directory using netsh.exe 
	.PARAMETER XmlDirectory 
	Directory to import Xml configuration-files from 
	.EXAMPLE 
	Import-WLAN -XmlDirectory c:\temp\wlan 
	#> 
[CmdletBinding()] 
    param ( 
        [parameter(Mandatory=$true)] 
        [string]$XmlDirectory 
        ) 
	Write-Host "Importing WLAN profiles" -ForegroundColor Yellow
	Get-ChildItem $XmlDirectory | Where-Object {$_.extension -eq ".xml"} | ForEach-Object {netsh wlan add profile filename=($XmlDirectory+"\"+$_.name)} 
}

Function Get-ScriptName 
{
	<#
	.SYNOPSIS
	Zisti cestu spusteneho scriptu aj s nazvom scriptu. Pozor MOZE BYT ZRADNE AK SA JEDNA O NAZOV Functions.ps1 !!!
	
	.DESCRIPTION	
	Get Script full path.
	Example: 
	$ScriptName = Get-ScriptName
	
	.EXAMPLE
	$ScriptName = Get-ScriptName
	#>
	Write-Host "Getting Script Name" -ForegroundColor Yellow
	return $MyInvocation.ScriptName
}

Function Install-Designer2013($PathInstallation)
{
	<#
	.SYNOPSIS
	Nainstaluje Designer 2013, ak existuje k nemu cesta.
	
	.DESCRIPTION	
	Install Designer 2013.
	Example: 
	Install-Designer2013
	
	.EXAMPLE
	Install-Designer2013
	#>
	if(Test-Path $PathInstallation)
	{		
		Write-Host "Installing Designer 2013" -ForegroundColor Yellow
		$ArgList = "/adminfile Updates\Custom.msp"
		Run $PathInstallation $ArgList
	}
	else
	{
		Write-Host "Instalation of Designer 2013 is not found." -ForegroundColor Yellow 
	}
}

Function Install-Framework($PathInstallation)
{
	<#
	.SYNOPSIS
	Nainstaluje .net FrameWork, ak existuje k nemu cesta.
	
	.DESCRIPTION	
	Install .net FrameWork
	Example: 
	Install-Framework
	
	.EXAMPLE
	Install-Framework
	#>	
	if(Test-Path $PathInstallation)
	{	
		Write-Host "Installing .net FrameWork $PathInstallation" -ForegroundColor Yellow
		Add-FirewallException "C:\Windows\microsoft.net\framework\v2.0.50727\vbc.exe" "Rule vbcmd"
		$ArgList = "/q /norestart"
		Run $PathInstallation $ArgList
	}
	else
	{
		Write-Host "Instalation of .net Framework is not found." -ForegroundColor Yellow 
	}	
}

Function Finish-Settings-NO_SHUTDOWN
{		
	<#
	.SYNOPSIS
	Nastavi autologon a runonce, ak je potreba a doinstaluje potrebne veci k sharepointom(outlookom).
	
	.DESCRIPTION	
	Set autologon and tunonce, if it's necessary ... Install necessaty things for sharepoint.
	Example: 
	Finish-Settings
	
	.EXAMPLE
	Finish-Settings
	#>
	if($env:ComputerName -like "LEKTOR*" -and !(Test-Path "D:\temp\SetDisplayDuplicate.txt"))
	{
        Start-Sleep 5
        SetDisplayDuplicate
        Start-Sleep 5
        New-Item -Path D:\temp\SetDisplayDuplicate.txt -ItemType "file" -Value "DONE"
        Start-Sleep 5
    }
	if($env:username -eq "StudentEN")
	{	
		Set-Autologon 1 "StudentCZ"  
		Set-RunOncePS "$ScriptName"
		Write-Host -ForegroundColor Green "Nastavenie Autologonu na StudentCZ"
		Start-Sleep -s 5
		Restart-Computer
	}
	elseif($env:username -eq "StudentCZ")
	{
		Set-Autologon 1 "StudentSK"  
		Set-RunOncePS "$ScriptName"
		Write-Host -ForegroundColor Green "Nastavenie Autologonu na StudentSK"
		Start-Sleep -s 5
		Restart-Computer	
	}
	else
	{		
		Set-Autologon 0
		Write-Host -ForegroundColor Green "Dokoncenie Scriptov a vypnutie PC."
		Start-Sleep -s 5
		Restart-Computer
	}
}

Function Finish-Settings
{		
	<#
	.SYNOPSIS
	Nastavi autologon a runonce, ak je potreba a doinstaluje potrebne veci k sharepointom(outlookom).
	
	.DESCRIPTION	
	Set autologon and tunonce, if it's necessary ... Install necessaty things for sharepoint.
	Example: 
	Finish-Settings
	
	.EXAMPLE
	Finish-Settings
	#>
	if($env:ComputerName -like "LEKTOR*" -and !(Test-Path "D:\temp\SetDisplayDuplicate.txt"))
	{
        Start-Sleep 5
        SetDisplayDuplicate
        Start-Sleep 5
        New-Item -Path D:\temp\SetDisplayDuplicate.txt -ItemType "file" -Value "DONE"
        Start-Sleep 5
    }
	if($env:username -eq "StudentEN")
	{	
		Set-Autologon 1 "StudentCZ"  
		Set-RunOncePS "$ScriptName"
		Write-Host -ForegroundColor Green "Nastavenie Autologonu na StudentCZ"
		Start-Sleep -s 5
		Restart-Computer
	}
	elseif($env:username -eq "StudentCZ")
	{
		Set-Autologon 1 "StudentSK"  
		Set-RunOncePS "$ScriptName"
		Write-Host -ForegroundColor Green "Nastavenie Autologonu na StudentSK"
		Start-Sleep -s 5
		Restart-Computer	
	}
	else
	{
        $PathInstallation = $Path+'\dotNet.exe'
		Install-Framework $PathInstallation
        $PathInstallation = $Path+'\Designer\setup.exe'	
		Install-Designer2013 $PathInstallation
		
		Set-Autologon 0
		Write-Host -ForegroundColor Green "Dokoncenie Scriptov a vypnutie PC."
		Start-Sleep -s 5
		Stop-Computer
	}
}

Function Set-ControlPanelViewToLargeIcons
{
	<#
	.SYNOPSIS
	Script na zmenenie zobrazenie ikoniek v ovladacom panely.
	
	.DESCRIPTION	
	Change Control Panel view Icons to Large.
	Example: 
	Set-ControlPanelViewToLargeIcons
	
	.EXAMPLE
	Set-ControlPanelViewToLargeIcons
	#>   
    if((Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name AllItemsIconView).AllItemsIconView -eq 2)
    {
        Write-Host "Control Panel View already set to `"Large Icons`"." -ForegroundColor Yellow
    } 
    else
    {        
		Write-Host "Changing Control Panel View to Large" -ForegroundColor Yellow
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name AllItemsIconView -Value 2        
        if((Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name AllItemsIconView).AllItemsIconView -eq 2)
        {
            Write-Host "Control Panel View has been updated to `"Large Icons`"." -ForegroundColor Green
        }
        else
        {
            Write-Host "Control Panel View was not set to `"Large Icons`". Cancelling processing." -ForegroundColor Yellow
        }
    }
	regedit.exe /s "$Temp\Custom_OS\Force_Control_Panel_Icons_View.reg"
}

Function Copy_Icons($Name)
{
	<#
	.SYNOPSIS
	Script na zmazanie starych ikoniek a vytvorenie novych, potom nastavi zdielanie dokumentov.
	
	.DESCRIPTION	
	Erase old icons and create new, than set documents share.
	Example: 
	Copy_Icons "Student"
	
	.EXAMPLE
	Copy_Icons "Student"
	#>
	if(Test-Path "C:\Users\$Name\Desktop\")
	{
		Remove-Item -Path "C:\Users\$Name\Desktop\*" -Filter "*Install.url"
		Copy-With-ProgressBar "$Temp\Links\" "C:\Users\$Name\Desktop\"
		$Garbage = & net share Documents=C:\Users\$Name\Documents '/grant:everyone,full' '/Unlimited' | Out-Null
	}
}

Function GetNumber_ClassRoom ()
{	
	<#
	.SYNOPSIS
	Zisti cislo ucebne podla Workgroupy.
	
	.DESCRIPTION	
	Get number of classroom from Workgroup.
	Example: 
	$Number = GetNumber_ClassRoom
	
	.EXAMPLE
	$Number = GetNumber_ClassRoom
	#>
	Write-Host "Getting Number of Classroom" -ForegroundColor Yellow
	$Domain = (Get-WmiObject Win32_ComputerSystem).domain	
	$Domain = $Domain.ToUpper()
	return $Domain.TrimStart("UCEBNASK")
}

Function SetTabs($ClassRoom)
{
	<#
	.SYNOPSIS
	Nastavi tabulky pre total commander.
	
	.DESCRIPTION	
	Set total commander tabs.
	Example: 
	$N = GetNumber_ClassRoom
	SetTabs $N
	
	.EXAMPLE
	$N = GetNumber_ClassRoom
	SetTabs $N
	#>
	Write-Host "Setting Tabs for Total Commander Ucebna $ClassRoom" -ForegroundColor Yellow
    $ErrorActionPreference  = "Stop"
	[int[]] $NumberOfPCS = 8,12,8,8,4,8,8,8,12,8,8,8,0,12
	$MaxNumber = $NumberOfPCS[[int]$ClassRoom-1]
	$WinCMDDir = $env:APPDATA
	$WinCMDDir = $WinCMDDir+"\Ghisler\wincmd.ini"
	if(Test-Path $WinCMDDir)
    {
        Remove-Item $WinCMDDir
    }
    Add-Content $WinCMDDir "`n[Configuration]"	
    Add-Content $WinCMDDir "`nInstallDir=C:\totalcmd"
    Add-Content $WinCMDDir "`nLanguageini=wcmd_sk.lng"
    Add-Content $WinCMDDir "`nMainmenu=wcmd_sk.mnu"
	Add-Content $WinCMDDir "`nUseNewDefFont=0"
    Add-Content $WinCMDDir "`nfirstmnu=2618"
    Add-Content $WinCMDDir "`nFirstTime=0"
    Add-Content $WinCMDDir "`ntest=253"
    Add-Content $WinCMDDir "`nSeparateTree=0"
    Add-Content $WinCMDDir "`nPanelsVertical=0"
    Add-Content $WinCMDDir "`nDirTabOptions=825"
    Add-Content $WinCMDDir "`nDirTabLimit=32"
    Add-Content $WinCMDDir "`nTabDir=D:\"
    Add-Content $WinCMDDir "`n"
    Add-Content $WinCMDDir "`n[left]"
    Add-Content $WinCMDDir "`npath=c:\"
    Add-Content $WinCMDDir "`nShowAllDetails=1"
    Add-Content $WinCMDDir "`nSpecialView=0"
    Add-Content $WinCMDDir "`nshow=1"
    Add-Content $WinCMDDir "`nsortorder=0"
    Add-Content $WinCMDDir "`nnegative Sortorder=0"
    Add-Content $WinCMDDir "`n[right]"
    Add-Content $WinCMDDir "`npath=c:\"
    Add-Content $WinCMDDir "`nShowAllDetails=1"
    Add-Content $WinCMDDir "`nSpecialView=0"
    Add-Content $WinCMDDir "`nshow=1"
    Add-Content $WinCMDDir "`nsortorder=0"
    Add-Content $WinCMDDir "`nnegative Sortorder=0"
    Add-Content $WinCMDDir "`n[RightHistory]"
    Add-Content $WinCMDDir "`n0=c:\"
    Add-Content $WinCMDDir "`n[LeftHistory]"
    Add-Content $WinCMDDir "`n0=c:\"
    Add-Content $WinCMDDir "`n[lefttabs]"
    
	$Temp1 = "_path=\\studentsk$ClassRoom-"
	$Temp2 = "_caption=$ClassRoom-"
	$Temp3 = "_options=1|0|0|0|0|2|0"
	$Temp11 = "" 
	$Temp22 = ""
	$Temp33 = ""
	$j = 0
	for ($i=1; $i -le $MaxNumber; $i++)
	{
		if($i -lt 10)
		{
			$Temp11 = "$j"+"$Temp1"+"0"+"$i"+"\c$"
			$Temp22 = "$j"+"$Temp2"+"0"+"$i"			
		}
		else
		{
			$Temp11 = "$j"+"$Temp1"+"$i"+"\c$"
			$Temp22 = "$j"+"$Temp2"+"$i"			
		}
		$Temp33 = "$j"+"$Temp3"
		Add-Content $WinCMDDir "`n$Temp11"
		Add-Content $WinCMDDir "`n$Temp22"
		Add-Content $WinCMDDir "`n$Temp33"
        $j++
	}
    Add-Content $WinCMDDir "`nactivetab=0"
    Write-Host "Vytvorene nastavenia pre Total Commander" -ForeGroundColor Green
}

Function WriteToTab($ClassRoom)
{
	<#
	.SYNOPSIS
	Vytvori tabulky pre total commander.
	
	.DESCRIPTION	
	Create total commander tabs.
	Example: 
	$N = GetNumber_ClassRoom
	WriteToTab $N
	
	.EXAMPLE
	$N = GetNumber_ClassRoom
	WriteToTab $N
	#>	
	[int[]] $NumberOfPCS = 8,12,8,8,8,8,0,12,8,8,8,0,12
	$MaxNumber = $NumberOfPCS[[int]$ClassRoom-1]
	
	$stream = [System.IO.StreamWriter] "D:\Ucebna.tab"
	
	$stream.WriteLine("[activetabs]")
	$stream.WriteLine("0_path=c:\")
	$stream.WriteLine("0_options=1|0|0|0|0|0|0")
	
	$Temp1 = "_path=\\student$ClassRoom-"
	$Temp2 = "_caption=$ClassRoom-"
	$Temp3 = "_options=1|0|0|0|0|2|0"
	$Temp11 = "" 
	$Temp22 = ""
	$Temp33 = ""
	
	for ($i=1; $i -le $MaxNumber; $i++)
	{
		if($i -lt 10)
		{
			$Temp11 = "$i"+"$Temp1"+"0"+"$i"+"\c$"
			$Temp22 = "$i"+"$Temp2"+"0"+"$i"			
		}
		else
		{
			$Temp11 = "$i"+"$Temp1"+"$i"+"\c$"
			$Temp22 = "$i"+"$Temp2"+"$i"			
		}
		$Temp33 = "$i"+"$Temp3"
		$stream.WriteLine("$Temp11")
		$stream.WriteLine("$Temp22")
		$stream.WriteLine("$Temp33")
	}

	$stream.WriteLine("activetab=0")
	$stream.close()
}

Function GhostClient-Off
{
	<#	
	.SYNOPSIS
	Vypne ghost clienta a nastavi ho na Automatic, tzn ze po restarte sa zapne.
	
	.DESCRIPTION	
	Turn off Ghost Client and set it for Automatic, after restart will be on.
	Example: 
	GhostClient-Off
	
	.EXAMPLE
	GhostClient-Off
	#>	
	Write-Host "Detecting GHOST service..." -ForegroundColor $Global:UserInputColor -BackgroundColor $Global:bgColor
	$GHOST=(Get-Service | where {$_.name -eq "NGCLIENT"}).Name
	if ($GHOST -like "NGCLIENT") 
	{
		Write-Host "GHOST service detected..." -ForegroundColor Green
		Write-Host "Stopping GHOST service..." -ForegroundColor Yellow -NoNewline
		Set-Service NGCLIENT -startuptype "Automatic"
		Stop-Service NGCLIENT
        Write-Host "Success" -ForegroundColor Green
	} 
	else 
	{
		Write-Host "GHOST service not detected..." -ForegroundColor Yellow
	}
}

Function GhostControlService-Off
{
	<#	
	.SYNOPSIS
	Vypne ghost controll servicu a nastavi ju na Automatic, tzn ze po restarte sa zapne.
	
	.DESCRIPTION	
	Turn off Ghost controll service and set it for Automatic, after restart will be on.
	Example: 
	GhostClient-Off
	
	.EXAMPLE
	GhostClient-Off
	#>	
	Write-Host "Detecting GhostClientControll service..." -ForegroundColor $Global:UserInputColor -BackgroundColor $Global:bgColor
	$GHOST=(Get-Service | where {$_.name -eq "GhostClientControll"}).Name
	if ($GHOST -like "GhostClientControll") 
	{
		Write-Host "GhostClientControll service detected..." -ForegroundColor Green
		Write-Host "Stopping GhostClientControll service..." -ForegroundColor Yellow -NoNewline
		Set-Service GhostClientControll -startuptype "Automatic"
		Stop-Service GhostClientControll
        Write-Host "Success" -ForegroundColor Green
	} 
	else 
	{
		Write-Host "GhostClientControll service not detected..." -ForegroundColor Yellow
	}
}

Function MouseClick($dx, $dy)
{
	Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;		
	[W.U32]::mouse_event(6,$dx,$dy,0,0);
}

Function RepairACandExplorer
{
	Write-Host "Repairing Action Center and starting Explorer..." -ForegroundColor Yellow -NoNewline	
	Kill-Process Explorer
	Kill-Process Explorer
	Kill-Process Explorer
	RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters, 1, true	
	Start-Process explorer.exe	
	Start-Sleep -Seconds 10
	[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
	[Microsoft.VisualBasic.Interaction]::AppActivate("explorer.exe")
	[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")		
	[System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
	Start-Sleep -Seconds 2	
	[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
	[Microsoft.VisualBasic.Interaction]::AppActivate("explorer.exe")
	[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")		
	[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
	Start-Sleep -Seconds 2	
	[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
	[Microsoft.VisualBasic.Interaction]::AppActivate("explorer.exe")
	[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")		
	[System.Windows.Forms.SendKeys]::SendWait("{ESC}")
	Start-Sleep -Seconds 2	
	MouseClick(0,0)	
	Write-Host "Success" -ForegroundColor Green
}

Function Set-WOL
{
	<#	
	.SYNOPSIS
	Nastavi Wake On Lan.
	
	.DESCRIPTION	
	Set Wake On Lan.
	Example: 
	Set-WOL
	
	.EXAMPLE
	Set-WOL
	#>	
	Write-Host "Setting registry for WOL" -ForegroundColor $Global:UserInputColor -BackgroundColor $Global:bgColor
	$GroupPolicePath = "C:\Windows\System32\GroupPolicy\Machine\Scripts\"
	if(!(Test-Path $GroupPolicePath))	
	{
		New-Item -ItemType directory -Path $GroupPolicePath
	}	
    regedit.exe /s "$Temp\WOL.reg"
    Copy-Item "$Temp\scripts.ini"  $GroupPolicePath -Force
    Copy-Item "$Temp\psscripts.ini"  $GroupPolicePath -Force
	
	. D:\Temp\WOL.ps1
	
	$PathFile = "$Temp\Check\WOL.ps1"
	if(!(Test-Path $PathFile))
	{			
		Start-Sleep -Seconds 2
		gpedit.msc
		Start-Sleep -Seconds 5		
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
		[Microsoft.VisualBasic.Interaction]::AppActivate("gpedit.msc")
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")		
		[System.Windows.Forms.SendKeys]::SendWait("{RIGHT}")
		Start-Sleep -Seconds 2		
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
		[Microsoft.VisualBasic.Interaction]::AppActivate("gpedit.msc")
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
		[System.Windows.Forms.SendKeys]::SendWait("{RIGHT}")
		Start-Sleep -Seconds 2
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
		[Microsoft.VisualBasic.Interaction]::AppActivate("gpedit.msc")
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
		[System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
		Start-Sleep -Seconds 2
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
		[Microsoft.VisualBasic.Interaction]::AppActivate("gpedit.msc")
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
		[System.Windows.Forms.SendKeys]::SendWait("{RIGHT}")
		Start-Sleep -Seconds 2
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
		[Microsoft.VisualBasic.Interaction]::AppActivate("gpedit.msc")
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
		[System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
		Start-Sleep -Seconds 2
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
		[Microsoft.VisualBasic.Interaction]::AppActivate("gpedit.msc")
		[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
		[System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
		Start-Sleep -Seconds 2
		Stop-Process -processname mmc	
		$TempContent = "ON"
		Add-Content $PathFile $TempContent	
	}
	Write-Host "Done" -ForegroundColor $Global:OnScreenMsgColor
}

Function EmptyTrash
{
	<#	
	.SYNOPSIS
	Vyprazdni kos.
	
	.DESCRIPTION	
	Empty Recycle Bin.
	Example: 
	EmptyTrash
	
	.EXAMPLE
	EmptyTrash
	#>	
	Write-Host "Emptying Recycle Bin" -ForegroundColor Yellow
	$Shell = New-Object -ComObject Shell.Application 
	$RecBin = $Shell.Namespace(0xA) 
	$RecBin.Items() | %{Remove-Item $_.Path -Recurse -Confirm:$false}
}

Function ChangeNetworkLocation
{
	<#	
	.SYNOPSIS
	Nastavi sietove umiestnenie na pracovnu siet.
	
	.DESCRIPTION	
	Set Network Location to Private network.
	Example: 
	ChangeNetworkLocation
	
	.EXAMPLE
	ChangeNetworkLocation
	#>	
	$INDomain = 1,3,4,5 -contains (Get-WmiObject win32_computersystem).DomainRole
	$WorkNetwork = 1 
	
	Write-Host "Set network location" -ForegroundColor $Global:UserInputColor -BackgroundColor $Global:bgColor
	Write-Host "Changing Network Location to Private Network" -ForegroundColor Yellow  -NoNewline
	if($INDomain -eq "true") { return } 

	$networkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}")) 
	$connections = $networkListManager.GetNetworkConnections() 

	$connections | % {$_.GetNetwork().SetCategory($WorkNetwork)}
	Write-Host "Success" -ForegroundColor Green
}

Function StandbyAndMonitorTimeout($Standby=0, $Monitor=0)
{
	<#	
	.SYNOPSIS
	Nastavi po akom case sa ma monitor vypnut a kedy sa ma pocitat uspat.
	
	.DESCRIPTION	
	Setting Power scheme.
	Example: 
	StandbyAndMonitorTimeout
	
	.EXAMPLE
	StandbyAndMonitorTimeout
	#>	
	Write-Host "Setting Power scheme..." -ForegroundColor Yellow -NoNewline
	Powercfg /change /standby-timeout-ac $Standby
	Powercfg /change /standby-timeout-dc $Standby
	Powercfg /change /monitor-timeout-dc $Monitor
	Powercfg /change /monitor-timeout-ac $Monitor
	write-host "Success" -ForegroundColor Green
	Write-Host "Display will be turned of after $Monitor minutes..." -ForegroundColor Green
}

Function Logon_background
{
	<#	
	.SYNOPSIS
	Nastavi pozadie na prihlasovacej obrazovke.
	
	.DESCRIPTION	
	Setting Logoc screen background.
	Example: 
	Logon_background
	
	.EXAMPLE
	Logon_background
	#>
	Write-Host "OS with classic logon screen detected..." -ForegroundColor Green
	Write-Host "Logon background will be changed..." -ForegroundColor Green
	if ($Test_LogonPath -eq "true") 
		{
			Write-Host "Previous version of logon background detected..." -ForegroundColor Green
			Write-Host "Deleting old files from $Logon" -ForegroundColor Green
			Remove-Item $Logon -force -recurse >> $null
		} 
	else 
		{
			Write-Host "Previous version of logon background not detected..." -ForegroundColor Green
			Write-Host "Nothing to delete from $Logon" -ForegroundColor Yellow
		}	
	Write-Host "Setting logon screen background..." -ForegroundColor Green
	New-Item -ItemType directory -Path "C:\Windows\System32\OOBE\info\Backgrounds\" >> $null
	Copy-Item "$Temp\BackgroundDefault.jpg" "C:\Windows\System32\OOBE\info\Backgrounds\"
	regedit.exe /s "$Temp\Use_Custom_Log_On_Screen.reg" >> $null
}

#Definice funkce pro OS bez klasicke logon screen - Windows 8 a vyssi
Function No_Logon_background
{
	<#	
	.SYNOPSIS
	Zazracna funckia, ktora neviem co nastavi pre Win 8 a vyzsie.
	
	.DESCRIPTION	
	BlackMagic.
	Example: 
	No_Logon_background
	
	.EXAMPLE
	No_Logon_background
	#>
	Write-Host "OS with classic logon screen not detected..."  -ForegroundColor Green
	Write-Host "Logon background will not be changed..." -ForegroundColor Green
	
	#Vypnuti Lock screen
	$LockScreen_RegistryPath="HKLM:\Software\Policies\Microsoft\Windows\Personalization"
	If (!(Test-Path -path $LockScreen_RegistryPath))  
	{
		write-host "Lock screen registry path not exist..." -ForegroundColor Yellow
		#WriteToLogs "Lock screen registry path not exist..."
		write-host "Creating Lock screen registry path..." -ForegroundColor Green
		New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization"  >> $null
	}
	Write-Host "Disabling lock screen display" -ForegroundColor Green 
	Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Personalization" -Name NoLockScreen -Value "1" -Type "Dword"  >> $null
}

Function MuteSounds
{
	<#	
	.SYNOPSIS
	Vypne zvuk.
	
	.DESCRIPTION	
	Metu Sounds.
	Example: 
	MuteSounds
	
	.EXAMPLE
	MuteSounds
	#>
	Write-Host "Mute Sounds..." -ForegroundColor Yellow
	& "$Temp\nircmd.exe" mutesysvolume 1
	Write-Host "Success" -ForegroundColor Yellow -NoNewline
}

Function CheckVersionOfNetFramework($ver="")
{
	<#	
	.SYNOPSIS
	Zisti verzie .net frameworku, popripade zisti ci sa tam nachadza hladana.
	
	.DESCRIPTION	
	Check version of .net Framework.
	Example: 
	$ExistVersionOfFramework = CheckVersionOfNetFramework "v3.5"
    or
    $ListOfFrameworkVersions = CheckVersionOfNetFramework
	
	.EXAMPLE	
	$ExistVersionOfFramework = CheckVersionOfNetFramework "v3.5"
    or
    $ListOfFrameworkVersions = CheckVersionOfNetFramework
	#>
	$VersionsOfFramework = gci "c:\windows\Microsoft.Net\Framework" V* | select Name 
    $ListOfVersions = @()
    foreach($Version in $VersionsOfFramework)
    { 
        $Version = $Version.name
        If ($Version.Substring(1,1) -lt 9) 
        { 
            $Version = $Version.Substring(0,4) 
            if($ver -eq "")
            {
                $ListOfVersions += $Version
            }
            ElseIf($Version -eq $ver)
            {
                Write-Host "Nainstalovany .net Framework 3.5" -ForegroundColor Green
                return $True
            }                        
        } 
    } 
    If($ver -eq "")
    {
        return $ListOfVersions
    }
    return $False    
}

Function SetAnK
{
    <#	
	.SYNOPSIS
	Nainstaluje framework 3.5 a nastavi automaticke spustanie aplikacii po prilogovani.
	
	.DESCRIPTION	
	Instal framework 3.5 and set autorun for aplication.
	Example: 
	SetAnK
	
	.EXAMPLE	
    SetAnK
	#>		
	$AnKPath = "D:\Temp\Ank"
	if(Test-Path $AnKPath)
	{
		Remove-Item $AnKPath -Force -Recurse >> $null
	}
	
	Copy-With-ProgressBar "Z:\AnK\" $AnKPath
	
	if(!((Get-ItemProperty -Path 'HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction SilentlyContinue).Version -like '4.5*'))
	{
		if(!((Get-ItemProperty -Path 'HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction SilentlyContinue).Version -like '4.6*'))
		{
			$PathInstallation = "$AnKPath\dotNet.exe"
			Install-Framework $PathInstallation			
		}
	}
	Set-Run "$AnKPath\AnK.exe" "AplikaciaNaKopirovanie"
	Write-Host "DONE" -ForeGroundColor Green
}

Function DeviceInstalationFromWU($number)
{
	<#	
	.SYNOPSIS
	Nastavuje instalovanie ovladacov cez Windows Update.
	
	.DESCRIPTION	
	Set on/off Windows Update device instalation.
	Example: 
	"for on"
	DeviceInstalationFromWU 1
	"for off"
	DeviceInstalationFromWU 3
	
	.EXAMPLE	
    "for on"
	DeviceInstalationFromWU 1
	"for off"
	DeviceInstalationFromWU 3
	#>
	Write-Host "Setting Windows Update device instalation to $number" -ForegroundColor Yellow -NoNewline
	regedit.exe /s "$Temp\Custom_OS\DeviceInstallFromWU.reg"	
	Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching -Name SearchOrderConfig -Value $number
	Write-Host "Success" -ForegroundColor Green
}

Function Copy-Directory($pathFrom, $pathTo)
{
	<#	
	.SYNOPSIS
	Prekopiruje veci z jedneho priecinka do druheho s kontrolou.
	
	.DESCRIPTION	
	Directory Copy.
	Example: 
	Copy-Directory "W:\_scripts\Custom_OS" "C:\Windows\Temp\Custom_OS"
	
	.EXAMPLE	
	Copy-Directory "W:\_scripts\Custom_OS" "C:\Windows\Temp\Custom_OS"
	#>
	If(Test-Path($pathTo))
	{
		If(!(DirsEquals $pathFrom $pathTo))
		{
			Remove-Item -Recurse -Force $pathTo >> $null
			Write-Host "Copy files to Temp" -ForegroundColor Yellow
			Copy-Item -Path $pathFrom -Destination $pathTo -Recurse -Force
		}
	}
	Else
	{
		write-host "Copy files to Temp" -ForegroundColor Yellow
		Copy-Item -Path $pathFrom -Destination $pathTo -Recurse -Force
	}
}

Function Restart-Service($serviceName)
{
    $GDS_Service = (Get-Service | where {$_.Name -eq $serviceName}).Name
	if ($GDS_Service -ne $null)
	{
		Write-Host "Restarting $serviceName service..." -ForegroundColor Yellow -NoNewline
		Start-Service -Name $GDS_Service
		Write-Host "Success" -ForegroundColor Green
	}
}
Function Automatic-Service($ServiceName)
{
	$GDS_Service = (Get-Service | where {$_.name -eq $ServiceName}).Name
	if ($GDS_Service -ne $null) 
	{
		write-host "Starting $ServiceName service..." -foregroundcolor Yellow -NoNewline
		Set-Service $ServiceName -startuptype "Automatic"
		Write-Host "Success" -ForegroundColor Green
	}
} 

Function Disable-Service($ServiceName)
{
	$GDS_Service = (Get-Service | where {$_.Name -eq $serviceName}).Name
	if ($GDS_Service -ne $null)
	{
		Write-Host "Stopping $serviceName service..." -ForegroundColor Yellow -NoNewline
		Set-Service –Name $ServiceName –StartupType "Disabled"
		Write-Host "Success" -ForegroundColor Green
	}	
}

Function Kill-Service($serviceName)
{
	$GDS_Service = (Get-Service | where {$_.Name -eq $serviceName}).Name
	if ($GDS_Service -ne $null)
	{
		Write-Host "Stopping $serviceName service..." -ForegroundColor Yellow -NoNewline
		Stop-Service -Name $GDS_Service
		Write-Host "Success" -ForegroundColor Green
	}
}

Function Kill-Process($programName)
{
	<#	
	.SYNOPSIS
	Ukonci process, ak je spusteny.
	
	.DESCRIPTION	
	Kill process if it's still running.
	Example: 
	Kill-Process "AnK"
	
	.EXAMPLE	
	Kill-Process "AnK"
	#>
	$isRunning = Get-Process $programName -ErrorAction SilentlyContinue

	If(!($isRunning -eq $null))
	{
		Write-Host "Stopping $programName process..." -ForegroundColor Yellow -NoNewline
		Stop-Process -ProcessName $programName -Force
		Write-Host "Success" -ForegroundColor Green
	}
}

Function Add-MSProjectAccount($keyPath,$accountName, $pwaURL)
{	
	<#	
	.SYNOPSIS
	Vytvori konto pre MS project 2010 alebo 2013.
	
	.DESCRIPTION	
	Crete account for MS Project 2010 or 2013.
	Example: 
	Add-MSProjectAccount "hkcu:\Software\Microsoft\Office\15.0\MS Project\Profiles\" "Default" "http://proj2013.p2013.skola.cz/PWA/"
	Add-MSProjectAccount "hkcu:\Software\Microsoft\Office\14.0\MS Project\Profiles\" "Default" "http://project.skola.cz/pwatest"
	
	.EXAMPLE	
	Add-MSProjectAccount "hkcu:\Software\Microsoft\Office\15.0\MS Project\Profiles\" "Default" "http://proj2013.p2013.skola.cz/PWA/"
	Add-MSProjectAccount "hkcu:\Software\Microsoft\Office\14.0\MS Project\Profiles\" "Default" "http://project.skola.cz/pwatest"
	#>
	$guid = [System.Guid]::NewGuid()	
	Write-Host "Adding MS Project Account..." -ForegroundColor Yellow -NoNewline
	New-Item -Path "$keyPath$accountName" -force >> $null
	New-ItemProperty -Path "$keyPath$accountName" -Name Name -PropertyType String -Value $accountName -Force >> $null
	New-ItemProperty -Path "$keyPath$accountName" -Name GUID -PropertyType String -Value "{$guid}" -Force >> $null
	New-ItemProperty -Path "$keyPath$accountName" -Name Path -PropertyType String -Value $pwaURL -Force >> $null
	New-ItemProperty -Path "$keyPath$accountName" -Name Default -PropertyType String -Value "Yes" -Force >> $null
	Write-Host "Done for $accountName $pwaURL" -ForegroundColor Green
}

Function Add-MSProjectAccount2010($accountName, $pwaURL)
{	
	<#	
	.SYNOPSIS
	Spusti funkciu pre vytvorenie konta MS PRojectu 2010.
	
	.DESCRIPTION	
	Run function to create account for MS Project 2010.
	Example: 
	Add-MSProjectAccount2010 "Default" "http://project.skola.cz/pwatest"
	
	.EXAMPLE	
	Add-MSProjectAccount2010 "Default" "http://project.skola.cz/pwatest"
	#>
	$keyPath = "hkcu:\Software\Microsoft\Office\14.0\MS Project\Profiles\"		
	Add-MSProjectAccount $keyPath $accountName $pwaURL
}

Function Add-MSProjectAccount2013($accountName, $pwaURL)
{	
	<#	
	.SYNOPSIS
	Spusti funkciu pre vytvorenie konta MS PRojectu 2013.
	
	.DESCRIPTION	
	Run function to create account for MS Project 2013.
	Example: 
	Add-MSProjectAccount2013 "Default" "http://proj2013.p2013.skola.cz/PWA/"
	
	.EXAMPLE	
	Add-MSProjectAccount2013 "Default" "http://proj2013.p2013.skola.cz/PWA/"
	#>
	$keyPath = "hkcu:\Software\Microsoft\Office\15.0\MS Project\Profiles\"		
	Add-MSProjectAccount $keyPath $accountName $pwaURL
}
	
Function EnableIEActiveXControl 
{
	<#	
	.SYNOPSIS
	Zapne funkciu ActiveX pre IE.
	
	.DESCRIPTION	
	Turn on ActiveX function for IE.
	Example: 
	EnableIEActiveXControl
	
	.EXAMPLE	
	EnableIEActiveXControl
	#>
	Write-Host "Enabling IE Active X Control..." -ForegroundColor Yellow
	$AppName = "Flash for IE"
	$GUID = "{D27CDB6E-AE6D-11CF-96B8-444553540000}"
	$Flag = "0x00000000"
	$Key = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\ActiveX Compatibility\"+$GUID
	If ((Test-Path $Key) -eq $true) 
	{
		Write-Host $AppName"....." -NoNewline
		Set-ItemProperty -Path $Key -Name "Compatibility Flags" -Value $Flag -Force
		$Var = Get-ItemProperty -Path $Key -Name "Compatibility Flags"
		If ($Var."Compatibility Flags" -eq 0) 
		{
			Write-Host "Enabled" -ForegroundColor Green
		} 
		Else 
		{
			Write-Host "Disabled" -ForegroundColor Yellow
		}
	}
}

Function DisableIEActiveXControl 
{
	<#	
	.SYNOPSIS
	Vypne funkciu ActiveX pre IE.
	
	.DESCRIPTION	
	Turn off ActiveX function for IE.
	Example: 
	DisableIEActiveXControl
	
	.EXAMPLE	
	DisableIEActiveXControl
	#>
	Write-Host "Disabling EActive X Control" -ForegroundColor Yellow
	$AppName = "Flash for IE"
	$GUID = "{D27CDB6E-AE6D-11CF-96B8-444553540000}"
	$Flag = "0x00000400"
    $Key = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\ActiveX Compatibility\"+$GUID
    If ((Test-Path $Key) -eq $true) 
	{
        Write-Host $AppName"....." -NoNewline
        Set-ItemProperty -Path $Key -Name "Compatibility Flags" -Value $Flag -Force
        $Var = Get-ItemProperty -Path $Key -Name "Compatibility Flags"
        If ($Var."Compatibility Flags" -eq 1024) 
		{
            Write-Host "Disabled" -ForegroundColor Yellow
        }
		Else 
		{	
            Write-Host "Enabled" -ForegroundColor Red
        }
    }
}

Function RenameWorkGroup($Name)
{
	<#	
	.SYNOPSIS
	Premenuje Workgroupu.
	
	.DESCRIPTION	
	Rename Workgroup.
	Example: 
	RenameWorkGroup("ucebna10")
	
	.EXAMPLE	
	RenameWorkGroup("ucebna10")
	#>
	$SysInfo = Get-WmiObject Win32_ComputerSystem
	$SysInfo.JoinDomainOrWorkgroup($Name) >> $null
	Write-Host "New name WorkGroup is $Name" -ForegroundColor Green
}

Function RenamePCConfig
{
	$Temp = "D:\"
	$ConfigPath = "$Temp\Configuration.txt"
	if(Test-Path $ConfigPath)
	{	
		$ConfigFile = Get-Content $ConfigPath
		$ConfigSplitter = $ConfigFile.split(',')
		$PCName = $ConfigSplitter[0]
		$Workgroup = $ConfigSplitter[1]		
		Write-Host "New name is $PCName" -ForegroundColor Green
		(Get-WmiObject -Class win32_ComputerSystem).rename($PCName) >> $null
		Write-Host "New workgroup is $Workgroup" -ForegroundColor Green
		(Get-WmiObject Win32_ComputerSystem).JoinDomainOrWorkgroup($Workgroup) >> $null
	}
}

Function RenamePCFromDatabase 
{
	<#	
	.SYNOPSIS
	Premenuje pocitac, podla databazy.
	
	.DESCRIPTION	
	Rename PC.
	Example: 
	RenamePCFromDatabase
	
	.EXAMPLE	
	RenamePCFromDatabase
	#>
    $Temp = "D:\Temp"
	Write-Host "Renaming PC from local Database.csv " -ForegroundColor Yellow
	$MacAddress=(Get-WmiObject win32_NetworkAdapterConfiguration | where {($_.dnsdomain -like "*skola*") -or ($_.dnsdomain -like "*gopas*")}).MACAddress
	$ClassRoom=(Import-Csv -path "$Temp\Database.csv" | where {$_.MAC1 -eq $MacAddress -or $_.MAC2 -eq $MacAddress}).Ucebna
    If($ClassRoom -eq $null)
	{
        #$ClassRoom=(Import-Csv -path "$Temp\Database.csv" | where {$_.MAC3 -eq $MacAddress}).Ucebna
    }
	$NumberOfPC=(Import-Csv -path "$Temp\Database.csv" | where {$_.MAC1 -eq $MacAddress -or $_.MAC2 -eq $MacAddress}).PC
    If($NumberOfPC -eq $null)
	{
        #$NumberOfPC=(Import-Csv -path "$Temp\Database.csv" | where {$_.MAC3 -eq $MacAddress}).PC
    }
	If(!($ClassRoom -eq $null))
	{		
		If($NumberOfPC -like "Lektor*")
		{
			$Newname = $NumberOfPC+"SK"+ $ClassRoom
		}
		Else		
		{
			if([convert]::ToInt32($NumberOfPC) -lt 10)
			{
				$Newname = "StudentSK"+$ClassRoom+"-0"+$NumberOfPC
			}
			else
			{
				$Newname = "StudentSK"+$ClassRoom+"-"+$NumberOfPC
			}
		}		
		(Get-WmiObject -Class win32_ComputerSystem).rename($Newname) >> $null
		Write-Host "New name is $Newname" -ForegroundColor Green
		RenameWorkGroup("UcebnaSK"+$ClassRoom)
	}
}

Function CheckRenamePC
{
	<#	
	.SYNOPSIS
	Skontroluje ci treba zmenit nazov pocitaca. (VHD IMAGE)
	
	.DESCRIPTION	
	Check if need to rename PC.
	Example: 
	CheckRenamePC
	
	.EXAMPLE	
	CheckRenamePC
	#>
	If($Global:OldCSName -like "*WIN-*")
	{		
		RenamePCConfig		
	}
}


Function Copy-With-ProgressBar($Source, $Dest)
{
	<#	
	.SYNOPSIS
	Nakopiruje subory aj s progress barom.
	
	.DESCRIPTION	
	Copy files with progress bar.
	Example: 
    Copy-With-ProgressBar "C:\Temp" "C:\Temp2"
	
	.EXAMPLE	
	Copy-With-ProgressBar "C:\Temp" "C:\Temp2"
	#>
    if($Source[$Source.Length-1] -eq "\")
    {
       $Source = $Source.Substring(0,$Source.Length-1)
    }
    if(($Dest[$Dest.Length-1] -eq "\"))
    {
       $Dest = $Dest.Substring(0,$Dest.Length-1)
    }
    $files = Get-ChildItem $Source -recurse    
    $counter = 1
    Foreach($file in $files)
    {
        $status = "Copy files {0} on {1}: {2}" -f $counter,$files.Count,$file.Name
        Write-Progress -Activity "Copy data" $status -PercentComplete ($counter / $files.count*100)
        $restpath = $file.fullname.replace($Source,"")
		If($file.PSIsContainer -eq $true)
		{
			New-Item -Type directory $($Dest+$restpath) -Force >> $null
		}
		else                             
		{
			Copy-Item  $file.fullname $($Dest+$restpath) -Force >> $null
		}           
        $counter+=1  
    }
	Write-Progress -Activity "Copy data" "DONE" -PercentComplete 100
}

Function Remove-With-ProgressBar($Dest)
{
	<#	
	.SYNOPSIS
	Odstrani subory aj s progress barom.
	
	.DESCRIPTION	
	Remove files with progress bar.
	Example: 
    Remove-With-ProgressBar "C:\Temp"
	
	.EXAMPLE	
	Remove-With-ProgressBar "C:\Temp"
	#>
    $files = Get-ChildItem $Dest -recurse    
    $counter = 1
    Foreach($file in $files)
    {
        $status = "Remove files {0} on {1}: {2}" -f $counter,$files.Count,$file.Name
        Write-Progress -Activity "Remove data" $status -PercentComplete ($counter / $files.count*100)        
        if(!($file.PSIsContainer -eq $true))
        {
            Remove-Item  $file.fullname -Force >> $null
        }        
        $counter+=1  
    }
    Remove-Item $Dest -Force -Recurse >> $null
	Write-Progress -Activity "Remove data" "DONE" -PercentComplete 100
}

Function Set-ConsoleFont($x, $y)
{
	<#	
	.SYNOPSIS
	Nastavi velkost powershellskeho rozhrania.(Prejavi sa az podalsom spusteni powershellu)
	
	.DESCRIPTION	
	Set powershell Windows Size.
	Example: 
    Set-ConsoleFont -x 8 -y 12
	
	.EXAMPLE	
	Set-ConsoleFont -x 8 -y 12
	#>
	Write-Host "Setting ConsoleFont Size $x $y" -ForegroundColor Yellow
	$ErrorActionPreference = "ON"
    $x = "{0:X}" -f $x
    $y = "{0:X}" -f $y
    $final = $x+"000"+$y
	$final = [Convert]::ToInt32($final, 16)
	If(!(Test-Path "HKCU:\Console\%SystemRoot%_system32_cmd.exe"))
	{
		New-Item -Path "HKCU:\Console\%SystemRoot%_system32_cmd.exe" >> $null
	}
    New-ItemProperty -Path "HKCU:\Console\%SystemRoot%_system32_cmd.exe" -Name FontSize -PropertyType DWord -Value $final -Force >> $null
	If(!(Test-Path "HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe"))
	{
		New-Item -Path "HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe" >> $null
	}
    New-ItemProperty -Path "HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe" -Name FontSize -PropertyType DWord -Value $final -Force >> $null 
}

Function GhostClientRepair($Path)
{
	<#	
	.SYNOPSIS
	Nakopiruje dobreho ghosta.
	
	.DESCRIPTION	
	GhostClientRepair
	Example: 
    GhostClientRepair "C:\Windows\Temp\Custom_OS\Ghost"
	
	.EXAMPLE	
	GhostClientRepair "C:\Windows\Temp\Custom_OS\Ghost"
	#>
	Write-Host "Repairing GhostClient..." -ForegroundColor Yellow -NoNewline
	$Pathx86 = "C:\Program Files\Symantec\"
	$Pathx64 = "C:\Program Files (x86)\Symantec\"
	$GhostPath = ""
    If(Test-Path $Pathx86)
	{
		$GhostPath = $Pathx86
	}
	Elseif(Test-Path $Pathx64)
	{
		$GhostPath = $Pathx64
	}
	If(!($GhostPath -eq ""))
	{
		Remove-With-ProgressBar $GhostPath"Ghost"
		Copy-With-ProgressBar $Path $GhostPath"Ghost"
		Write-Host "Success" -ForeGroundColor Green
	}
	Else
	{		
		Write-Host "Not found ghost path" -ForeGroundColor Yellow
	}	
	#GhostClientInstall "C:\Windows\Temp\Custom_OS\GhostClientInstall\Client.msi"
}

Function GhostClientRemove
{
	<#	
	.SYNOPSIS
	Odstrani ghosta.
	
	.DESCRIPTION	
	GhostClientRemove
	Example: 
    GhostClientRemove
	
	.EXAMPLE	
	GhostClientRemove
	#>
	Write-Host "Removing GhostClient..." -ForegroundColor Yellow -NoNewline
	$Pathx86 = "C:\Program Files\Symantec\"
	$Pathx64 = "C:\Program Files (x86)\Symantec\"
	$GhostPath = ""
    If(Test-Path $Pathx86)
	{
		$GhostPath = $Pathx86
	}
	Elseif(Test-Path $Pathx64)
	{
		$GhostPath = $Pathx64
	}
	If(!($GhostPath -eq ""))
	{
		Remove-With-ProgressBar $GhostPath
		Write-Host "Success" -ForeGroundColor Green
	}
	Else
	{		
		Write-Host "Not found ghost path" -ForeGroundColor Yellow
	}	
}

Function Set-WallPaper($SourcePath)
{
	<#	
	.SYNOPSIS
	Nastavi pozadie plochy.
	
	.DESCRIPTION	
	Set background image.
	Example: 
    Set-WallPaper "C:\Windows\Temp\Custom_OS\Gopas_backgroundImage.jpg"
	
	.EXAMPLE	
	Set-WallPaper "C:\Windows\Temp\Custom_OS\Gopas_backgroundImage.jpg"
	#>
	Write-Host "Setting Wallpaper" -ForeGroundColor Yellow
	if(!(Test-Path "HKU:\"))
	{
		write-host "Loading Default profile registry hive..." -foregroundcolor green
		New-PSDrive HKU registry HKEY_USERS >> $null
		reg load HKU\Default C:\Users\Default\ntuser.dat >> $null
	}
	New-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -Name Wallpaper -PropertyType String -Value $SourcePath -Force >> $null
	New-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -Name Wallpaperstyle -PropertyType String -Value 2 -Force >> $null
	New-ItemProperty -path 'HKU:\Default\Control Panel\Desktop\' -Name Wallpaper -PropertyType String -Value $SourcePath -Force >> $null
	New-ItemProperty -path 'HKU:\Default\Control Panel\Desktop\' -Name Wallpaperstyle -PropertyType String -Value 2 -Force >> $null
	New-ItemProperty -path 'HKU:\.Default\Control Panel\Desktop\' -Name Wallpaper -PropertyType String -Value $SourcePath -Force >> $null
	New-ItemProperty -path 'HKU:\.Default\Control Panel\Desktop\' -Name Wallpaperstyle -PropertyType String -Value 2 -Force >> $null
	New-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System\' -Name Wallpaper -PropertyType String -Value $SourcePath -Force >> $null
	New-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System\' -Name Wallpaperstyle -PropertyType String -Value 2 -Force >> $null
	rundll32.exe user32.dll, UpdatePerUserSystemParameters
}

Function ChangeBootLink
{
	<#	
	.SYNOPSIS
	Nastavi pozadie plochy.
	
	.DESCRIPTION	
	Set background image.
	Example: 
    Set-WallPaper "C:\Windows\Temp\Custom_OS\Gopas_backgroundImage.jpg"
	
	.EXAMPLE	
	Set-WallPaper "C:\Windows\Temp\Custom_OS\Gopas_backgroundImage.jpg"
	#>
	Write-Host "Adding Zmenit Bootovanie.lnk to Start Menu" -ForegroundColor Yellow
	$Temp = "D:\Temp"
	$TMP = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\"
	If(Test-Path $TMP)
	{
		Copy-Item "$Temp\BootOS\Zmenit Bootovanie.lnk" $TMP -Force >> $null
	}
}

Function ChangePassword($Password="")
{        
	Write-Host "Changing User password to $Password" -ForegroundColor Yellow
    ([adsi]"WinNT://$Global:OldCSName/$env:username,user").setpassword($Password)
}

Function CheckNotebookPassword()
{
	$Temp = "D:\"
	$ConfigPath = "$Temp\Configuration.txt"
	if(Test-Path $ConfigPath)
	{	
		$ConfigFile = Get-Content $ConfigPath
		$ConfigSplitter = $ConfigFile.split(',')
		$PCName = $ConfigSplitter[0]
		if($PCName -like "Dell*" -or $PCName -like "STUDENTSK5*")
		{
			ChangePassword
		}
	}    
}

Function UpdateUserSystemRegistry
{
	<#	
	.SYNOPSIS
	Updatne zmeny urobene v registroch.
	
	.DESCRIPTION	
	Update User System Registry.
	Example: 
    UpdateUserSystemRegistry
	
	.EXAMPLE	
	UpdateUserSystemRegistry
	#>
	Write-Host "Updating User Registry" -ForegroundColor Yellow
	for ($i=1; $i -le 4; $i++)
    {
		rundll32.exe user32.dll, UpdatePerUserSystemParameters 
	}
}

Function PageFileAutomatic()
{
	Write-Host "Setting Page File to Automatic" -ForegroundColor Yellow
	$computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges >> $null
	$computersys.AutomaticManagedPagefile = $True >> $null
	$computersys.Put() >> $null
}

Function RenameUserAccount($OldName, $NewName)
{
	& net user $OldName /fullname:$NewName > 2 
	& wmic useraccount where name="'"$OldName"'" rename $NewName > 2
	write-host "Change user account $OldName to $NewName" -ForeGroundColor Yellow
}

Function RemoveUserAccount($Account)
{
	write-host "Deleting $Account..." -ForeGroundColor Yellow -NoNewline
	& net user $Account /delete > 2
	write-host "Deleted" -ForeGroundColor Green
}

Function UpdateCzechWindowsx64()
{
	If(Get-OSAbrivation -eq "w7_x64")
	{
		If($Global:HWUserName -like "*StudentEN")
		{
			RemoveUserAccount "StudentCZ"
			ChangePassword 'Pa$$w0rd' 
			RenameUserAccount "StudentEN" "Student"			
		}
	}
}

Function OfficeRearm()
{		
	If(Test-Path "C:\Program Files (x86)\Microsoft Office\Office15\Ospprearm.exe")
	{
		$Path_OSPPREARM = "C:\Program Files (x86)\Microsoft Office\Office15\Ospprearm.exe"
	}
	if(Test-Path $Path_OSPPREARM)
	{
		$Objects = & $Path_OSPPREARM
		Write-Host "Rearming Office" -ForegroundColor Yellow
		foreach($Object in $Objects)
		{
			if($Object -like "*Error*")
			{
				$Nepresiel = 1
				$Rearm_ok = 0
			}
		}
	}
}

Function Remove-Autologon-Registry()
{
	Write-Host "Removing Autologon from registry..." -ForegroundColor Yellow -NoNewline
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoLogonCount" -Force
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Force	
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "ForceAutoLogon" -Force
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Force
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Force
	Write-Host "Success" -ForegroundColor Green
}

Function Save-Current-Logon-User()
{
	Write-Host "Writing Current Logon User $env:UserName to Temp\User.txt" -ForegroundColor Yellow
	& echo $env:username >  $Temp\User.txt
}

Function Set-AutologonAutomatic()
{	
	Write-Host "Setting Automatic Autologon..." -ForegroundColor Yellow
	$User_name=$env:username
	if($User_name -eq $null)
	{
		$User_name = Get-Content $Temp\User.txt
	}	

	switch -wildcard ($User_name) 
	{ 
		"*StudentCZ" {Set-Autologon 1 $User_name}
		"*StudentEN" {Set-Autologon 1 $User_name}
		"*StudentSK" {Set-Autologon 1 $User_name}
		"*Student" {Set-Autologon 1 $User_name 'Pa$$w0rd'}
		"*Administrator" {
			if(Get-OSAbrivation -eq "w2k16")
			{				
					Set-Autologon 1 $User_name 'Pa55w.rd'				
			}
			else
			{
				Set-Autologon 1 $User_name 'Pa$$w0rd'
			}
		}
		default {Set-Autologon 1}
	}
}

Function Set-WindowStyle 
{
param(
    [Parameter()]
    [ValidateSet('FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE', 
                 'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED', 
                 'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
    $Style = 'SHOW',
    [Parameter()]
    $MainWindowHandle = (Get-Process -Id $pid).MainWindowHandle
)
    $WindowStates = @{
        FORCEMINIMIZE   = 11; HIDE            = 0
        MAXIMIZE        = 3;  MINIMIZE        = 6
        RESTORE         = 9;  SHOW            = 5
        SHOWDEFAULT     = 10; SHOWMAXIMIZED   = 3
        SHOWMINIMIZED   = 2;  SHOWMINNOACTIVE = 7
        SHOWNA          = 8;  SHOWNOACTIVATE  = 4
        SHOWNORMAL      = 1
    }
    Write-Verbose ("Set Window Style {1} on handle {0}" -f $MainWindowHandle, $($WindowStates[$style]))

    $Win32ShowWindowAsync = Add-Type –memberDefinition @" 
    [DllImport("user32.dll")] 
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -name "Win32ShowWindowAsync" -namespace Win32Functions –passThru

    $Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$Style]) 2>null | Out-Null
}

Function Delete-From-Run($Name)
{
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name $Name -Force
}

Function Check-Run-Registry()
{
	Delete-From-Run -Name "Map_Disc"	
	Delete-From-Run -Name "UserSettings"
}

Function Check-Temporary-Profile
{
	if($Global:UserName -eq "Profile")
	{
		Remove-Autologon-Registry
		Set-RunOnce -Path "$Temp\GatewayDetection.bat" -Name "ConnectToImage"
		Set-Autologon -Setter 1 -UserName "Student" -Password 'Pa$$w0rd'
		Restart-Computer
	}
}

Function Office-Rearm
{
	$Bit_version=(Get-WMIObject win32_operatingsystem).osarchitecture

	if ($Bit_version -like "*64*") 
	{
		$ProgramFiles="Program Files (x86)"
	} 
	else 
	{
		$ProgramFiles="Program Files"
	}

	$Nepresiel = 0
	$Rearm_ok = 1
	$Path_OSPPREARM = ""
	$Path_OSPPVBS = "" 

	if(Test-Path "C:\$ProgramFiles\Microsoft Office\Office15\Ospprearm.exe")
	{
		$Path_OSPPREARM = "C:\$ProgramFiles\Microsoft Office\Office15\Ospprearm.exe"
		$Path_OSPPVBS = "C:\$ProgramFiles\Microsoft Office\Office15\Ospp.vbs" 
	}
	elseif(Test-Path "C:\$ProgramFiles\Common Files\Microsoft Shared\OfficeSoftwareProtectionPlatform\Ospprearm.exe")
	{
		$Path_OSPPREARM = "C:\$ProgramFiles\Common Files\Microsoft Shared\OfficeSoftwareProtectionPlatform\Ospprearm.exe"
		$Path_OSPPVBS = "C:\$ProgramFiles\Common Files\Microsoft Shared\OfficeSoftwareProtectionPlatform\Ospp.vbs" 
	}

	if(Test-Path $Path_OSPPREARM)
	{
		$Objects = & $Path_OSPPREARM
		foreach($Object in $Objects)
		{
			if($Object -like "*Error*")
			{
				$Nepresiel = 1
				$Rearm_ok = 0
			}
		}
	}

	if($Nepresiel)
	{	
		if(Test-Path $Path_OSPPREARM)
		{
			$Objects = cscript $Path_OSPPREARM /dstatus
			foreach($Object in $Objects)
			{
				if($Object -like "SKU ID:*")
				{
					$ID = $Object.Substring(8)
					write-host $ID -foreground green
				}
			}
			$Object = cscript $Path_OSPPREARM /rearm:$ID
			foreach($Object in $Objects)
			{
				write-host $Object -foregroundcolor Yellow
				if($Object -like "*successful*")
				{
					$Rearm_ok = 1
				}
			}
		}
	}

	if($Rearm_ok -eq 1)
	{
		write-host "DONE" -foregroundcolor green
	}
	else
	{
		write-host "Pri rearme nastala chyba" -foregroundcolor red
	}
}

Function TimeSynch($ServerName)
{	
	$pole_casu = @{}
	$actual_date=Get-Date -format "MM/dd/yyyy"
	Write-Host "Actual date is $actual_date ..." -ForegroundColor Green
	Get-ChildItem "W:\Change_Dates\" | % {
		$desired_date=(Get-Content $_.FullName)[0]
		$desired_date=$desired_date -replace "date ",""		
		$pole_casu[$_] = $desired_date
	}
	if (($Time_sync -eq "$null") -or ($Time_sync -eq ""))
	{
		if ($pole_casu.Values -contains $actual_date)
		{
			write-host "Date and time applied is not actual due to course prerequsities..." -foregroundcolor green
		}
		else
		{
			Write-Host "Syncing time with time server..." -ForegroundColor Green
			net.exe time \\$ServerName /set /y
		}
	}
}

Function DetectMapNetworkShares
{
	if(!(Test-Path "Z:\") -or !(Test-Path "W:\"))
	{
        $ServerName = Get-ServerName
		if($ServerName -ne "")
		{
			$Temp="D:\Temp"
			write-host "Connecting to $ServerName..." -foregroundcolor green
			
			$password="$Temp\Password.txt"
			if(!(Test-Path -path $password))
			{
				$password = Read-Host "Zadej heslo pro pripojeni na $ServerName"
			}	
			else
			{
				$password=Get-Content $password
				Remove-Item $Temp\Password.txt -Force
			}
			$OBJ = net use z: \\$ServerName\Startup_OS$ /user:ghostinstall $password /persistent:no 2>null | Out-Null
			$OBJ = net use w: \\$ServerName\Startup_WinPE$ /user:ghostinstall $password /persistent:no 2>null | Out-Null
		}
	}	
}

Function Restart($Time=15)
{
	$wshell = new-object -comobject wscript.shell -erroraction stop
	$wshell.popup("Restart for Post-install scripts....",$Time,"Restart")
	Restart-Computer -Force
}

Function Shutdown($Time=15)
{
	$wshell = new-object -comobject wscript.shell -erroraction stop
	$wshell.popup("Shutdown Computer....",$Time,"Shutdown")
	Stop-Computer -Force
}

Function RepairGhostPubCert
{
	Write-Host "Repairing GhostClient Certificate..." -ForegroundColor Yellow -NoNewline
	$Pathx86 = "C:\Program Files\Symantec\Ghost"
	$Pathx64 = "C:\Program Files (x86)\Symantec\Ghost"
	$GhostPath = ""
    If(Test-Path $Pathx86)
	{
		$GhostPath = $Pathx86
	}
	Elseif(Test-Path $Pathx64)
	{
		$GhostPath = $Pathx64
	}
	If(!($GhostPath -eq ""))
	{
		Remove-Item "$GhostPath\pubkey.crt"
		Write-Host "Success" -ForeGroundColor Green
	}
	Else
	{		
		Write-Host "Not found ghost path" -ForeGroundColor Yellow
	}	
}

Function GetComputerNameFromServerByMac($Mac)
{
	$ComputerName = ""
	if($Mac -ne "")
	{
		DetectMapNetworkShares
		$MachineGroupPath = "W:\Deployment\GDS Console\Machine Groups"
		if(Test-Path $MachineGroupPath)
		{
			$Files = Get-ChildItem $MachineGroupPath -recurse -filter "*.my"
			foreach($File in $Files)
			{	
				$ContentOfFile = Get-Content -Path $File.FullName
				foreach($line in $ContentOfFile)
				{
					if($line -like "MacAddress||*")
					{
						$MacAddresses = $line.Split('||') | Where { $_.length -gt 0 }            
						if($MacAddresses -like '*&*')
						{                
							$ArrayOfMacs = $MacAddresses[1].Split('&')                
							foreach($MacFromArray in $ArrayOfMacs)
							{
								if($Mac -eq $MacFromArray)
								{
									$ComputerName = $File.FullName.Replace(".my",".cfg")
									break
								}
							}
							if($ComputerName -ne "")
							{
								break
							}
						}
						else
						{
							if($Mac -eq $MacAddresses[1])
							{
								$ComputerName = $File.FullName.Replace(".my",".cfg")
								break
							}
						}						         
					}
				}
			}
		}
	}
	return $ComputerName
}

Function GetComputerNameFromServerByMacXML($Mac)
{
	$ComputerName = ""
	if($Mac -ne "")
	{
		DetectMapNetworkShares
		$MachineGroupPath = "W:\Deployment\GDS Server\Machine Groups"
		if(Test-Path $MachineGroupPath)
		{
			$Files = Get-ChildItem $MachineGroupPath -recurse -filter "*.my"			
			foreach($File in $Files)
			{	
				[xml]$XMLConfigFile = Get-Content -Path $File.FullName
				foreach($MacAddres in $XMLConfigFile.ComputerDetailsData.macAddresses.string)
				{    
					if($Mac -eq $MacAddres)
					{
						$ComputerName = $File.FullName.Replace(".my",".cfg")                        
						return $ComputerName
					}					
				}
			}
		}
	}
	return $ComputerName
}


Function AddCert
{
	$CertFiles=get-childitem "$Temp\*.cer"
	$Store = get-item Cert:\LocalMachine\Root
	$Store.Open("ReadWrite")
	foreach($CertFile in $CertFiles)
	{
		$Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertFile.FullName)
		$Store.Open("ReadWrite")
		$Store.Add($Cert)
		$TRASH = certutil -addstore 'TrustedPublisher' $CertFile 2>null | Out-Null
		write-host "Adding $certfile" -foregroundcolor green
	}
	$Store.Close()		
}

Function IE_SEC_OFF
{	
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" /v "IsInstalled" /t REG_DWORD /d 0 /f 2>null | Out-Null
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" /v "IsInstalled" /t REG_DWORD /d 0 /f 2>null | Out-Null
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432node\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" /v "IsInstalled" /t REG_DWORD /d 0 /f 2>null | Out-Null
	REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "IEHarden" /t REG_DWORD /d 0 /f 2>null | Out-Null
	REG ADD "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "IEHarden" /t REG_DWORD /d 0 /f 2>null | Out-Null
	REG ADD "HKEY_CURRENT_USER\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "IEHarden" /t REG_DWORD /d 0 /f 2>null | Out-Null
	Rundll32 iesetup.dll,IEHardenUser 2>null | Out-Null
	Rundll32 iesetup.dll,IEHardenAdmin 2>null | Out-Null
	Rundll32 iesetup.dll,IEHardenMachineNow 2>null | Out-Null
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OC Manager\Subcomponents" /v "iehardenadmin" /f /va 2>null | Out-Null
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OC Manager\Subcomponents" /v "iehardenuser" /f /va 2>null | Out-Null
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OC Manager\Subcomponents" /v "iehardenadmin" /t REG_DWORD /d 0 /f 2>null | Out-Null
	REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OC Manager\Subcomponents" /v "iehardenuser" /t REG_DWORD /d 0 /f 2>null | Out-Null
	REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "First Home Page" /f 2>null | Out-Null
	REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "Default_Page_URL" /t REG_SZ /d "about:blank" /f 2>null | Out-Null
	REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "Start Page" /t REG_SZ /d "about:blank" /f 2>null | Out-Null
	REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "NoProtectedModeBanner" /t REG_DWORD /d 1 /f 2>null | Out-Null
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\Install\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "IEHarden" /f 2>null | Out-Null
	REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Terminal Server\Install\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "IEHarden" /f 2>null | Out-Null
}
Function CreateNetworkShortcuts
{
	#Vytvoreni odkazu na ostatni PC v ucebne
	$gateway=(Get-WmiObject win32_NetworkAdapterConfiguration | where {($_.dnsdomain -like "*skola*") -or ($_.dnsdomain -like "*gopas*")}).DefaultIPGateway
	$DesktopPath = (get-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders").Desktop
	New-Item $DesktopPath\Shares -itemtype directory
	$SharesFolder = "$DesktopPath\Shares"
	if($env:computername -like "*LEKTOR*") 
	{
		$Classroom = $env:computername -replace "LEKTOR", ""
	}
	if($env:computername -like "*STUDENT*") 
	{ 
		$Classroom = $env:computername -replace "STUDENT", ""
		$Classroom = $Classroom -replace "-.*", ""
	}
	
	$WshShell = New-Object -comObject WScript.Shell
	$Shortcut = $WshShell.CreateShortcut("$SharesFolder\LEKTOR$($Classroom).lnk")
	$Shortcut.TargetPath = "\\LEKTOR$($Classroom)"
	$Shortcut.Save()
	
	$Student = 1
	$Count = 1
	while($Count -lt 13)
	{
		$Order = 0
		if($Count -lt 10){$Order = "0" + $Count}
		else{$Order = $Count}
		$Computer = "STUDENT$($Classroom)-$Order"
		$ComputerShare = "\\STUDENT$($Classroom)-$Order"
		
		$WshShell = New-Object -comObject WScript.Shell
		$Shortcut = $WshShell.CreateShortcut("$SharesFolder\$Computer.lnk")
		$Shortcut.TargetPath = "$ComputerShare"
		$Shortcut.Save()

		$Count++
	}	
}

Function ResetTime 
{
	#Pokud v image nesedi cas, kvuli zimnimu a letnimu presunu, toto to opravi
	get-service | where {$_.name -like "*W32Time*"} | start-service
	cmd /c "W32tm /resync /force"
	get-service | where {$_.name -like "*W32Time*"} | stop-service
	tzutil /s "Central European Standard Time"
}

Function CHOCO-INSTALL($InstallationName, $Counter = 0)
{
  write-host "Installing $InstallationName..." -foregroundcolor yellow
  choco install $InstallationName -y
  if($? -eq $True)
  {
    "Installation of $InstallationName completed succesfully" | out-file E:\Log.txt -encoding ascii -append
  }
  else
  {
    if($Counter -eq 3)
    { 
      "Installation of $InstallationName failed" | out-file E:\Log.txt -encoding ascii -append
    }
    else
    {
      write-host "Retrying to install $InstallationName" -foregroundcolor yellow
      start-sleep -s 5
	  $Counter++
      CHOCO-INSTALL $InstallationName $Counter
    }
  }
  start-sleep -s 2
}

Function SetDisplayDuplicate-Registry
{
	$Monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams

	$MonitorsID = @()
	Write-Host "Getting Monitors ID..." -ForegroundColor Yellow -NoNewLine
	foreach($Monitor in $Monitors)
	{
		If($Monitor.InstanceName -like "*\*")
		{
			$MonitorID = $Monitor.InstanceName.Split('\')[1]
			$MonitorsID += $MonitorID
		}
	}
	Write-Host "Success" -ForegroundColor Green

	if($MonitorsID.Count -eq 2)
	{
		$MonitorFirst = $MonitorsID[0]
		$MonitorSecond = $MonitorsID[1]		
		$DateInHex = [Convert]::ToString([Math]::Round((Get-Date).ToFileTime()),16)
		$registryFolders = Get-ChildItem "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Configuration"    
		Foreach($registryFolder in $registryFolders)
		{                        
			if($registryFolder.PSChildName -like "$MonitorFirst*+$MonitorSecond*" -or $registryFolder.PSChildName -like "$MonitorSecond*+$MonitorFirst*")
			{				
				$RegistryChildName = $registryFolder.PSChildName            
				Write-Host "Removing Registry Folder..." -ForegroundColor Yellow -NoNewLine
				Remove-Item -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Configuration\$RegistryChildName" -Force -Recurse >> $null
				Write-Host "Success" -ForegroundColor Green			
			}
		}
		$registryFolders = Get-ChildItem "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity"    
		Foreach($registryFolder in $registryFolders)
		{
			if($registryFolder.PSChildName -like "$MonitorFirst*^$MonitorSecond*" -or $registryFolder.PSChildName -like "$MonitorSecond*^$MonitorFirst*")
			{
				$RegistryChildName = $registryFolder.PSChildName 
				$RegistryChildNameSplitter = $RegistryChildName.Split('^')
				$ID = $RegistryChildNameSplitter[0]+"*"+$RegistryChildNameSplitter[1]                                                      
				$itemProperty = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" -Name "eXtend" -ErrorAction SilentlyContinue
				if(!($itemProperty -eq $null))
				{
					$ID = $itemProperty.eXtend
					Write-Host "Removing Registry Item extend..." -ForegroundColor Yellow -NoNewLine
					Remove-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" -Name "eXtend" -ErrorAction SilentlyContinue
					Write-Host "Success" -ForegroundColor Green	
					$ID = $ID.Replace('+','*').Substring(0,$ID.Length-1)
				}            
				if(!(Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" "Clone" -ErrorAction SilentlyContinue))                                
				{
					Write-Host "Creating Registry Item Clone..." -ForegroundColor Yellow -NoNewLine
					New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" -Name "Clone" -Value $ID -Force >> $null                  
					Write-Host "Success" -ForegroundColor Green	
				} 
				if(!(Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" "Recent" -ErrorAction SilentlyContinue))                                
				{
					Write-Host "Creating Registry Item Recent..." -ForegroundColor Yellow -NoNewLine
					New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" -Name "Recent" -Value $ID -Force >> $null
					Write-Host "Success" -ForegroundColor Green	
				}             
				else
				{
					Write-Host "Setting Registry Item Recent..." -ForegroundColor Yellow -NoNewLine
					Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" -Name "Recent" -Value $ID -Force >> $null
					Write-Host "Success" -ForegroundColor Green	
				}
				$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
				$utf8 = new-object -TypeName System.Text.UTF8Encoding
				$hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($ID)))
				$hash = $hash.Replace('-','')              
				$ID_HASH ="$ID^$hash"
				if(!(Test-Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Configuration\$ID_HASH"))
				{
					if(Test-Path D:\SetDisplayDuplicate_Template.reg)
					{						
						$ContentOfRegistry = (Get-Content -Path D:\SetDisplayDuplicate_Template.reg).Replace("ID_WITH_HASH", $ID_HASH).Replace("ID_WITHOUT_HASH", $ID)
						Set-Content -Path D:\SetDisplayDuplicate.reg -Value $ContentOfRegistry
						Write-Host "Importing registry..." -ForegroundColor Yellow -NoNewLine
						& reg import D:\SetDisplayDuplicate.reg 2>null | Out-Null
						Write-Host "Success" -ForegroundColor Green
						Write-Host "Setting Registry Item Timestamp..." -ForegroundColor Yellow -NoNewLine
						Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Configuration\$ID_HASH" -Name "TimeStamp" -Value "0x$DateInHex" >> $null
						Write-Host "Success" -ForegroundColor Green	
					}
				}
			}
		}
	}
}

Function SetDisplayDuplicate
{
	Write-Host "Setting Duplicate monitor for Lector"
	& C:\Windows\System32\DisplaySwitch.exe /clone
}

Function SetDisplayDuplicateForLector
{		
	$MacAddress = (Get-WmiObject win32_NetworkAdapterConfiguration | where {($_.dnsdomain -like "*skola*") -or ($_.dnsdomain -like "*gopas*")}).MACAddress
    $ComputerFileName = GetComputerNameFromServerByMacXML -Mac $MacAddress
    if(Test-Path $ComputerFileName)
    {
	    [xml]$XMLConfigFile = Get-Content $ComputerFileName
        $PCName = $XMLConfigFile.ComputerConfigData.Name
    }
	if($PCName -like "LEKTOR*")
	{
		SetDisplayDuplicate-Registry
		New-Item -Path D:\temp\SetDisplayDuplicate.txt -ItemType "file" -Value "DONE" >> $null
	}
}

Function SettingsDualMonitor
{	
	write-host ""
	# Nastavi stranu sekundarneho monitora
	Write-Host "Setting monitor side" -foreground $Global:UserInputColor -BackgroundColor $Global:bgColor
	$Student = $env:computername
	if($Student -like "Student*")
	{
		$Student = $Student.Substring($Student.length-2,2)
		$int = [int]$Student
		if($int % 2 -eq 1) 
		{
			Run "D:\Temp\SwitchMonitor.exe" "-1980"
		}	
		else
		{
			Run "D:\Temp\SwitchMonitor.exe" "1980"
		}
	}				
}

Function Set-ePrezence
{
	<#	
	.SYNOPSIS
	Nastavi ePrezence.
	
	.DESCRIPTION	
	Set ePrezence.
	Example: 
    Set-ePrezence
	
	.EXAMPLE	
	Set-ePrezence
	#>
	Write-Host "Adding ePrezence.lnk to Start Menu" -ForegroundColor Yellow
	$ePrezencePath = "D:\Temp\ePrezence"
	$StartMenuPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\"	
	$PublicDesktopPath = "C:\Users\Public\Desktop\"
	If(Test-Path $StartMenuPath)
	{
		Copy-Item "$ePrezencePath\ePrezence.lnk" $StartMenuPath -Force >> $null
	}
	If(Test-Path $PublicDesktopPath)
	{
		Copy-Item "$ePrezencePath\ePrezence.lnk" $PublicDesktopPath -Force >> $null
	}
	#Set-Run -Path "$ePrezencePath\ePrezence.exe" -Name "ePrezence"
	#Register-ScheduledTask -Xml (get-content 'D:\Temp\ePrezence\ePrezence.xml' | out-string) -TaskName "ePrezence" –Force
}

Function Get-ServerName()
{
    # Detekce pobocky na zaklade vychozi brany. Funguje jak pro ucebnovou, tak privatni sit na kazde podobcce
    $gateway=(Get-WmiObject win32_NetworkAdapterConfiguration | where {($_.dnsdomain -like "*skola*") -or ($_.dnsdomain -like "*gopas*")}).DefaultIPGateway
    write-host "Gateway $gateway detected..." -foregroundcolor green

    #Rozhodovani, jaka funkce pro pobocku bude pouzita na zaklade detekce vychozi brany
    switch -wildcard ($gateway) 
    { 
        "10.1.0.1" {$ServerName = "PrahaImage"}
 	    "10.2.0.1" {$ServerName = "PrahaImage"}
        "10.101.0.1" {$ServerName = "BrnoImage"}
	    "10.102.0.1" {$ServerName = "BrnoImage"} 
        "10.201.0.1" {$ServerName = "BlavaImage"}
	    "10.202.0.1" {$ServerName = "BlavaImage"}   
        default { $ServerName = ""}
    }
    return $ServerName
}

Function Install-Choco-From-Local-Server
{
    $ServerName = Get-ServerName

    #Instalace Chocolatey
    iex ((New-Object System.Net.WebClient).DownloadString("http://$ServerName.gopas.cz/install.txt"))

    choco source add --name=internal_machine --source="http://$ServerName.gopas.cz/chocolatey" --priority=1
    choco source remove --name=chocolatey
}

Function Set-Password-By-UserName
{
	Write-Host "Setting Password by UserName" -ForegroundColor Yellow
	$User_name=$env:username
	if($User_name -eq $null)
	{
		$User_name = Get-Content $Temp\User.txt
	}	

	switch -wildcard ($User_name) 
	{ 
		"*StudentCZ" { ChangePassword }
		"*StudentEN" { ChangePassword }
		"*StudentSK" { ChangePassword }
		"*Student" { ChangePassword 'Pa$$w0rd'}
		"*Administrator" { ChangePassword 'Pa$$w0rd'}
		default { ChangePassword }
	}
}

Function Add-KeyboardLanguage($lang)
{
	<#
	.SYNOPSIS
	Script na pridani vstupniho jazyka klavesnice. Prozatim Win10 only.
	
	.DESCRIPTION	
	Add language input profile.
	Usage: 
	Add-KeyboardLanguage("cs-CZ")
	 
	.PROFILE EXAMPLES
	"cs-CZ", "sk-SK", "de-DE", "fr-FR", "ru-RU"
	and more on https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs
	#>	

    if (![string]::IsNullOrEmpty($lang))
    {
        $langList = Get-WinUserLanguageList
	    $langList.Add($lang)
	    Set-WinUserLanguageList $langList -Force
    }
}