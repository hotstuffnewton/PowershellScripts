$Servers = Get-Content C:\Users\admin-en\Desktop\servers.txt

foreach ($Server in $Servers) 
{
    Write-Host -ForegroundColor Green $Server
    $GracePeriodBefore = Invoke-Command -ComputerName $Server -ScriptBlock {(Invoke-WmiMethod -PATH (gwmi -namespace root\cimv2\terminalservices -class win32_terminalservicesetting).__PATH -name GetGracePeriodDays).daysleft}
    Write-Host -ForegroundColor Green ======================================================
    Write-Host -ForegroundColor Green 'Terminal Server (RDS) grace period Days remaining are' : $GracePeriodBefore
    Write-Host -ForegroundColor Green ======================================================  
    Write-Host -ForegroundColor Yellow "Would you like to rest the Terminal Server (RDS) grace period for $Server ? "
    $ReadHost = Read-Host " ( y / n ) "

    Switch ($ReadHost)
        {
            Y {
            Invoke-Command -ComputerName $Server -ScriptBlock {;$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod", [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership);$acl = $key.GetAccessControl();$acl.SetOwner([System.Security.Principal.NTAccount]"Administrators");$key.SetAccessControl($acl);$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("Administrators","FullControl","Allow");$acl.SetAccessRule($rule);$key.SetAccessControl($acl)}
            Write-Host -ForegroundColor DarkYellow 'Removing Registry Key'
            Invoke-Command -ComputerName $Server -ScriptBlock {Remove-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal' 'Server\RCM\GracePeriod -Name L$RTMTIMEBOMB_*}
            Write-Host -ForegroundColor DarkYellow 'Stopping Service'
            Invoke-Command -ComputerName $Server -ScriptBlock {get-service -Name "TermService" | Stop-Service -Force}
            Start-Sleep -Seconds 10 
            Write-Host -ForegroundColor DarkYellow 'Starting Service'
            Invoke-Command -ComputerName $Server -ScriptBlock {get-service -Name "TermService" | Start-Service}
            Start-Sleep -Seconds 10 
            $GracePeriodAfter = Invoke-Command -ComputerName $Server -ScriptBlock {(Invoke-WmiMethod -PATH (gwmi -namespace root\cimv2\terminalservices -class win32_terminalservicesetting).__PATH -name GetGracePeriodDays).daysleft}
            Write-Host -ForegroundColor Green $Server
            Write-Host -ForegroundColor Green ======================================================
            Write-Host -ForegroundColor Green 'Terminal Server (RDS) grace period Days remaining are' : $GracePeriodAfter
            Write-Host -ForegroundColor Green ====================================================== 
        }

        N {write-host -ForegroundColor Yellow "Skipping $Server"}

        Default {Write-Host -ForegroundColor Red "Invalid Input"}
    }
}