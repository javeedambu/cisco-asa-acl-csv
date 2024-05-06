########################################################################
#
# Script Name: CiscoASA_MAIN_JOIN-ACL-OBJECT.ps1
# Description: Script to convert Cisco ASA exteded access lists to CSV.
# This is the Main script. This will execute two scripts.
# First one will extract all ACLs and second will extract all Objects.
# The script will then merge both output.
#
# Instructions:
# 1. Ensure the following files are in the same location:
#    - Main Script          : CiscoASA_MAIN_JOIN-ACL-OBJECT.ps1
#    - ACL Script           : CiscoASA_ACL-to-CSV_MAIN.ps1
#    - ACL Function Script  : CiscoASA_ACL-to-CSV_FUNCTIONS.ps1
#    - Object Script        : CiscoASA_OBJECTS-to-CSV.ps1
#    - Input Config File    : inputfile_ciscoasaconfig.txt
#    - Input ACL Type File  : inputfile_acltype.csv (DO NOT MODIFY)
#    - Output File          : ciscoasa_MAIN_outputfile_yyyy-MM-dd-HHmmss.csv
# 2. Execute the script "CiscoASA_MAIN_JOIN-ACL-OBJECT.ps1"
# 3. On the GUI Grid output (filter and) select all records and click OK
# 4. The output file will be save to the "./output"
#   - MAIN CSV      : ciscoasa_MAIN_outputfile_<date/time_stamp>.csv
#   - Objects CSV   : ciscoasa_objects_outputfile_<date/time_stamp>.csv
#   - ACL CSV       : ciscoasa_acl_outputfile_<date/time_stamp>.csv
#
########################################################################

# Change the execution path to the script location 
Set-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)

# Output file variable
if (-not (Test-Path -Path ".\Output\")) {New-Item -Path .\Output -ItemType Directory -Force}
$AclOutputFile = ".\Output\ciscoasa_MAIN_outputfile_$(Get-Date -format yyyy-MM-dd-HHmmss).csv"

# Execute the ACL extraction script
Write-Host "..... Converting AccessLists to CSV ....."
$AclObjects = & .\CiscoASA_ACL-to-CSV.ps1

# Execute the OBJECT extraction script
Write-Host "..... Converting Objects to CSV ....."
$csvData = & .\CiscoASA_OBJECTS-to-CSV.ps1

# Expand the Services, Sources and Destinations within each ACLs by referring to the Object list.
Write-Host "..... Expanding Objects in the AccessLists ....."

# Iterate though each ACLs
foreach ($acl in $AclObjects) {

    # Iterate though each Objects
    foreach ($csv in $csvData) {

        # Expand Source Object names to IPs
        if ($acl.Source -eq $csv.ObjectName) {
            $acl.SourceHGMembers = $csv.ObjectValue
            $acl.SourceIP = $csv.ExpandedObjectValue
        }

        # Expand Destination Object names to IPs
        if ($acl.Destination -eq $csv.ObjectName) {
            $acl.DestinationHGMembers = $csv.ObjectValue
            $acl.DestinationIP = $csv.ExpandedObjectValue
        }

        # Expand Service names to protocols and ports
        if ($acl.ServiceName -eq $csv.ObjectName) {
            $acl.ServiceMembers = $csv.ObjectValue
            $acl.'Protocol/Port' = $csv.ExpandedObjectValue
        }
    }

}

# Export FINAL list of ACLs
Write-Host "..... Exporting final output to CSV ....."
$AclObjects | Export-Csv -Path $AclOutputfile -NoTypeInformation

# Open the output folder
Invoke-Item ((Get-item $AclOutputFile).Directory)

# Open the output file
Write-Host "..... Opening the exported CSV ....."
Invoke-Item (Resolve-Path $AclOutputFile)