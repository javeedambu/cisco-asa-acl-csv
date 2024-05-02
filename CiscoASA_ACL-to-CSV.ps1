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
. ".\Modules\CiscoASA_ACL-to-CSV_FUNCTIONS.ps1"

# Read the input text from a TXT file
$inputText = Get-Content -Path ".\Input\inputfile_ciscoasaconfig.txt"

# Import a list of patters to match and differrent fortmats of access lists
#$classList = Import-Csv .\Input\inputfile_acltype.csv

$aclPatterns = @"
matchPattern,matchName
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b Object-group \b[\w.-]+\b Object-group \b[\w.-]+\b.*,ObjectGroup-ObjectGroup-ObjectGroup
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b Object-group \b[\w.-]+\b Object \b[\w.-]+\b.*,ObjectGroup-ObjectGroup-Object
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b Object-group \b[\w.-]+\b Host \b[\w.-]+\b.*,ObjectGroup-ObjectGroup-Host
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b Object-group \b[\w.-]+\b any(?:4)?.*,ObjectGroup-ObjectGroup-Any
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b Object \b[\w.-]+\b Object-group \b[\w.-]+\b.*,ObjectGroup-Object-ObjectGroup
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b Object \b[\w.-]+\b Object \b[\w.-]+\b.*,ObjectGroup-Object-Object
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b Object \b[\w.-]+\b Host \b[\w.-]+\b.*,ObjectGroup-Object-Host
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b Object \b[\w.-]+\b any(?:4)?.*,ObjectGroup-Object-Any
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b Host \b[\w.-]+\b Object-group \b[\w.-]+\b.*,ObjectGroup-Host-ObjectGroup
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b Host \b[\w.-]+\b Object \b[\w.-]+\b.*,ObjectGroup-Host-Object
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b Host \b[\w.-]+\b Host \b[\w.-]+\b.*,ObjectGroup-Host-Host
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b Host \b[\w.-]+\b any(?:4)?.*,ObjectGroup-Host-Any
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b any(?:4)? Object-group \b[\w.-]+\b.*,ObjectGroup-Any-ObjectGroup
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b any(?:4)? Object \b[\w.-]+\b.*,ObjectGroup-Any-Object
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b any(?:4)? Host \b[\w.-]+\b.*,ObjectGroup-Any-Host
^access-list \b[\w.-]+\b extended \b[\w.-]+\b object(?:-group)? \b[\w.-]+\b any(?:4)? any(?:4)?.*,ObjectGroup-Any-Any
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b object-group \b[\w.-]+\b Object-group \b[\w.-]+\b.*,TcpUdp-ObjectGroup-ObjectGroup
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b object-group \b[\w.-]+\b Object \b[\w.-]+\b.*,TcpUdp-ObjectGroup-Object
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b object-group \b[\w.-]+\b Host \b[\w.-]+\b.*,TcpUdp-ObjectGroup-Host
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b object-group \b[\w.-]+\b any(?:4)?.*,TcpUdp-ObjectGroup-Any
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b object \b[\w.-]+\b Object-group \b[\w.-]+\b.*,TcpUdp-Object-ObjectGroup
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b object \b[\w.-]+\b Object \b[\w.-]+\b.*,TcpUdp-Object-Object
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b object \b[\w.-]+\b Host \b[\w.-]+\b.*,TcpUdp-Object-Host
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b object \b[\w.-]+\b any(?:4)?.*,TcpUdp-Object-Any
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b host \b[\w.-]+\b Object-group \b[\w.-]+\b.*,TcpUdp-Host-ObjectGroup
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b host \b[\w.-]+\b Object \b[\w.-]+\b.*,TcpUdp-Host-Object
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b host \b[\w.-]+\b Host \b[\w.-]+\b.*,TcpUdp-Host-Host
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b host \b[\w.-]+\b any(?:4)?.*,TcpUdp-Host-Any
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b any(?:4)? Object-group \b[\w.-]+\b.*,TcpUdp-Any-ObjectGroup
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b any(?:4)? Object \b[\w.-]+\b.*,TcpUdp-Any-Object
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b any(?:4)? Host \b[\w.-]+\b.*,TcpUdp-Any-Host
^access-list \b[\w.-]+\b extended \b[\w.-]+\b \b[\w.-]+\b any(?:4)? any(?:4)?.*,TcpUdp-Any-Any
"@ | ConvertFrom-Csv

# Output file
if (-not (Test-Path -Path ".\Output\")) {New-Item -Path .\Output -ItemType Directory -Force}
$AclOutputFile = ".\Output\ciscoasa_acl_outputfile_$(Get-Date -format yyyy-MM-dd-HHmmss).csv"
$UnprocessedConfig = ".\Output\ciscoasa_config_unporocessed_$(Get-Date -format yyyy-MM-dd-HHmmss).txt"

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


# Iterate though each line in the ASA config file
foreach ($line in $lines) {

    # Remove leading and trailing whitespace
    $line = $line.Trim()

    # Check if the line is an extended access list
    if ($line -match "^access-list \b[\w.-]+\b extended") {

        # Execute if its an extended access-list
        foreach ($item in $aclPatterns){

            if ($line -match $item.matchPattern.Trim()) {
            
                # Call associated function if the line matches the ACL syntax
                $AclObjects += & $item.matchName -line $line -item $item -currentAclRemark $currentAclRemark -currentFirewallName $currentFirewallName
            }
        }

        $currentAclRemark = @()

    } ElseIf ($line -match "^access-list \b[\w.-]+\b remark") {
        # If the the line is a Remark/Description then Add ACL Name and Descroption
        #currentAclName = ($line -split " ")[1]
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


# Export ACLs to CSV
# $AclObjects | Out-GridView -PassThru
$AclObjects | Export-Csv -Path $AclOutputfile -NoTypeInformation

#Export unprocessed lines to CSV
#$unprocesedLines | Where-Object {$_ -ne ''} | Out-GridView -PassThru | Export-Csv -Path $UnprocessedConfig -NoTypeInformation
$unprocesedLines | Where-Object {$_ -ne ''} | Out-File -FilePath $UnprocessedConfig

return $AclObjects