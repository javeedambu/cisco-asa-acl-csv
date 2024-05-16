$filterIPs = @(
"55.0.0.10",
"75.0.0.10"
)

# Change the execution path to the script location 
Set-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

# Check output path
if (-not (Test-Path -Path ".\Output\")) {New-Item -Path .\Output -ItemType Directory -Force}
if (-not (Test-Path -Path ".\Output\RulesPerIPs")) {New-Item -Path .\Output\RulesPerIPs -ItemType Directory -Force}
$FwRuleOutputFile = ".\Output\RulesPerIPs\"

# Load function to browse file
. ".\Modules\BrowseFile.ps1"

# Specify the file path
Write-Host "`nPlease select 'MAIN' CSV output file :`n"
if (-not ($filePath = BrowseFile)) {"No file was selcted. Exiting the script.`n"; exit}

# Read the file line by line
$Data = Import-Csv $filePath
Write-host "The raw file containes $($Data.Count) line.`n"

# Initialize an empty array to store matching lines
$matchingLines = @()
$matchingLinesSource = @()
$matchingLinesDestination = @()

# Loop through each SourceIP address
foreach ($IP in $filterIPs) {
    Write-Host "$(Get-Date) ..... Creating CSV for $($IP) ....."
    # Filter the lines based on the current SourceIP
    $matchingLinesSource += $data | Where-Object { $_.SourceIP -like "*$IP*" } | Select-Object FirewallName,@{n="SourceIP";e={$IP}}, DestinationIP,'Protocol/Port'
    $matchingLinesDestination += $data | Where-Object { $_.DestinationIP -like "*$IP*" } | Select-Object FirewallName,SourceIP, @{n="DestinationIP";e={$IP}},'Protocol/Port'
    $matchingLines = $matchingLinesSource + $matchingLinesDestination
    $matchingLines | Export-Csv "$($FwRuleOutputFile)$($IP)_$(Get-Date -format yyyy-MM-dd-HHmmss).csv" -NoTypeInformation
    $matchingLines = @()
    $matchingLinesSource = @()
    $matchingLinesDestination = @()
}

# Export the matching lines to a new CSV file
$matchingLines | Select-Object FirewallName,SourceIP, DestinationIP,'Protocol/Port' | Export-Csv c:\temp\falls.csv -NoTypeInformation
