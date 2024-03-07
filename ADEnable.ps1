#CMil5 02/16/2024
#The main purpose of this script is to be used as a rollback from excel for my InactiveADDisable script, this script pulls from the excel output from the last script and re-enables accounts based on the excel file.

# Import necessary module
Import-Module ActiveDirectory

# Specify the path to the CSV file. Make sure to replace example csvPath with your own where you previously saved the CSV report.
$csvPath = "C:\path\to\DisabledUsersReport.csv"

# Import the CSV file to get the list of disabled users
try {
    $disabledUsers = Import-Csv -Path $csvPath
} catch {
    Write-Error "Error importing CSV file. Please ensure the path is correct and the file is not open elsewhere."
    exit
}

# Display the users to be enabled in a grid view for review and allow selection of specific users to re-enable
$selectedUsers = $disabledUsers | Out-GridView -Title "Select Users to be Enabled" -PassThru

# Check if any users were selected
if ($selectedUsers.Count -gt 0) {
    # Ask for confirmation before proceeding
    $confirmation = [System.Windows.Forms.MessageBox]::Show("Do you want to proceed with enabling the selected accounts?", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo)

    if ($confirmation -eq 'Yes') {
        $enabledUsers = @()

        foreach ($user in $selectedUsers) {
            # Enable the account
            Enable-ADAccount -Identity $user.SamAccountName

            # Optionally, you might want to update the description or perform other actions here

            # Add user to the enabled users list
            $enabledUsers += $user | Select-Object Name, SamAccountName, @{Name="EnabledDate"; Expression={Get-Date -Format "yyyy-MM-dd"}}

            # Output the action taken to the console
            Write-Output "Enabled user $($user.SamAccountName)."
        }

        # Export the list of enabled users to a new CSV file for record-keeping. Make sure to replace example exportPath with your own.
        $exportPath = "C:\path\to\EnabledUsersReport.csv"
        $enabledUsers | Export-Csv -Path $exportPath -NoTypeInformation

        [System.Windows.Forms.MessageBox]::Show("Selected accounts have been enabled, and a report has been exported to: $exportPath", "Operation Completed")
    } else {
        Write-Output "Operation cancelled by the user."
    }
} else {
    [System.Windows.Forms.MessageBox]::Show("No users were selected.", "Operation Cancelled")
}

