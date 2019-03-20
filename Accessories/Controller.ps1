while($true)
{
    $Process=(Get-Process | where {$_.name -eq "rundll32"})	
    if($Process -ne $null)
	{
		Start-Sleep -Seconds 2
	    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
	    [Microsoft.VisualBasic.Interaction]::AppActivate($Process.Id)
	    [void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")	
        Start-Sleep -Seconds 2
	    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
	    [Microsoft.VisualBasic.Interaction]::AppActivate($Process.Id)
	    [void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")		
	    [System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
	    Start-Sleep -Seconds 2	
	    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
	    [Microsoft.VisualBasic.Interaction]::AppActivate($Process.Id)
	    [void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")		
	    [System.Windows.Forms.SendKeys]::SendWait("{DOWN}")
	    Start-Sleep -Seconds 2	
	    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
	    [Microsoft.VisualBasic.Interaction]::AppActivate($Process.Id)
	    [void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")		
	    [System.Windows.Forms.SendKeys]::SendWait("{UP}")
        Start-Sleep -Seconds 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
	    [Microsoft.VisualBasic.Interaction]::AppActivate($Process.Id)
	    [void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")		
	    [System.Windows.Forms.SendKeys]::SendWait("{RIGHT}")
	    Start-Sleep -Seconds 2
        [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
	    [Microsoft.VisualBasic.Interaction]::AppActivate($Process.Id)
	    [void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")		
	    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    }
	Start-Sleep -Seconds 2
}