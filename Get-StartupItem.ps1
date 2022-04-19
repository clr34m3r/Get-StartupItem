function Split-CommandLine {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$CommandLine
    )

    Begin {
        $Kernel32Definition = @'
            [DllImport("kernel32")]
            public static extern IntPtr GetCommandLineW();
            [DllImport("kernel32")]
            public static extern IntPtr LocalFree(IntPtr hMem);
'@
        $Kernel32 = Add-Type -MemberDefinition $Kernel32Definition -Name 'Kernel32' -Namespace 'Win32' -PassThru

        $Shell32Definition = @'
            [DllImport("shell32.dll", SetLastError = true)]
            public static extern IntPtr CommandLineToArgvW(
                [MarshalAs(UnmanagedType.LPWStr)] string lpCmdLine,
                out int pNumArgs);
'@
        $Shell32 = Add-Type -MemberDefinition $Shell32Definition -Name 'Shell32' -Namespace 'Win32' -PassThru

        if(!$CommandLine) {
            $CommandLine = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Kernel32::GetCommandLineW())
        }
    }

    Process {
        $ParsedArgCount = 0
        $ParsedArgsPtr = $Shell32::CommandLineToArgvW($CommandLine, [ref]$ParsedArgCount)

        Try {
            $ParsedArgs = @();

            0..$ParsedArgCount | ForEach-Object {
                $ParsedArgs += [System.Runtime.InteropServices.Marshal]::PtrToStringUni(
                    [System.Runtime.InteropServices.Marshal]::ReadIntPtr($ParsedArgsPtr, $_ * [IntPtr]::Size)
                )
            }
        }
        Finally {
            $Kernel32::LocalFree($ParsedArgsPtr) | Out-Null
        }

        $ret = @()

        # -lt to skip the last item, which is a NULL ptr
        for ($i = 0; $i -lt $ParsedArgCount; $i += 1) {
            $ret += $ParsedArgs[$i]
        }

        return $ret
    }
}

function Get-ItemInfo {
    param (
        [Parameter(Mandatory,Position=0)]
        [String]$Item
    )
    if ((($Item | Test-Path) -notcontains $false) -eq $True) {
        Get-FileHash $Item | Format-List
        Get-Item $Item -Force | Format-List
        Write-Output "---------------------------------------------------"
    }
}

function Get-StartupFolderItem {
    param (
        [Parameter(Mandatory,Position=0)]
        [String]$FolderPath
    )
    $StartupFolder = Get-ChildItem -Path $FolderPath -Exclude *.lnk,desktop.ini -Force | Select-Object -ExpandProperty Name

    $StartupFolder | ForEach-Object {
        $StartupFolderItem = $FolderPath + $_ 
        Get-ItemInfo $StartupFolderItem
    }
}


# Main script

# Check startup command
$StartupCmd = Get-CimInstance -ClassName Win32_StartupCommand -Property * | Select-Object -ExpandProperty Command

$Dir = "%windir%"
if (($null -ne ($Dir | Where-Object { $StartupCmd -match $_ })) -eq $True) {
    $FinalStartupCmd = $StartupCmd -ireplace [regex]::Escape($Dir), $Env:windir
}
else {
    $FinalStartupCmd = $StartupCmd
}

# Get file path from startup command and check info
$FinalStartupCmd | ForEach-Object {
    $Command = Split-CommandLine $_

    $Command | ForEach-Object {
        Get-ItemInfo $_
    }

    $MissedCommand = $Command[0]
    for ($i = 1; $i -lt $Command.Length; $i++) {
        if( $MissedCommand -match "\.[a-z0-9]{3}$") {
            $MissedCommand = "null"
        }
        else {
            $MissedCommand += " "
            $MissedCommand += $Command[$i]
        }
    }

    Get-ItemInfo $MissedCommand
}

# Check exe files in all-users startup folder
$StartupFolderPath = $Env:windir -ireplace [regex]::Escape("Windows"), "ProgramData\Microsoft\Windows\Start` Menu\Programs\StartUp\"

if ((($StartupFolderPath | Test-Path) -notcontains $false) -eq $True) {
    Get-StartupFolderItem $StartupFolderPath
}

# Check exe files in single-user startup folders
$UsersFolderPath = $Env:windir -ireplace [regex]::Escape("Windows"), "Users\"

if ((($UsersFolderPath | Test-Path) -notcontains $false) -eq $True) {

    $UsersFolder = Get-ChildItem -Path $UsersFolderPath -Directory -Force | Select-Object -ExpandProperty Name

    $UsersFolder | ForEach-Object {
        $UserStartupFolderPath = $UsersFolderPath + $_ + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\"

        if ((($UserStartupFolderPath | Test-Path) -notcontains $false) -eq $True) {
            Get-StartupFolderItem $UserStartupFolderPath
        }
    }
}