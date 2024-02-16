#CMil5 02/16/2024
#The main purpose of this script is to be used as a rollback from excel for my InactiveADDisable script, this script pulls from the excel output from the last script and re-enables accounts based on the excel file.

# Import necessary modules
Import-Module ActiveDirectory
Import-Module ImportExcel -ErrorAction SilentlyContinue

# Check if ImportExcel module is loaded
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Output "ImportExcel module not found. Installing now..."
    Install-Module -Name ImportExcel -Force
    Import-Module ImportExcel
}

# Specify the path to the Excel file
$excelPath = "C:\path\to\DisabledUsersReport.xlsx"

# Import the Excel file to get the list of disabled users
try {
    $disabledUsers = Import-Excel -Path $excelPath
} catch {
    Write-Error "Error importing Excel file. Please ensure the path is correct and the file is not open elsewhere."
    exit
}

# Display the users to be enabled in a grid view for review
$disabledUsers | Out-GridView -Title "Users to be Enabled - Review Before Enabling"

# Ask for confirmation before proceeding
$confirmation = [System.Windows.Forms.MessageBox]::Show("Do you want to proceed with enabling the listed accounts?", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo)

if ($confirmation -eq 'Yes') {
    $enabledUsers = @()

    foreach ($user in $disabledUsers) {
        # Enable the account
        Enable-ADAccount -Identity $user.SamAccountName

        # Optionally, you might want to update the description or perform other actions here

        # Add user to the enabled users list
        $enabledUsers += $user | Select-Object Name, SamAccountName, DisabledDate

        # Output the action taken to the console
        Write-Output "Enabled user $($user.SamAccountName)."
    }

    # Optionally, export the list of enabled users to a new Excel file for record-keeping
    $exportPath = "C:\path\to\EnabledUsersReport.xlsx"
    $enabledUsers | Export-Excel -Path $exportPath -WorksheetName "Enabled Users" -AutoSize

    [System.Windows.Forms.MessageBox]::Show("The listed accounts have been enabled, and a report has been exported to: $exportPath", "Operation Completed")
} else {
    Write-Output "Operation cancelled by the user."
}
