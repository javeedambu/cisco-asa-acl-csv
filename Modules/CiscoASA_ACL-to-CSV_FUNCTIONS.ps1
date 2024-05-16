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


########## Variable to collate data for main ##########
Function retunVariable {

    $currentAclName = ($line -split " ")[1]
    $currentAction = ($line -split " ")[3]

    [PSCustomObject]@{
        FirewallName = $currentFirewallName
        AclName = $currentAclName
        Action = $currentAction
        SourceType =$currentSrcType
        Source = $currentSrcHG
        SourceHGMembers = $currentSrcHGMemebers
        SourceIP = $currentSrcIP
        DestinationType = $currentDestType
        Destination = $currentDestHG
        DestinationHGMembers = $currentDestHGMembers
        DestinationIP =$currentDestIP
        ServiceType = $currentServiceType
        ServiceName = $currentServiceName
        ServiceMembers = $currentServiceMembers
        Protocol = $currentProtocol
        'Protocol/Port' = If ($currentPort) {"$($currentProtocol)/$($currentPort)"}Elseif ($currentProtocol) {"$($currentProtocol)/Any"}Else {""}
        PortType = $currentPortType
        Interface = $currentInterface
        Description = $currentAclRemark -join ", `n"
        }

}


#################################################################
##########               ObjectGroup-Service             #########
#################################################################
########## object-group -> object-group -> object-group ##########
Function ObjectGroup-ObjectGroup-ObjectGroup {

    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-ObjectGroup -> (DEST)-ObjectGroup
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)object-group (7)SRC_ADDRESSES (8)Object-group (9)DEST_ADDRESSES #
    $currentSrcType = "Host/NetworkObjectGroup"
    $currentSrcHG = ($line -split " ")[7]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Host/NetworkObjectGroup"
    $currentDestHG = ($line -split " ")[9]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl
}

########## object-group -> object-group -> object ##########
Function ObjectGroup-ObjectGroup-Object {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-ObjectGroup -> (DEST)-Object
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)object-group (7)SRC_ADDRESSES (8)Object (9)DEST_ADDRESSES #
    $currentSrcType = "Host/NetworkObjectGroup"
    $currentSrcHG = ($line -split " ")[7]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""

    $currentDestType = "Host/NetworkObject"
    $currentDestHG = ($line -split " ")[9]
    $currentDestHGMembers = ""
    $currentDestIP = ""

    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""

    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl
}

########## object-group -> object-group -> host ########## 
Function ObjectGroup-ObjectGroup-Host {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-ObjectGroup -> (DEST)-Host
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)object-group (7)SRC_ADDRESSES (8)host (9)DEST_ADDRESSES #
    $currentSrcType = "Host/NetworkObjectGroup"
    $currentSrcHG = ($line -split " ")[7]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Host"
    $currentDestHG = ($line -split " ")[9]
    $currentDestHGMembers = ""
    $currentDestIP = ($line -split " ")[9]
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl
}

########## object-group -> object-group -> Any ########## 
Function ObjectGroup-ObjectGroup-Any {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-ObjectGroup -> (DEST)-Any
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)object-group (7)SRC_ADDRESSES (8)Any #
    $currentSrcType = "Host/NetworkObjectGroup"
    $currentSrcHG = ($line -split " ")[7]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Any"
    $currentDestHG = "Any"
    $currentDestHGMembers = ""
    $currentDestIP = "Any"
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl
}

##################################################################
########## object-group -> object -> object-group ##########
Function ObjectGroup-Object-ObjectGroup {

    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-Object -> (DEST)-ObjectGroup
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)object (7)SRC_ADDRESSES (8)Object-group (9)DEST_ADDRESSES #
    $currentSrcType = "Host/NetworkObject"
    $currentSrcHG = ($line -split " ")[7]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Host/NetworkObjectGroup"
    $currentDestHG = ($line -split " ")[9]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl
}

########## object-group -> object -> object ##########
Function ObjectGroup-Object-Object {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-ObjectGroup -> (DEST)-Object
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)object-group (7)SRC_ADDRESSES (8)Object (9)DEST_ADDRESSES #
    $currentSrcType = "Host/NetworkObject"
    $currentSrcHG = ($line -split " ")[7]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""

    $currentDestType = "Host/NetworkObject"
    $currentDestHG = ($line -split " ")[9]
    $currentDestHGMembers = ""
    $currentDestIP = ""

    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""

    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

}

########## object-group -> object -> host ##########
Function ObjectGroup-Object-Host {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-ObjectGroup -> (DEST)-Host
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)object-group (7)SRC_ADDRESSES (8)host (9)DEST_ADDRESSES #
    $currentSrcType = "Host/NetworkObject"
    $currentSrcHG = ($line -split " ")[7]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Host"
    $currentDestHG = ($line -split " ")[9]
    $currentDestHGMembers = ""
    $currentDestIP = ($line -split " ")[9]
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl
}

