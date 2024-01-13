# Startup Item Checker

## Description

This PowerShell script checks and gathers information about startup items on a Windows system. It retrieves details such as file hashes and additional file information for executable files configured to run at system startup.

## Usage

### `Split-CommandLine` Function

The `Split-CommandLine` function splits a command line into individual arguments.

```powershell
Split-CommandLine -CommandLine "command arg1 arg2"
```

### `Get-ItemInfo` Function

The `Get-ItemInfo` function provides information about a given item, including file hashes and additional details.

```powershell
Get-ItemInfo -Item "C:\Path\To\File.exe"
```

### `Get-StartupFolderItem` Function

The `Get-StartupFolderItem` function checks and gathers information about executable files in a specified startup folder.

```powershell
Get-StartupFolderItem -FolderPath "C:\Path\To\Startup\Folder"
```

### Main Script

The main script checks and retrieves information about startup commands, executable files in the startup folders, and more.

```powershell
# Example: Run the main script
.\StartupItemChecker.ps1
```

## Prerequisites

- PowerShell version 5.1 or later.

## Notes

- This script checks both all-users and single-user startup folders for executable files.
- File hashes and additional information are gathered for each executable file found.

## Disclaimer

This script is provided as-is, without any warranty. Use it responsibly and at your own risk.

## Author

[Your Name]

## License

This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details.
