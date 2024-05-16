# Sample table with duplicate rows
$table = @"
ID,Name,Value
1,John,100
2,Alice,200
3,John,100
4,Bob,150
"@

# Convert the table to objects
$objects = $table | ConvertFrom-Csv

# Group the objects by all properties except ID
$groupedObjects = $objects | Group-Object -Property Name, Value | ForEach-Object { $_.Group[0] }

# Display the unique objects
$groupedObjects
