#CMil5 02/15/2024
#This scripts primary purpose is to return stale users found in AD it is currently configured to 30 days stale, however, this can be changed to 60, 90, etc. 

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create a form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Export Inactive Users'
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

# Create form controls
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Size = New-Object System.Drawing.Size(380, 20)
$label.Text = 'Enter the name for the export file and choose the location:'
$form.Controls.Add($label)

$fileNameLabel = New-Object System.Windows.Forms.Label
$fileNameLabel.Location = New-Object System.Drawing.Point(10, 60)
$fileNameLabel.Size = New-Object System.Drawing.Size(80, 20)
$fileNameLabel.Text = 'File Name:'
$form.Controls.Add($fileNameLabel)

$fileNameTextBox = New-Object System.Windows.Forms.TextBox
$fileNameTextBox.Location = New-Object System.Drawing.Point(100, 60)
$fileNameTextBox.Size = New-Object System.Drawing.Size(280, 20)
$form.Controls.Add($fileNameTextBox)

$saveLocationLabel = New-Object System.Windows.Forms.Label
$saveLocationLabel.Location = New-Object System.Drawing.Point(10, 100)
$saveLocationLabel.Size = New-Object System.Drawing.Size(80, 20)
$saveLocationLabel.Text = 'Save Location:'
$form.Controls.Add($saveLocationLabel)

$saveLocationTextBox = New-Object System.Windows.Forms.TextBox
$saveLocationTextBox.Location = New-Object System.Drawing.Point(100, 100)
$saveLocationTextBox.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($saveLocationTextBox)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(310, 100)
$browseButton.Size = New-Object System.Drawing.Size(70, 20)
$browseButton.Text = 'Browse...'
$browseButton.Add_Click({
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowserDialog.ShowDialog() -eq 'OK') {
        $saveLocationTextBox.Text = $folderBrowserDialog.SelectedPath
    }
})
$form.Controls.Add($browseButton)

$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Location = New-Object System.Drawing.Point(150, 140)
$exportButton.Size = New-Object System.Drawing.Size(100, 30)
$exportButton.Text = 'Export'
$exportButton.Add_Click({
    $fileName = $fileNameTextBox.Text
    $saveLocation = $saveLocationTextBox.Text

    if (-not [string]::IsNullOrEmpty($fileName) -and -not [string]::IsNullOrEmpty($saveLocation)) {
        $outputPath = Join-Path -Path $saveLocation -ChildPath "$fileName.csv"

        # Import the Active Directory module
        Import-Module ActiveDirectory

        # Define the number of days to consider for inactive accounts
        $daysInactive = 30

        # Calculate the inactive date threshold
        $inactiveDate = (Get-Date).AddDays(-$daysInactive)

        # Get all user accounts in Active Directory
        $users = Get-ADUser -Filter * -Properties LastLogonDate,Enabled | Where-Object { $_.Enabled -eq $true }

        # Filter inactive user accounts based on last logon date
        $inactiveUsers = $users | Where-Object { $_.LastLogonDate -lt $inactiveDate }

        # Create a custom object to store user information
        $userInfo = foreach ($user in $inactiveUsers) {
            [PSCustomObject]@{
                SamAccountName = $user.SamAccountName
                Name = $user.Name
                LastLogonDate = $user.LastLogonDate
		Manager = $user.Manager
            }
        }

        # Export the list of inactive user accounts to a CSV file
        $userInfo | Export-Csv -Path $outputPath -NoTypeInformation

        [System.Windows.Forms.MessageBox]::Show('Export completed. The list of inactive user accounts has been saved.', 'Export Inactive Users', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information)

        # Close the form
        $form.Close()
    }
    else {
        [System.Windows.Forms.MessageBox]::Show('Please enter a file name and choose a save location.', 'Export Inactive Users', 'OK', [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})
$form.Controls.Add($exportButton)

# Display the form
$form.ShowDialog() | Out-Null
