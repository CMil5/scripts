#CMil5 02/15/2024
#The purpose of this script is to provide a report of users who are inactive for 90 days or more and then disable their accounts in AD. It is built to be used by HR or other end users and includes text windows with confirmation of what actions they are taking.

# Import Active Directory module
Import-Module ActiveDirectory
Import-Module ImportExcel -ErrorAction SilentlyContinue

# Check if ImportExcel module is loaded
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Output "ImportExcel module not found. Installing now..."
    Install-Module -Name ImportExcel -Force
    Import-Module ImportExcel
}

# Define the number of days of inactivity
$daysInactive = 90
$date = (Get-Date).AddDays(-$daysInactive)

# Get all AD users that have not logged in within the past 90 days, excluding disabled accounts
$inactiveUsers = Get-ADUser -Filter {(LastLogonTimeStamp -lt $date) -and (Enabled -eq $true)} -Properties LastLogonTimeStamp, Description, Name, SamAccountName

# Display inactive users in a grid view for review
$inactiveUsers | Select-Object Name, SamAccountName, @{Name="LastLogonTimeStamp"; Expression={[DateTime]::FromFileTime($_.LastLogonTimeStamp)}} | Out-GridView -Title "Inactive Users - Review Before Disabling"

# Ask for confirmation before proceeding
$confirmation = [System.Windows.Forms.MessageBox]::Show("Do you want to proceed with disabling the inactive accounts?", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo)

if ($confirmation -eq 'Yes') {
    $disabledUsers = @()

    foreach ($user in $inactiveUsers) {
        # Format the date for the description
        $disableDate = Get-Date -Format "yyyy-MM-dd"

        # Update the description to indicate the account was disabled due to inactivity
        $newDescription = "Account disabled due to inactivity on $disableDate."
        if ($user.Description) {
            $newDescription = $user.Description + " " + $newDescription
        }

        Set-ADUser -Identity $user.SamAccountName -Description $newDescription

        # Disable the account
        Disable-ADAccount -Identity $user.SamAccountName

        # Add user to the disabled users list
        $disabledUsers += $user | Select-Object Name, SamAccountName, @{Name="DisabledDate"; Expression={$disableDate}}

        # Output the action taken to the console
        Write-Output "Disabled user $($user.SamAccountName) due to inactivity."
    }

    # Export the list of disabled users to Excel. Make sure to replace example exportPath with your own where you want to save the Excel report.
    if ($disabledUsers.Count -gt 0) {
        $exportPath = "C:\path\to\DisabledUsersReport.xlsx"
        $disabledUsers | Export-Excel -Path $exportPath -WorksheetName "Disabled Users" -AutoSize

        [System.Windows.Forms.MessageBox]::Show("Inactive accounts have been disabled, and a report has been exported to: $exportPath", "Operation Completed")
    } else {
        [System.Windows.Forms.MessageBox]::Show("No accounts have been disabled.", "Operation Completed")
    }
} else {
    Write-Output "Operation cancelled by the user."
}
