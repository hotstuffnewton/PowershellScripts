$Folders = Get-ChildItem -Path "E:\Backup_Data" -Name

foreach ($Folder in $Folders)
{
    if (($Folder -eq "ToDelete") -or ($Folder -eq "LocalSettings.txt"))
    {

    }
    else
    {
        $path = "E:\Backup_Data\" + $Folder + "\Data"
        Get-ChildItem -Path $path -Filter "SmallFiles*.old"
    }
}