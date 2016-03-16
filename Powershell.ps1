   function Start
   {
   param( [string] $vm )
   if ($vm -eq "")
        {
          Write-Host "Enter a VM name"
        }
   if ((Get-VM $vm).powerstate -eq "PoweredOn")
        {
          Write-Host "$vm is already powered on!"
        }
   else
   {
   Start-VM -Name (Get-VM $vm) 
   Write-Host "Starting $vm"
    do
        {
         $status=(Get-VM $vm | Get-View).Guest.ToolsRunningStatus
        } until($status -eq "guestToolsRunning")
    return "Ready"
   } 

  }

 Start-VM Machine-ingrid_stoleru


function setvmRam
{
    param([string]$VMName, [int]$MemoryMB, [string]$Option)
    if($VMName -eq "")
        {
            Write-Host "Enter a VM Name"
        }
    if ($MemoryMB -eq "")
        {
            Write-Host "Enter the amount of Memory"
        }
    if ($Option -eq "")
        {
            Write-Host "Enter an option: Add or Remove Memory"
        }
    $vm = Get-VM $VMName
    if ($vm.PowerState -eq "PoweredOn")
        {
            Write-Host "The VM needs to be Powered Off to continue"
        }
    if ($Option -eq "Add")
        {
            $FinalMemory=(($vm).MemoryAssigned)/2748779 + $MemoryMB
        }
    elseif ($Option -eq "Remove")
    {
        if ($MemoryMB -ge (($vm).MemoryAssigned)/2748779)
        {
            Write-Host "You entered more memory than the amount already allocated to the VM"
        }
        $FinalMemory=(($vm).MemoryAssigned)/2748779 - $MemoryMB
    }
    $sum=[int]((Get-VM $VMName).MemoryAssigned)/2748779 + [int]$MemoryMB
    Write-Host "The amount of memory allocated at this moment is: $sum"
}
    setvmRam Machine-ingrid_stoleru 5 Add
  
 
function SetvCPU
{
   param([string]$VMName, [int]$NumCPU, [string]$Option)
   if($VMName -eq "")
         {
            Write-Host "Enter a VM Name"
        }
    if ($RAMmb -eq "")
        {
            Write-Host "Enter the amount of vCPU you want to add or remove"
        }
    if ($Option -eq "")
        {
            Write-Host "Enter an option: Add or Remove vCPU"
        }
    $vm=Get-VM $VMName
    if ($vm.PowerState -eq "PoweredOn")
        {
            Write-Host "The VM needs to be Powered Off to continue"
        } 
    if ($Option -eq "Add")
        {
           $FinalCpu=$NumCPU + ($vm).ProcessorCount
        }
    elseif ($Option -eq "Remove")
        {
             if ($NumCPU -ge ($vm).ProcessorCount)
                {
                    Write-Host "The number of vCPU's entered is greater than the ones that are currently allocated."
                }
             $FinalCpu=($vm).ProcessorCount - $NumCPU
        }
        $NumCPU
    $vm | Set-VM -ProcessorCount $FinalCpu
    Write-Host "vm: $vm"
    Write-Host "VMName: $VMName"
    Write-Host "The number of vCPU's allocated at this moment is:"(Get-VM $VMName).ProcessorCount
}
 SetvCPU Machine-ingrid_stoleru 1 Add


function revert_checkpoint
{
    param([string]$VMName, [string]$SnapshotName)
    if($VMName -eq "")
        {
            Write-Host "Enter a VM Name"
        }
    if($SnapshotName -eq "")
       {
            Write-Host "Enter a Snapshot Name"
       }
    if($SeverName -eq "")
       {
            Write-Host "Enter a Server Name"
       }
    $snap=Get-VMSnapshot $VMName
    Write-Host ($snap).Name
    Restore-VMSnapshot -VMName $VMName -Name $snap.Name -Confirm:$false -Verbose
    if ($? -ne "True")
    {
    Write-Host "Failed to revert Snapshot"
    return $False
    }
    else
    {
    Write-Host "VM Snapshot reverted"
    $retVal=$True
    }
   
}
revert_checkpoint Machine-ingrid_stoleru MyfirstCheckpoint


function exec_bash
{
param([string]$plink_location,  [string]$username, [string]$Ip_Addr, [string]$passwd, [string]$command)
    if ($plink_location -eq "")
        {
            Write-Host "Enter a Path Name"
         }
    if (-not (Test-Path $plink_location))
    {
        Write-Host "Plink.exe not found, trying to dowload"
        $WC = new-object net.webclient
        $WC.DownloadFile("http://www.chiark.greenend.org.uk/~sgtatham/putty/dowload.html")
        if (-not (Test-Path $plink_location))
            {
                Write-Host "Unable to dowload"
            }
        else
            {
                $plinkexe= Get-ChildItem $plink_location
                if ($plinkexe.Length -gt 0)
                {
                    Write-Host "Downloaded"
                }
                else
                {
                    Write-Host "Error at dowloading"
                }
            }
    } 
            if($username -eq "")
                {
                    Write-Host "Enter a username"
                }
            if($Ip_Addr -eq "")
                {
                    Write-Host "Enter an Ip_Addr"
                }
            if($passwd -eq "")
                {
                    Write-Host "Enter a password"
                }
            if($command -eq "")
                {
                    Write-Host "Enter a command"
                }
        iex "$plink_location -ssh ${username}@${Ip_Addr} -pw ${passwd} $command"  
  
}

exec_bash C:\Users\Administrator\Desktop\Script_Ingrid\plink.exe ingrid 192.168.133.114 ls

 function copy_bash
 {
    param([string]$pscp_location, [string]$path_copied_file, [string]$username, [string]$hostname, [string]$path_where_sent)
    if ($pscp_location -eq "")
        {
            Write-Host "Enter a Path Name"
        }
    if (-not (Test-Path $pscp_location))
    {
        Write-Host "pscp.exe not found, trying to dowload"
        $WC = new-object net.webclient
        $WC.DownloadFile("http://www.chiark.greenend.org.uk/~sgtatham/putty/dowload.html")
        if (-not (Test-Path $pscp_location))
            {
                Write-Host "Unable to dowload"
            }
        else
            {
                $pscpexe= Get-ChildItem $pscp_location
                if ($pscpexe.Length -gt 0)
                {
                    Write-Host "Downloaded"
                }
                else
                {
                    Write-Host "Error at dowloading"
                }
            }
    }
        if($path_copied_file -eq "")
            {
                Write-Host "Enter a path for the file you want to copy"
            }
        if($username -eq "")
            {
                Write-Host "Enter a username"
            }
        if($hostname -eq "")
             {
                Write-Host "Enter a hostname"
            }
        if($path_where_sent -eq "")
            {
                Write-Host "Enter the path of the VM"
            }
        if (-not (Test-Path $path_copied_file))
            {
                Write-Host "The path wasn't detected!"
            }
            
      C:\Users\Administrator\Desktop\Script_Ingrid\pscp ${path_copied_file} ${username}@${hostname}:${path_where_sent}
}
copy_bash C:\Users\Administrator\Desktop\Script_Ingrid C:\Users\Administrator\Desktop\Script_Ingrid\Test.txt ingrid@192.168.133.114: /home/ingrid