########################################################################
#
# Script Name: CiscoASA_ACL-to-CSV_MAIN.ps1
# Description: PowerShell script to convert Cisco ASA ACL to CSV format.
#
# Instructions:
# 1. Ensure the following files are in the same location:
#    - Main Script: CiscoASA_ACL-to-CSV_MAIN.ps1
#    - Function Script: CiscoASA_ACL-to-CSV_FUNCTIONS.ps1
#    - Input Config File: inputfile_ciscoasaconfig.txt
#    - Input ACL Type File: inputfile_acltype.csv (DO NOT MODIFY)
#    - Output File: ciscoasa_acl_outputfile_yyyy-MM-dd-HHmmss.csv
# 2. Navigate to the file location and then execute the script "CiscoASA_ACL-to-CSV_Converter.ps1"
# 3. On the GUI Grid output (filter and) select all records and click OK
# 4. The output file will be save to the running folder
#
########################################################################


# Source the functions from the external file
. ".\CiscoASA_ACL-to-CSV_FUNCTIONS.ps1"

# Import a list of patters to match and differrent classes of ACL
$classList = Import-Csv .\inputfile_acltype.csv

# Read the input text from a TXT file
$inputText = Get-Content -Path ".\inputfile_ciscoasaconfig.txt"

# Output file
if (-not (Test-Path -Path ".\output\")) {New-Item -Path .\output -ItemType Directory -Force}
$AclOutputFile = ".\output\ciscoasa_acl_outputfile_$(Get-Date -format yyyy-MM-dd-HHmmss).csv"
$UnprocessedConfig = ".\output\ciscoasa_config_unporocessed_$(Get-Date -format yyyy-MM-dd-HHmmss).csv"

# Convert the input text into an array of lines
$lines = $inputText -split "`n"


# Initialize an empty array to store ACL objects
$AclObjects = @()

# Initialize an empty array to store lines that are not processed
$unprocesedLines = @()

# Initialize variables to store current object-group information
#$currentAclName = ""
$currentAclRemark = @()
$currentFirewallName = ""
#$currentAction = ""
#$currentSrcType = ""
#$currentSrcHG = ""
#$currentSrcHGMemebers = ""
#$currentSrcIP = ""
#$currentDestType = ""
#$currentDestHG = ""
#$currentDestHGMembers = ""
#$currentDestIP = ""
#$currentServiceType = ""
#$currentServiceName = ""
#$currentServiceMembers = ""
#$currentProtocol = ""
#$currentPort = ""
#$currentPortType = ""
#$currentInterface = ""
#$currentDescription = ""



foreach ($line in $lines) {

    $line = $line.Trim()

    if ($line -match "^access-list \b[\w.-]+\b extended") {

        # Execute if its an extended access-list
        foreach ($item in $classList){

            if ($line -match $item.matchClass.Trim()) {
            
                # Call associated function if the line matches the ACL syntax
                $AclObjects += & $item.className -line $line -item $item -currentAclRemark $currentAclRemark -currentFirewallName $currentFirewallName
            }
        }

        $currentAclRemark = @()

    } ElseIf ($line -match "^access-list \b[\w.-]+\b remark") {
        # If the the line is a Remark/Description then Add ACL Name and Descroption
        $currentAclName = ($line -split " ")[1]
        $currentAclRemark += ($line -replace "access-list.*?remark ","") -join "`n"

    } Elseif ($line.StartsWith("hostname")){
        # If the line is Firewall name
        $currentFirewallName = ($line -split " ")[-1]
    
    } Else{
        # Capture unprocessed lines
        $currentAclRemark = @()
        $unprocesedLines += $line
    }

}


# Export ACLs
#$AclObjects | Out-GridView -PassThru
$AclObjects | Export-Csv -Path $AclOutputfile -NoTypeInformation

#Export unprocessed lines
$unprocesedLines | Where-Object {$_ -ne ''} | Out-GridView -PassThru | Export-Csv -Path $UnprocessedConfig -NoTypeInformation

return $AclObjects