########## object-group -> object -> any ##########
Function ObjectGroup-Object-Any {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-ObjectGroup -> (DEST)-Any
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)object (7)SRC_ADDRESSES (8)Any #
    $currentSrcType = "Host/NetworkObject"
    $currentSrcHG = ($line -split " ")[7]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Any"
    $currentDestHG = "Any"
    $currentDestHGMembers = ""
    $currentDestIP = "Any"
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl
}

##################################################################
########## object-group -> Host -> object-group ##########
Function ObjectGroup-Host-ObjectGroup {

    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-Object -> (DEST)-ObjectGroup
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)Host (7)SRC_ADDRESSES (8)Object-group (9)DEST_ADDRESSES #
    $currentSrcType = "Host"
    $currentSrcHG = ($line -split " ")[7]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ($line -split " ")[7]
    
    $currentDestType = "Host/NetworkObjectGroup"
    $currentDestHG = ($line -split " ")[9]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl
}

########## object-group -> Host -> object ##########
Function ObjectGroup-Host-Object {

    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-Host-> (DEST)-Object
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)Host (7)SRC_ADDRESSES (8)Object (9)DEST_ADDRESSES #
    $currentSrcType = "Host"
    $currentSrcHG = ($line -split " ")[7]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ($line -split " ")[7]
    
    $currentDestType = "Host/NetworkObject"
    $currentDestHG = ($line -split " ")[9]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl
}

########## object-group -> Host -> Host ##########
Function ObjectGroup-Host-Host {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-ObjectGroup -> (DEST)-Host
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)host (7)SRC_ADDRESSES (8)host (9)DEST_ADDRESSES #
    $currentSrcType = "Host"
    $currentSrcHG = ($line -split " ")[7]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ($line -split " ")[7]
    
    $currentDestType = "Host"
    $currentDestHG = ($line -split " ")[9]
    $currentDestHGMembers = ""
    $currentDestIP = ($line -split " ")[9]
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

}

########## object-group -> Host -> Any ##########
Function ObjectGroup-Host-Any {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-ObjectGroup -> (DEST)-Host
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)host (7)SRC_ADDRESSES (8)host (9)DEST_ADDRESSES #
    $currentSrcType = "Host"
    $currentSrcHG = ($line -split " ")[7]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ($line -split " ")[7]
    
    $currentDestType = "Any"
    $currentDestHG = "Any"
    $currentDestHGMembers = ""
    $currentDestIP = "Any"
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

}

##################################################################
########## object-group -> Any -> object-group ##########
Function ObjectGroup-Any-ObjectGroup {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-Any -> (DEST)-ObjecteGroup
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)Any (7)object-group (8)DEST_ADDRESSES #
    $currentSrcType = "Any"
    $currentSrcHG = "Any"
    $currentSrcHGMemebers = ""
    $currentSrcIP = "Any"
    
    $currentDestType = "Host/NetworkObjectGroup"
    $currentDestHG = ($line -split " ")[8]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl
}

########## object-group -> Any -> object ##########
Function ObjectGroup-Any-Object {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-Any -> (DEST)-Host
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)Any (7)object (8)DEST_ADDRESSES #
    $currentSrcType = "Any"
    $currentSrcHG = "Any"
    $currentSrcHGMemebers = ""
    $currentSrcIP = "Any"
    
    $currentDestType = "Host/NetworkObject"
    $currentDestHG = ($line -split " ")[8]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl
}

########## object-group -> Any -> Host ##########
Function ObjectGroup-Any-Host {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-Any -> (DEST)-Host
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)Any (7)host (8)DEST_ADDRESSES #
    $currentSrcType = "Any"
    $currentSrcHG = "Any"
    $currentSrcHGMemebers = ""
    $currentSrcIP = "Any"
    
    $currentDestType = "Host"
    $currentDestHG = ($line -split " ")[8]
    $currentDestHGMembers = ""
    $currentDestIP = ($line -split " ")[8]
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl
}

########## object-group -> Any -> Any ##########
Function ObjectGroup-Any-Any {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (SERVICE)-ObjecteGroup -> (SRC)-Any -> (DEST)-Host
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)object-group (5)ALLOWED_SERVICES (6)Any (7)Any #
    $currentSrcType = "Any"
    $currentSrcHG = "Any"
    $currentSrcHGMemebers = ""
    $currentSrcIP = "Any"
    
    $currentDestType = "Any"
    $currentDestHG = "Any"
    $currentDestHGMembers = ""
    $currentDestIP = "Any"
    
    $currentServiceType = if (($line -split " ")[4] -eq "object-group"){"ServiceGroup"} else {"ServiceObject"}
    $currentServiceName = ($line -split " ")[5]
    $currentServiceMembers = ""
    
    $currentProtocol = ""
    $currentPort = ""
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl
}

