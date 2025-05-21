Diagnostics
Diagtool

Author: Marcelo Cano

PURPOSE:
This tool collects key diagnostics from a Windows system to assist Service Desk teams in troubleshooting performance issues, hardware failures, unexpected reboots, network problems, or corrupted system files. It is designed for use during remote support sessions or as a pre-triage diagnostic collector.

HOW TO USE:
1. Copy the entire 'EventCollector' folder to C:\\Temp
2. Run the 'ExportEvents.bat' file (double-click)
3. Accept the Administrator (UAC) prompt
4. Use the graphical interface to execute desired tasks:
   - "Collect Logs" for system events and device diagnostics
   - "Run SFC" for system file integrity check
   - "Run CHKDSK" for disk scan
   - "Run Network Test" to gather IP/DNS and verify internet reachability
   - "Open Log Folder" to view exported results

FILES GENERATED:
- SystemErrors.csv .......... Critical and Error-level events from the System log
- DriverFailures.csv ........ Detected driver issues (Event ID 219)
- UnexpectedReboots.csv ..... Unexpected shutdowns (Event ID 41 - Kernel-Power)
- SFC_Scan.txt .............. Output of 'sfc /scannow'
- CheckDisk.txt ............. Output of 'chkdsk /scan'
- NetworkInfo.txt ........... Full output of 'ipconfig /all'
- InternetTest.txt .......... Connectivity check to 8.8.8.8 on port 53
- SystemInfo.txt ............ Windows system info (hostname, OS, hardware)
- ComputerInfo.txt .......... Detailed PowerShell system inventory
- DiskInfo.txt .............. Physical disk and hardware details

REQUIREMENTS:
- Windows 10, 11 or Windows Server 2016+
- Must be run with Administrator privileges
- PowerShell 5.1 or newer (preinstalled on supported OS versions)

DISCLAIMER:
This tool is provided as-is for internal IT support use.
Use in production environments should be validated beforehand.
Created by Marcelo Cano on behalf of Sorint.

Version: 2.0 – May 2025
