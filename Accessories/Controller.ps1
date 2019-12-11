. D:\Functions.ps1 
Add-Type -AssemblyName System.Windows.Forms
while($true)
{	          
    $Process=(Get-Process | where {$_.name -eq "rundll32"})	          
    if($Process -ne $null)
	{
        $Monitors = [System.Windows.Forms.Screen]::AllScreens
        foreach ($Monitor in $Monitors)
        {	
        	$dx = $Monitor.bounds.Width/2
        	$dy = ($Monitor.bounds.Height/2)+10
            break
        }   
        if($dx -eq $null)
        {
            $dx = 1260
            $dy = 560
        }
       
        write-host $dx $dy
        [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point((($dx) + 1) , $dy.Y)    
        [W.U32]::mouse_event(0x02 -bor 0x04 -bor 0x8000 -bor 0x01, .1*65535, .1 *65535, 0, 0);             
        MouseClick $dx $dy  
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