#################################################################
##########              ObjectGroup-Protocol            #########
#################################################################

########## TcpUdp -> object-group -> object-group ##########
Function TcpUdp-ObjectGroup-ObjectGroup {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-Object-Group -> (DEST)-Object-Group
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)object-group (6)SRC_ADDRESSES (7)Object-group (8)DEST_ADDRESSES (9)operator/range (10)port/port #
    $currentSrcType = "Host/NetworkObjectGroup"
    $currentSrcHG = ($line -split " ")[6]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Host/NetworkObjectGroup"
    $currentDestHG = ($line -split " ")[8]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[10]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

########## TcpUdp -> object-group -> object ##########
Function TcpUdp-ObjectGroup-Object {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-Object-Group -> (DEST)-Object
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)object-group (6)SRC_ADDRESSES (7)Object (8)DEST_ADDRESSES (9)operator/range (10)port/port #
    $currentSrcType = "Host/NetworkObjectGroup"
    $currentSrcHG = ($line -split " ")[6]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Host/NetworkObject"
    $currentDestHG = ($line -split " ")[8]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[10]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

########## TcpUdp -> object-group -> host ##########
Function TcpUdp-ObjectGroup-Host {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-Object-Group -> (DEST)-Host
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)object-group (6)SRC_ADDRESSES (7)host (8)DEST_ADDRESSES (9)operator/range (10)port/port #
    $currentSrcType = "Host/NetworkObjectGroup"
    $currentSrcHG = ($line -split " ")[6]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Host"
    $currentDestHG = ($line -split " ")[8]
    $currentDestHGMembers = ""
    $currentDestIP = ($line -split " ")[8]
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[10]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

########## TcpUdp -> object-group -> any ##########
Function TcpUdp-ObjectGroup-Any {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-Object-Group -> (DEST)-Any
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)object-group (6)SRC_ADDRESSES (7)Any (8)operator/range (9)port/ports #
    $currentSrcType = "Host/NetworkObjectGroup"
    $currentSrcHG = ($line -split " ")[6]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Any"
    $currentDestHG = "Any"
    $currentDestHGMembers = ""
    $currentDestIP = "Any"
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[10]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

#################################################################

########## TcpUdp -> object -> object-group ##########
Function TcpUdp-Object-ObjectGroup {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-Object -> (DEST)-Object-Group
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)object (6)SRC_ADDRESSES (7)Object-group (8)DEST_ADDRESSES (9)operator/range (10)port/port #
    $currentSrcType = "Host/NetworkObject"
    $currentSrcHG = ($line -split " ")[6]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Host/NetworkObjectGroup"
    $currentDestHG = ($line -split " ")[8]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[10]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

########## TcpUdp -> object -> object ##########
Function TcpUdp-Object-Object {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-Object -> (DEST)-Object
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)object (6)SRC_ADDRESSES (7)Object (8)DEST_ADDRESSES (9)operator/range (10)port/port #
    $currentSrcType = "Host/NetworkObject"
    $currentSrcHG = ($line -split " ")[6]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Host/NetworkObject"
    $currentDestHG = ($line -split " ")[8]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[10]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

########## TcpUdp -> object -> host ##########
Function TcpUdp-Object-Host {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-Object -> (DEST)-Host
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)object (6)SRC_ADDRESSES (7)host (8)DEST_ADDRESSES (9)operator/range (10)port/port #
    $currentSrcType = "Host/NetworkObject"
    $currentSrcHG = ($line -split " ")[6]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Host"
    $currentDestHG = ($line -split " ")[8]
    $currentDestHGMembers = ""
    $currentDestIP = ($line -split " ")[8]
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[10]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

########## TcpUdp -> object -> any ##########
Function TcpUdp-Object-Any {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-Object -> (DEST)-Any
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)object (6)SRC_ADDRESSES (7)Any (8)operator/range (9)port/ports #
    $currentSrcType = "Host/NetworkObject"
    $currentSrcHG = ($line -split " ")[6]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ""
    
    $currentDestType = "Any"
    $currentDestHG = "Any"
    $currentDestHGMembers = ""
    $currentDestIP = "Any"
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[10]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

#################################################################
########## TcpUdp -> host -> object-group ##########
Function TcpUdp-host-ObjectGroup {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-host -> (DEST)-Object-Group
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)host (6)SRC_ADDRESSES (7)Object-group (8)DEST_ADDRESSES (9)operator/range (10)port/port #
    $currentSrcType = "Host"
    $currentSrcHG = ($line -split " ")[6]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ($line -split " ")[6]
    
    $currentDestType = "Host/NetworkObjectGroup"
    $currentDestHG = ($line -split " ")[8]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[10]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

