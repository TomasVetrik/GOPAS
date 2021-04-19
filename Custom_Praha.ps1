. D:\Functions.ps1

#Tyto balicky jsou nakonfigurovane tak, ze stahuji instalacky z prahaimage, ne z internetu
Install-Choco-From-Local-Server

if(((get-wmiobject win32_operatingsystem).Version | % {$_.Substring(0,2)}) -eq "10")
{
	CHOCO-INSTALL "azure-cli"
	CHOCO-INSTALL "vscode"
	CHOCO-INSTALL "git"
}

CHOCO-INSTALL "microsoft-teams"