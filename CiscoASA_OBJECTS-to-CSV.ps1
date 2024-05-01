﻿$csvData = @()
$Matches =""
$currentObject = ""
$objectFWHostname = ""
#$objectDescription = ""
$objectHostIP = ""
$objectHostSubnet = ""
$objectHostRange = ""
$objectNetworkObject = @()
$ExpandedObjectValueTemp = @()

# function to expand the value of Host Groups
function ExpandObjValue{

    param($ObjectGroupName)

    foreach ($record in $csvData) {
        if ($record.ObjectName -eq $ObjectGroupName) {
        return $record.ExpandedObjectValue
        }
    }
}

# Read the input text from a TXT file
$inputText = Get-Content -Path .\inputfile_objects.txt

# Output file
if (-not (Test-Path -Path ".\output\")) {New-Item -Path .\output -ItemType Directory -Force}
$ObjectsOutputFile = ".\output\ciscoasa_objects_outputfile_$(Get-Date -format yyyy-MM-dd-HHmmss).csv"
#$UnprocessedConfig = ".\output\ciscoasa_config_unporocessed_$(Get-Date -format yyyy-MM-dd-HHmmss).csv"

# Convert the input text into an array of lines
$lines = $inputText -split "`n"

foreach ($line in $lines) {
    
    $line = $line.Trim()

    if ($line -match "hostname (\b[\w.-]+\b)") {$objectFWHostname = $matches[1]; $matches = ""}

    if ($line -match "(object(?:-group)?) (network|service) (\b[\w.-]+\b)(?: (tcp(?:-udp)?|udp))?" -or $line -match "(object-group) (\b[\w.-]+\b)" ){
        
        if ($currentObject -ne "") {
            $csvData += $currentObject
        }
        $currentObject = [PSCustomObject]@{
            FirewallName = $objectFWHostname
            ItemDefenition = $matches[1]
            ObjectType = if (($line -split " ").Count -eq 2){"service"}else{$Matches[2]}
            ObjectName = if (($line -split " ").Count -eq 2){$matches[2]}else{$Matches[3]}
            ObjectServiceType = $matches[4]
            Description = ""
            ObjectValue = @()
            ExpandedObjectValue = @()
        }
        $matches = ""
        #$objectDescription = ""
        $objectHostIP = ""
        $objectHostSubnet = ""
        $objectHostRange = ""
        $objectNetworkObject = @()
        $ExpandedObjectValueTemp = @()

    } Else {

        # Capture the starting word of each line in the block for switching
        $lineType = ($line -split " ")[0]

        # Clear the matches before switching
        $matches = ""
        
        # Switch based on the line type
        switch ($lineType) {

            "description" {
                if ($line -match "description (.*)"){
                    $currentObject.Description = $matches[1]
                }
            }

            "host" {
                if ($line -match "host (.*)"){
                    $objectHostIP = "($($lineType)):$($matches[1])" # Ip of the Host object
                    $currentObject.ObjectValue = $objectHostIP
                    $currentObject.ExpandedObjectValue = $matches[1]
                }
            }

            "range" {
                if ($line -match "range (.+) (.+)") {
                    $objectHostRange = "($($lineType)):$($matches[1])-$($matches[2])"
                    $currentObject.ObjectValue = $objectHostRange
                    $currentObject.ExpandedObjectValue = "$($matches[1])-$($matches[2])"
                }
            }

            "subnet" {
                if ($line -match "subnet (.+) (.+)") {
                    $objectHostSubnet = "($($lineType)):$($matches[1])/$($matches[2])"
                    $currentObject.ObjectValue = $objectHostSubnet
                    $currentObject.ExpandedObjectValue = "$($matches[1])/$($matches[2])"
                }
            }

            "network-object" {
                if ($line -match "network-object (.+) (.+)") {
                    $objectNetworkObject += "($($lineType)):$($matches[1])/$($matches[2])"
                    $currentObject.ObjectValue = $objectNetworkObject -join ", `n"
                    $ExpandedObjectValueTemp += "$($matches[1])/$($matches[2])"
                    $currentObject.ExpandedObjectValue = $ExpandedObjectValueTemp -join ", `n"
                }
            }

            "group-object" {
                if ($line -match "group-object (.*)") {
                    $objectNetworkObject += "($($lineType)):$($matches[1])"
                    $currentObject.ObjectValue = $objectNetworkObject -join ", `n"
                    # Call function to expange nested group
                    $ExpandedObjectValueTemp += ExpandObjValue -ObjectGroupName $matches[1]
                    $currentObject.ExpandedObjectValue = $ExpandedObjectValueTemp -join ", `n"
                }
            }

            "service" {
                if ($line -match "service (?:(tcp(?:-udp)?|udp))? (destination|source) eq (.*)") {
                    $objectNetworkObject += "($($lineType)):$($matches[1])\$($matches[3])"
                    $ExpandedObjectValueTemp += "$($matches[1])\$($matches[3])"
                } elseif ($line -match "service (?:(tcp(?:-udp)?|udp))? (destination|source) range (.+) (.+)") {
                    $objectNetworkObject += "($($lineType)):$($matches[1])\$($matches[3])-$($matches[4])"
                    $ExpandedObjectValueTemp += "$($matches[1])\$($matches[3])-$($matches[4])"
                }
                $currentObject.ObjectValue = $objectNetworkObject -join ", `n"
                
                $currentObject.ExpandedObjectValue = $ExpandedObjectValueTemp -join ", `n"
            }

            "service-object" {
                if ($line -match "service-object (?:(tcp(?:-udp)?|udp))? (destination|source) eq (.*)") {
                    $objectNetworkObject += "($($lineType)):$($matches[1])\$($matches[3])"
                    $ExpandedObjectValueTemp += "$($matches[1])\$($matches[3])"
                } elseif ($line -match "service-object (?:(tcp(?:-udp)?|udp))? (destination|source) range (.+) (.+)") {
                    $objectNetworkObject += "($($lineType)):$($matches[1])\$($matches[3])-$($matches[4])"
                    $ExpandedObjectValueTemp += "$($matches[1])\$($matches[3])-$($matches[4])"
                } elseif ($line -match "service-object ((tcp(?:-udp)?|udp))") {
                    $objectNetworkObject += "($($lineType)):$($matches[1])"
                    $ExpandedObjectValueTemp += "$($matches[1])"
                } elseif ($line -match "service-object object(?: ([\w.-]+))?"){
                    $objectNetworkObject += "($($lineType)):$($matches[1])"
                    # Call function to expange nested group
                    $ExpandedObjectValueTemp += ExpandObjValue -ObjectGroupName $matches[1]
                }
                $currentObject.ObjectValue = $objectNetworkObject -join ", `n"
                $currentObject.ExpandedObjectValue = $ExpandedObjectValueTemp -join ", `n"
            }

            "port-object" {
                if ($line -match "port-object eq(?: ([\w.-]+))?") {
                    $objectNetworkObject += "($($lineType)):$($currentObject.ObjectServiceType)\$($matches[1])"
                    $ExpandedObjectValueTemp += "$($currentObject.ObjectServiceType)\$($matches[1])"
                } Elseif ($line -match "port-object range (.+) (.+)") {
                    $objectNetworkObject += "($($lineType)):$($currentObject.ObjectServiceType)\$($matches[1])-$($matches[2])"
                    $ExpandedObjectValueTemp += "$($currentObject.ObjectServiceType)\$($matches[1])-$($matches[2])"
                }
                $currentObject.ObjectValue = $objectNetworkObject -join ", `n"
                $currentObject.ExpandedObjectValue = $ExpandedObjectValueTemp -join ", `n"
            }

        } # Switch block

    } # Else block

} # Foreach block


# Add the last object if it's not empty
if ($currentObject -ne "") {
    $csvData += $currentObject
}

$csvData  | Export-Csv -Path $ObjectsOutputFile -NoTypeInformation

return $csvData

# SCRATCH
#$line -match "service(?:-object)? (?:(tcp(?:-udp)?|udp))? (destination|source) (eq|range)(?: (\w+)(?: (\w+))?)?")