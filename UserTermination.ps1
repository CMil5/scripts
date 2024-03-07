# CMil5 03/07/2024
# This script is used for user termination based off a csv file.
# Define paths for user list and export files (modify as needed)
$userListPath = "C:\users.csv"
$exportPath = "C:\terminated_users.csv"

# Read users from CSV file - ensure CSV file has at least one column named Username
$usersToTerminate = Import-Csv -Path $userListPath | Select-Object -ExpandProperty Username

# Display users for confirmation in a more interactive way
$selectedUsersToTerminate = $usersToTerminate | Out-GridView -Title "Select Users to Terminate" -PassThru

# Confirmation prompt with selected users
if ($selectedUsersToTerminate.Count -gt 0) {
    Write-Host "You have selected the following users for termination:"
    $selectedUsersToTerminate | ForEach-Object { Write-Host $_ }

    $confirm = Read-Host "Are you sure you want to continue with the termination of the selected users? (Y/N)"
    
    if ($confirm -eq "Y") {
        # Initialize an empty array to store user termination details
        $terminatedUsers = @()

        foreach ($user in $selectedUsersToTerminate) {
            # Perform user termination actions here (replace with your specific steps)
            # **WARNING** This is a placeholder, modify and test actions carefully!
            # Example: Write-Host "Disabling user: $user"

            # Add user termination details to the array
            $terminatedUsers += New-Object PSObject -Property @{
                Username = $user
                TerminationDate = Get-Date -Format "yyyy-MM-dd"
            }
        }

        # Export terminated user details to a CSV file
        $terminatedUsers | Export-Csv -Path $exportPath -NoTypeInformation

        Write-Host "User termination completed and report saved to: $exportPath"
    } else {
        Write-Host "User termination cancelled."
    }
} else {
    Write-Host "No users were selected for termination."
}

