# cisco-asa-acl-csv
Script to convert a Cisco ASA ACL/OBJECTS to CSV
###################################################


CiscoASA_MAIN_JOIN-ACL-OBJECT.ps1
- This is the MAIN script that will provide the final CSV of all ACLs with all properties expanded from the objects

CiscoASA_OBJECTS-to-CSV.ps1
- Script to convert Objects from running-config to CSV

CiscoASA_ACL-to-CSV.ps1 
- Script to convert ACLs from running-config to CSV

CiscoASA_FirewallRules_perIP.ps1
- Script to filter the MAIN output per IP and export to CSV

CiscoASA_Extract_RunningConfig.ps1
- Script to extract all Running-Config
- Calls Script to extract all Objects only from Running-Config
- Calls Script to extract all AccessLists only from Running-Config