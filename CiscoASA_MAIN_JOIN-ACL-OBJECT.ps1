Set-Location -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)
# Output file
if (-not (Test-Path -Path ".\output\")) {New-Item -Path .\output -ItemType Directory -Force}
$AclOutputFile = ".\output\ciscoasa_FinalACL_outputfile_$(Get-Date -format yyyy-MM-dd-HHmmss).csv"

$AclObjects = & .\CiscoASA_ACL-to-CSV.ps1
$csvData = & .\CiscoASA_OBJECTS-to-CSV.ps1

foreach ($acl in $AclObjects) {

    foreach ($csv in $csvData) {

        if ($acl.Source -eq $csv.ObjectName) {
            $acl.SourceHGMembers = $csv.ObjectValue
            $acl.SourceIP = $csv.ExpandedObjectValue
        }

        if ($acl.Destination -eq $csv.ObjectName) {
            $acl.DestinationHGMembers = $csv.ObjectValue
            $acl.DestinationIP = $csv.ExpandedObjectValue
        }

        if ($acl.ServiceName -eq $csv.ObjectName) {
            $acl.ServiceMembers = $csv.ObjectValue
            $acl.'Protocol/Port' = $csv.ExpandedObjectValue
        }
    }

}

# Export ACLs
$AclObjects | Export-Csv -Path $AclOutputfile -NoTypeInformation

# Open output folder
Invoke-Item ((Get-item $AclOutputFile).Directory)

# Open output file
Invoke-Item (Resolve-Path $AclOutputFile)