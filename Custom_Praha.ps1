. D:\Functions.ps1

#Tyto balicky jsou nakonfigurovane tak, ze stahuji instalacky z prahaimage, ne z internetu
Install-Choco-From-Local-Server

CHOCO-INSTALL "azure-cli"
CHOCO-INSTALL "vscode"
CHOCO-INSTALL "git"