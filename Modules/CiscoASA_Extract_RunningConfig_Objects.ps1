########################################################################
#
# Script Name: CiscoASA_Extract_RunningConfig_Objects.ps1
# Description: Script to extract Objects from the from SHOW TECSUPPORT.
#
# Instrunction:
# - Invoke the script and browse to the input file.
#
########################################################################

# Load function to browse file
. ".\Modules\BrowseFile.ps1"

# Specify the file path
#Write-Host "`nPlease select Cisco ASA 'SHOW TECH' file`n"
#if (-not ($filePath = BrowseFile)) {"No file was selcted. Exiting the script.`n"; exit}

# Define the start and end markers
$startMarker = "object"
$endMarker = "access-list "

# Initialise a flag to indicate when to start and stop extracting lines
$extract = $false

# Initialise a flag to store the extracted lines
$extractedLines = @()

# Read the file line by line
Get-Content -Path $filePath | ForEach-Object {

    if ($_.StartsWith("hostname ")) {
        $runningConfigFileName = "./Output/RunningConfig_$(($_ -Split " ")[1])_Objects_$(Get-Date -format yyyy-MM-dd-HHmmss).txt"
        $extractedLines += $_
        $extractedLines | Out-File -FilePath $runningConfigFileName -Append
    }
    
    # Check if the current line matches the start marker
    if ($_.StartsWith($startMarker)) { 
        # Set the flag to start extracting lines
        $extract = $true
        $extractedLines += $_
        # Skip adding start marker to the extracted lines
        return
    }

    # Check if the current line matches the end marker
    if ($_.StartsWith($endMarker)) { 
        # Set the flag to stop extracting lines
        $extract = $false
        # Export extracted lines and clear the variable
        if ($extractedLines) {
            $extractedLines | Out-File -FilePath $runningConfigFileName -Append
            Write-host "Objects File exported to $runningConfigFileName.`n"
            $extractedLines = @()
        }
        # End the loop
        return
    }

    # If the flag is true, add the current line to the extracted lines
    if ($extract){
        $extractedLines += $_
    } Else {$extractedLines = @()}

}
