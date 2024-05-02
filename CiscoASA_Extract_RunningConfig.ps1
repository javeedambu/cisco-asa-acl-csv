########################################################################
#
# Script Name: CiscoASA_Extract_RunningConfig.ps1
# Description: Script to extract running config from SHOW TECSUPPORT.
#
# Instrunction:
# - Invoke the script witht the parameter:
#   .\CiscoASA_Extract_RunningConfig.ps1 -filePath <specify path 
#
########################################################################

# Load function to browse file
. ".\Modules\BrowseFile.ps1"

# Check output path
if (-not (Test-Path -Path ".\Output\")) {New-Item -Path .\Output -ItemType Directory -Force}

# Specify the file path
Write-Host "`nPlease select Cisco ASA 'SHOW TECH' file`n"
if (-not ($filePath = BrowseFile)) {"No file was selcted. Exiting the script.`n"; exit}

# Define the start and end markers
$startMarker = "------------------ show running-config ------------------"
$endMarker = ": end"

# Initialise a flag to indicate when to start and stop extracting lines
$extract = $false

# Initialise a flag to store the extracted lines
$extractedLines = @()

# Read the file line by line
$rawText = Get-Content -Path $filePath
Write-host "The raw file containes $($rawText.Count) line.`n"

Get-Content -Path $filePath | ForEach-Object {

    if ($_.StartsWith("hostname ")) {
        $runningConfigFileName = "./Output/RunningConfig_$(($_ -Split " ")[1])_$(Get-Date -format yyyy-MM-dd-HHmmss).txt"
    }
    
    # Check if the current line matches the start marker
    if ($_ -eq $startMarker) { 
        # Set the flag to start extracting lines
        $extract = $true
        # Skip adding start marker to the extracted lines
        return
    }

    # Check if the current line matches the end marker
    if ($_ -eq $endMarker) { 
        # Set the flag to stop extracting lines
        $extract = $false
        # Export extracted lines and clear the variable
        $extractedLines | Out-File -FilePath $runningConfigFileName 
        Write-host "Running-Config File exported to $runningConfigFileName.`n"
        $extractedLines = @()
        # End the loop
        return
    }

    # If the flag is true, add the current line to the extracted lines
    if ($extract){
        $extractedLines += $_
    }
    
}

# Extract Running-Config Objects
& .\Modules\CiscoASA_Extract_RunningConfig_Objects.ps1 #-filePath $filePath

# Extract Running-Config Access Lists
& .\Modules\CiscoASA_Extract_RunningConfig_AccessLists.ps1 #-filePath $filePath