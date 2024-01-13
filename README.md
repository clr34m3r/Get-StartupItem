Project Name
Get-StartupItem

Description
This PowerShell script aims to check and gather information about startup items on a Windows system. It retrieves information about executable files configured to run at system startup, including details such as file hashes and additional file information.

Usage
Split-CommandLine Function:

The Split-CommandLine function splits a command line into individual arguments.
Example: Split-CommandLine -CommandLine "command arg1 arg2"
Get-ItemInfo Function:

The Get-ItemInfo function provides information about a given item, such as file hashes and additional details.
Example: Get-ItemInfo -Item "C:\Path\To\File.exe"
Get-StartupFolderItem Function:

The Get-StartupFolderItem function checks and gathers information about executable files in a specified startup folder.
Example: Get-StartupFolderItem -FolderPath "C:\Path\To\Startup\Folder"
Main Script:

The main script checks and retrieves information about startup commands, executable files in the startup folders, and more.
powershell
Copy code
# Example: Run the main script
.\StartupItemChecker.ps1
Prerequisites
PowerShell version 5.1 or later.
Notes
This script checks both all-users and single-user startup folders for executable files.
File hashes and additional information are gathered for each executable file found.
Disclaimer
This script is provided as-is, without any warranty. Use it responsibly and at your own risk.

Author
clr34m3r

License
This project is licensed under the MIT License - see the LICENSE.md file for details.
