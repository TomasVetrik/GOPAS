. D:\Functions.ps1 
while($true)
{	
    $VideoController = Get-WmiObject -class "Win32_VideoController"
    $dx = $VideoController.CurrentHorizontalResolution/2
    $dy = ($VideoController.CurrentVerticalResolution/2)+20
    $Pos = [System.Windows.Forms.Cursor]::Position
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point((($Pos.X) + 1) , $Pos.Y)    
    [W.U32]::mouse_event(0x02 -bor 0x04 -bor 0x8000 -bor 0x01, .1*65535, .1 *65535, 0, 0);
    MouseClick $dx $dy
    MouseClick $dx $dy
    write-host $dx $dy	
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