
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "Diags - CANO - Sorint"
$form.Size = New-Object System.Drawing.Size(420,360)
$form.StartPosition = "CenterScreen"

$exportPath = "C:\Temp\EventCollector\Logs"
New-Item -ItemType Directory -Path $exportPath -Force | Out-Null

$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Style = "Continuous"
$progress.Minimum = 0
$progress.Maximum = 100
$progress.Value = 0
$progress.Size = New-Object System.Drawing.Size(360,20)
$progress.Location = New-Object System.Drawing.Point(20,240)
$form.Controls.Add($progress)

$status = New-Object System.Windows.Forms.Label
$status.Text = "Ready"
$status.Size = New-Object System.Drawing.Size(360,40)
$status.Location = New-Object System.Drawing.Point(20,270)
$form.Controls.Add($status)

# Collect Logs Button
$btnLogs = New-Object System.Windows.Forms.Button
$btnLogs.Text = "Collect Logs"
$btnLogs.Size = New-Object System.Drawing.Size(160,40)
$btnLogs.Location = New-Object System.Drawing.Point(20,20)
$form.Controls.Add($btnLogs)

$btnLogs.Add_Click({
    try {
        $progress.Value = 10
        $status.Text = "Exporting system errors..."

        Get-WinEvent -FilterHashtable @{
            LogName = 'System'
            Level = 1,2
            StartTime = (Get-Date).AddDays(-7)
        } | Select TimeCreated, Id, LevelDisplayName, ProviderName, Message |
        Export-Csv "$exportPath\SystemErrors.csv" -NoTypeInformation -Encoding UTF8

        $progress.Value = 30
        $status.Text = "Exporting driver issues..."

        Get-WinEvent -FilterHashtable @{
            LogName = 'System'
            Id = 219
            StartTime = (Get-Date).AddDays(-7)
        } | Select TimeCreated, Id, ProviderName, Message |
        Export-Csv "$exportPath\DriverFailures.csv" -NoTypeInformation -Encoding UTF8

        $progress.Value = 50
        $status.Text = "Checking reboot issues..."

        try {
            $reboots = Get-WinEvent -FilterHashtable @{
                LogName = 'System'
                Id = 41
                ProviderName = 'Microsoft-Windows-Kernel-Power'
                StartTime = (Get-Date).AddDays(-7)
            } -ErrorAction Stop

            if ($reboots.Count -gt 0) {
                $reboots | Select TimeCreated, MachineName, Message |
                Export-Csv "$exportPath\UnexpectedReboots.csv" -NoTypeInformation -Encoding UTF8
            } else {
                "No unexpected reboots detected." | Out-File "$exportPath\UnexpectedReboots.csv"
            }
        } catch {
            "No Kernel-Power reboot events found or log is inaccessible." | Out-File "$exportPath\UnexpectedReboots.csv"
        }

        $progress.Value = 70
        $status.Text = "Collecting system info..."

        systeminfo | Out-File "$exportPath\SystemInfo.txt"
        Get-ComputerInfo | Out-File "$exportPath\ComputerInfo.txt"
        Get-WmiObject Win32_DiskDrive | Out-File "$exportPath\DiskInfo.txt"

        $progress.Value = 100
        $status.Text = "Logs collected successfully."
        [System.Windows.Forms.MessageBox]::Show("Logs exported to: $exportPath", "Done", 'OK', 'Information')
    } catch {
        $status.Text = "Error during log collection."
        [System.Windows.Forms.MessageBox]::Show("An error occurred: $_", "Error", 'OK', 'Error')
    }
})

# Run SFC Button
$btnSFC = New-Object System.Windows.Forms.Button
$btnSFC.Text = "Run SFC"
$btnSFC.Size = New-Object System.Drawing.Size(160,40)
$btnSFC.Location = New-Object System.Drawing.Point(20,80)
$form.Controls.Add($btnSFC)

$btnSFC.Add_Click({
    $progress.Value = 0
    $status.Text = "Running SFC..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c sfc /scannow > `"$exportPath\SFC_Scan.txt`"" -Wait -Verb RunAs
    $progress.Value = 100
    $status.Text = "SFC completed."
    [System.Windows.Forms.MessageBox]::Show("SFC completed and saved.", "Done", 'OK', 'Information')
})

# Run CHKDSK Button
$btnCHK = New-Object System.Windows.Forms.Button
$btnCHK.Text = "Run CHKDSK"
$btnCHK.Size = New-Object System.Drawing.Size(160,40)
$btnCHK.Location = New-Object System.Drawing.Point(20,140)
$form.Controls.Add($btnCHK)

# Run Network Diagnostics Button
$btnNet = New-Object System.Windows.Forms.Button
$btnNet.Text = "Run Network Test"
$btnNet.Size = New-Object System.Drawing.Size(160,40)
$btnNet.Location = New-Object System.Drawing.Point(20,200)
$form.Controls.Add($btnNet)

$btnNet.Add_Click({
    $progress.Value = 0
    $status.Text = "Running network diagnostics..."
    try {
        ipconfig /all > "$exportPath\NetworkInfo.txt"
        
try {
    $test = Test-NetConnection -ComputerName 8.8.8.8 -Port 53 -WarningAction SilentlyContinue
    if ($test.TcpTestSucceeded) {
        "Internet connectivity confirmed to 8.8.8.8:53" | Out-File "$exportPath\InternetTest.txt"
    } else {
        "No response from 8.8.8.8 on port 53" | Out-File "$exportPath\InternetTest.txt"
    }
} catch {
    "Internet test failed: $_" | Out-File "$exportPath\InternetTest_Error.txt"
}

        $progress.Value = 100
        $status.Text = "Network diagnostics completed."
        [System.Windows.Forms.MessageBox]::Show("Network test completed and saved.", "Done", 'OK', 'Information')
    } catch {
        "Network test failed: $_" | Out-File "$exportPath\NetworkTest_Error.txt"
        $status.Text = "Network diagnostics failed."
        [System.Windows.Forms.MessageBox]::Show("Network test failed.", "Error", 'OK', 'Error')
    }
})

$btnCHK.Add_Click({
    $progress.Value = 0
    $status.Text = "Running CHKDSK..."
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c chkdsk /scan > `"$exportPath\CheckDisk.txt`"" -Wait -Verb RunAs
    $progress.Value = 100
    $status.Text = "CHKDSK completed."
    [System.Windows.Forms.MessageBox]::Show("CHKDSK completed and saved.", "Done", 'OK', 'Information')
})

$form.TopMost = $true
# Open Log Folder Button
$btnOpen = New-Object System.Windows.Forms.Button
$btnOpen.Text = "Open Log Folder"
$btnOpen.Size = New-Object System.Drawing.Size(160,40)
$btnOpen.Location = New-Object System.Drawing.Point(200,20)
$form.Controls.Add($btnOpen)

$btnOpen.Add_Click({
    if (Test-Path $exportPath) {
        Invoke-Item $exportPath
    } else {
        [System.Windows.Forms.MessageBox]::Show("Log folder not found.", "Error", 'OK', 'Error')
    }
})

[System.Windows.Forms.Application]::Run($form)
