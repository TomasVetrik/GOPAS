. D:\Functions.ps1
$Student = $env:computername
if ($Student -like "Dell*") 
{
    $Student = $Student.Substring($Student.length-2,2)
	$Student = "StudentSK12-"+$Student
}
# Deklarace promennych
# ------------------------
$Login = $Student+'@class.skola.cz'
$OutIdent = 'MS.Outlook:'+$Student+'@class.skola.cz@gopasskola.class.skola.cz'
$Path = Get-ScriptDirectory
$Password = 'password'
$SourcePath = $Path
$IntranetDomain = "skola.cz"
$Sites = ('shrp0110', 'shrp0210', 'office2010', 'moc10232', 'project', 'training', 'gopasskola.class')
$ScriptName = Get-ScriptName

foreach($Site in $Sites+"dc.skola.cz","skola.cz","class.skola.cz","gopasskola.class.skola.cz")
{
	Set-Credential $Site $Login $Password
}
Set-CredentialGeneric $OutIdent $Login $Password
Set-IntranetSites $IntranetDomain $Sites
Proxy-OFF
$wshell = new-object -comobject wscript.shell -erroraction stop
$wshell.popup("Pocas nastavovania nepracujte na pocitaci. Po dokonceni sa Outlook zavrie sam.",10,"Upozornenie")
ConfigureOutlookProfile -Student $Student -Domain "gopasskola.class.skola.cz" -SourcePath $SourcePath