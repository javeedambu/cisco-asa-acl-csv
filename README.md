# cisco-asa-acl-csv
Script to convert a Cisco ASA ACL to CSV

CiscoASA_MAIN_JOIN-ACL-OBJECT.ps1
- This is the MAIN script that will provide the final CSV of all ACLs with all properties expanded from the objects

CiscoASA_OBJECTS-to-CSV.ps1
- Script to convert Objects from config to CSV

CiscoASA_ACL-to-CSV.ps1 
- Script to extract all ACLs from the running config

CiscoASA_Extract_RunningConfig.ps1
- Script to extract all Running-Config
- Calls Script to extract all Objects only from Running-Config
- Calls Script to extract all AccessLists only from Running-Config