########## TcpUdp -> host -> object ##########
Function TcpUdp-host-Object {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-host -> (DEST)-Object
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)host (6)SRC_ADDRESSES (7)Object (8)DEST_ADDRESSES (9)operator/range (10)port/port #
    $currentSrcType = "Host"
    $currentSrcHG = ($line -split " ")[6]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ($line -split " ")[6]
    
    $currentDestType = "Host/NetworkObject"
    $currentDestHG = ($line -split " ")[8]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[10]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

########## TcpUdp -> host -> host ##########
Function TcpUdp-host-Host {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-Host -> (DEST)-Host
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)host (6)SRC_ADDRESSES (7)host (8)DEST_ADDRESSES (9)operator/range (10)port/port #
    $currentSrcType = "Host"
    $currentSrcHG = ($line -split " ")[6]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ($line -split " ")[6]
    
    $currentDestType = "Host"
    $currentDestHG = ($line -split " ")[8]
    $currentDestHGMembers = ""
    $currentDestIP = ($line -split " ")[8]
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[10]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

########## TcpUdp -> host -> any ##########
Function TcpUdp-host-Any {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-Object -> (DEST)-Any
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)object (6)SRC_ADDRESSES (7)Any (8)operator/range (9)port/ports #
    $currentSrcType = "Host"
    $currentSrcHG = ($line -split " ")[6]
    $currentSrcHGMemebers = ""
    $currentSrcIP = ($line -split " ")[6]
    
    $currentDestType = "Any"
    $currentDestHG = "Any"
    $currentDestHGMembers = ""
    $currentDestIP = "Any"
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[9]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

#################################################################
########## TcpUdp -> any -> object-group ##########
Function TcpUdp-any-ObjectGroup {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-any -> (DEST)-Object-Group
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)any (6)Object-group (7)DEST_ADDRESSES (8)operator/range (9)port/port #
    $currentSrcType = "Any"
    $currentSrcHG = "Any"
    $currentSrcHGMemebers = ""
    $currentSrcIP = "Any"
    
    $currentDestType = "Host/NetworkObjectGroup"
    $currentDestHG = ($line -split " ")[7]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[9]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

########## TcpUdp -> any -> object ##########
Function TcpUdp-any-Object {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-Any -> (DEST)-Object
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)any (6)Object (7)DEST_ADDRESSES (8)operator/range (9)port/port #
    $currentSrcType = "Any"
    $currentSrcHG = "Any"
    $currentSrcHGMemebers = ""
    $currentSrcIP = "Any"
    
    $currentDestType = "Host/NetworkObject"
    $currentDestHG = ($line -split " ")[7]
    $currentDestHGMembers = ""
    $currentDestIP = ""
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[9]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

########## TcpUdp -> any -> host ##########
Function TcpUdp-Any-Host {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-Any -> (DEST)-Host
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)any (6)host (7)DEST_ADDRESSES (8)operator/range (9)port/port #
    $currentSrcType = "Any"
    $currentSrcHG = "Any"
    $currentSrcHGMemebers = ""
    $currentSrcIP = "Any"
    
    $currentDestType = "Host"
    $currentDestHG = ($line -split " ")[7]
    $currentDestHGMembers = ""
    $currentDestIP = ($line -split " ")[7]
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[9]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

########## TcpUdp -> any -> any ##########
Function TcpUdp-Any-Any {
    param ($line,$item,$currentAclRemark,$currentFirewallName)

    # (PROTOCOL)TcpUdp -> (SRC)-Any -> (DEST)-Any
    # SAMPLE ACL: (0)access-list (1)ACLNAME (2)extended (3)permit (4)tcp/udp (5)Any (6)Any (7)operator/range (8)port/ports #
    $currentSrcType = "Any"
    $currentSrcHG = "Any"
    $currentSrcHGMemebers = ""
    $currentSrcIP = "Any"
    
    $currentDestType = "Any"
    $currentDestHG = "Any"
    $currentDestHGMembers = ""
    $currentDestIP = "Any"
    
    $currentServiceType = "Protocol"
    $currentServiceName = ""
    $currentServiceMembers = ""
    
    $currentProtocol = ($line -split " ")[4]
    $currentPort = if ($line -match "^access-list .* range (\d+) (\d+)(?: eq (\w+))?") {"$($currentProtocol)\$($Matches[1])-$($Matches[2])"} else {($line -split " ")[8]}
    $currentInterface = ""

    $Acl = retunVariable

    # Return the custom object
    return $Acl

    
}

#################################################################