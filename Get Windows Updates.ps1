#Add servers to text file to run through updates that have installed
$Servers = Get-Content -Path C:\Users\admin-en\Documents\Servers.txt

foreach ($Server in $Servers) 
{
    #Can us the following to just get the latest install - (Get-HotFix | Sort-Object -Property InstalledOn)[-1]
    Invoke-Command -ComputerName $Server -ScriptBlock {Get-HotFix}

    #format output on screen
    Write-Output "============================================================="
}

Read-Host -Prompt "Press Enter to exit"