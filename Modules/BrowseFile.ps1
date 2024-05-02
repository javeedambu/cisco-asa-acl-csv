
########################################################################
#
# Script Name: BrowseFile.ps1
# Description: Script to open a windows dialoge box to browse and select.
#
########################################################################

function BrowseFile {

    # Get the current directory
    $currentDirectory = Get-Location

    # Add the assembly containing the necessary .NET types
    Add-Type -AssemblyName System.Windows.Forms

    # Create an instance of the OpenFileDialog class
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog

    # Set properties of the OpenFileDialog
    $openFileDialog.Title = "Select a Cisco ASA SHOWTECH file"
    $openFileDialog.Filter = "All Files (*.*)|*.*"
    $openFileDialog.InitialDirectory = [Environment]::GetFolderPath("Desktop")
    $openFileDialog.InitialDirectory = $currentDirectory

    # Show the dialog window and check if the user clicked OK
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        # Retrieve the selected file path
        $selectedFile = $openFileDialog.FileName

        # Return selected file
        return $selectedFile
    } else {
        return $null
    }

}
