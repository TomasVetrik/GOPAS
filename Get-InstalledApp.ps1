[CmdletBinding()]
param(
  [parameter(Position=0,ValueFromPipeline=$TRUE)]
    [String[]] $ComputerName=$ENV:COMPUTERNAME,
    [String] $AppID,
    [String] $AppName,
    [String] $Publisher,
    [String] $Version,
    [String] [ValidateSet("32-bit","64-bit")] $Architecture,
    [Switch] $MatchAll
)

begin {
  $HKLM = [UInt32] "0x80000002"
  $UNINSTALL_KEY = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
  $UNINSTALL_KEY_WOW = "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

  # Detect whether we are using pipeline input.
  $PIPELINEINPUT = (-not $PSBOUNDPARAMETERS.ContainsKey("ComputerName")) -and (-not $ComputerName)

  # Create a hash table containing the requested application properties.
  $PropertyList = @{}
  if ($AppID -ne "") { $PropertyList.AppID = $AppID }
  if ($AppName -ne "") { $PropertyList.AppName = $AppName }
  if ($Publisher -ne "") { $PropertyList.Publisher = $Publisher }
  if ($Version -ne "") { $PropertyList.Version = $Version }
  if ($Architecture -ne "") { $PropertyList.Architecture = $Architecture }

  # Returns $TRUE if the leaf items from both lists are equal; $FALSE otherwise.
  function compare-leafequality($list1, $list2) {
    # Create ArrayLists to hold the leaf items and build both lists.
    $leafList1 = new-object System.Collections.ArrayList
    $list1 | foreach-object { [Void] $leafList1.Add((split-path $_ -leaf)) }
    $leafList2 = new-object System.Collections.ArrayList
    $list2 | foreach-object { [Void] $leafList2.Add((split-path $_ -leaf)) }
    # If compare-object has no output, then the lists matched.
    (compare-object $leafList1 $leafList2 | measure-object).Count -eq 0
  }

  function get-installedapp2($computerName) {
    try {
      $regProv = [WMIClass] "\\$computerName\root\default:StdRegProv"

      # Enumerate HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
      # Note that this request will be redirected to Wow6432Node if running from 32-bit
      # PowerShell on 64-bit Windows.
      $keyList = new-object System.Collections.ArrayList
      $keys = $regProv.EnumKey($HKLM, $UNINSTALL_KEY)
      foreach ($key in $keys.sNames) {
        [Void] $keyList.Add((join-path $UNINSTALL_KEY $key))
      }

      # Enumerate HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
      $keyListWOW64 = new-object System.Collections.ArrayList
      $keys = $regProv.EnumKey($HKLM, $UNINSTALL_KEY_WOW)
      if ($keys.ReturnValue -eq 0) {
        foreach ($key in $keys.sNames) {
          [Void] $keyListWOW64.Add((join-path $UNINSTALL_KEY_WOW $key))
        }
      }

      # Default to 32-bit. If there are any items in $keyListWOW64, then compare the
      # leaf items in both lists of subkeys. If the leaf items in both lists match, we're
      # seeing the Wow6432Node redirection in effect and we can ignore $keyListWOW64.
      # Otherwise, we're 64-bit and append $keyListWOW64 to $keyList to enumerate both.
      $is64bit = $FALSE
      if ($keyListWOW64.Count -gt 0) {
        if (-not (compare-leafequality $keyList $keyListWOW64)) {
          $is64bit = $TRUE
          [Void] $keyList.AddRange($keyListWOW64)
        }
      }

      # Enumerate the subkeys.
      foreach ($subkey in $keyList) {
        $name = $regProv.GetStringValue($HKLM, $subkey, "DisplayName").sValue
        if ($name -eq $NULL) { continue }  # skip entry if empty display name
        $output = new-object PSObject
        $output | add-member NoteProperty "ComputerName" -value $computerName
        # $output | add-member NoteProperty "Subkey" -value (split-path $subkey -parent)  # useful when debugging
        $output | add-member NoteProperty "AppID" -value (split-path $subkey -leaf)
        $output | add-member NoteProperty "AppName" -value $name
        $output | add-member NoteProperty "Publisher" -value $regProv.GetStringValue($HKLM, $subkey, "Publisher").sValue
        $output | add-member NoteProperty "Version" -value $regProv.GetStringValue($HKLM, $subkey, "DisplayVersion").sValue
        # If subkey's name is in Wow6432Node, then the application is 32-bit. Otherwise,
        # $is64bit determines whether the application is 32-bit or 64-bit.
        if ($subkey -like "SOFTWARE\Wow6432Node\*") {
          $appArchitecture = "32-bit"
        } else {
          if ($is64bit) {
            $appArchitecture = "64-bit"
          } else {
            $appArchitecture = "32-bit"
          }
        }
        $output | add-member NoteProperty "Architecture" -value $appArchitecture

        # If no properties defined on command line, output the object.
        if ($PropertyList.Keys.Count -eq 0) {
          $output
        } else {
          # Otherwise, iterate the requested properties and count the number of matches.
          $matches = 0
          foreach ($key in $PropertyList.Keys) {
            if ($output.$key -like $PropertyList.$key) {
              $matches += 1
            }
          }
          # If all properties matched, output the object.
          if ($matches -eq $PropertyList.Keys.Count) {
            $output
            # If -matchall is missing, don't enumerate further.
            if (-not $MatchAll) { break }
          }
        }
      }
    }
    catch [System.Management.Automation.RuntimeException] {
      write-error $_
    }
  }
}

process {
  if ($PIPELINEINPUT) {
    get-installedapp2 $_
  } else {
    $ComputerName | foreach-object {
      get-installedapp2 $_
    }
  }
}
