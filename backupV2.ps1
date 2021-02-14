# I have implemented Schedueld Task with the following code:
#   Creating a task action:
#   $taskAction = New-ScheduledTaskAction `
#        -Execute 'pwsh.exe' `
#        -Argument '-File C:\Users\Admin\dcsg1005\portifolio1\backupV2.ps1'
#
#   Adding a trigger:
#   $repeat = (New-TimeSpan -Minutes 30)
#   $dt = ([DateTime]::Now)
#   $duration = $dt.AddYears(100)
#   $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionDuration $duration
#
#   Register task:
#   Register-ScheduledTask -TaskName RansomwareProtection -Action $taskAction -Trigger $trigger


$disk = 'D:\'
$backupPath = 'D:\backupFolder\'
$folder = 'C:\Users\Admin\private\'
$lastWriteTime = ( (Get-ChildItem $folder).LastWriteTime | Sort-Object -Bottom 1).ToString("dd/MM/yyyy/HH/mm")
$lastWriteTimeParent = ((Get-Item $folder).LastWriteTime).ToString("dd/MM/yyyy/HH/mm")

########################## Functions #################################################################

function Add-DirIfNoPath {
    param (
       [Parameter(Mandatory)]
       [String] $FullPath,

       [Parameter(Mandatory)]
       [ValidateSet("Directory", "File")]
       [String] $Type
    )

    if ($Type -eq "Directory"){
        if (-Not (Test-Path $FullPath) ){
            New-Item -Type Directory $FullPath
        }

    } else{
        if (-Not (Test-Path $FullPath) ){
            New-Item -Path $FullPath -ItemType "file"
        }
    }
}

############################ Controlled Folder Access ###############################################
$pwshCore = 'C:\Program Files\PowerShell\7\pwsh.exe'

$enabled = (get-MpPreference).EnableControlledFolderAccess

#Turn on 'conrolled folder acess'
if( -Not $enabled ){
    Set-MpPreference -EnableControlledFolderAccess Enabled
}

$allowedApplications = (Get-MpPreference).ControlledFolderAccessAllowedApplications
#Allow powershell core to make changes to folders which is protected by 'controlled folder access'
if ( -Not ($allowedApplications -eq $pwshCore) ){
    Add-MpPreference -ControlledFolderAccessAllowedApplications $pwshCore
}

$protectedFolders = (Get-MpPreference).ControlledFolderAccessProtectedFolders
#Add the folder I want to protect
if ( -Not ($protectedFolders -eq $folder) ) {
    Add-MpPreference -ControlledFolderAccessProtectedFolders $folder
}

########################### Encryption ########################################################

$encryptFolder = Get-ChildItem $folder

foreach ($file in $encryptFolder) {  
    if ( -Not ($file).Attributes -match "Encrypted"){
        cipher /e $file
    }
}

########################### Backup to external disk ############################################

# If a file/dir has been deleten in the subfolder. Then the "lastWriteTime" needs to be added in an extra check
if($lastWriteTime -lt $lastWriteTimeParent) {
    $lastWriteTime = $lastWriteTimeParent
}

#Call function to check path, and eventually create a dir
$feedBackFolder = $folder + "backup\"
Add-DirIfNoPath -FullPath $feedBackFolder -Type "Directory"

#Call function to check path, and eventually create a file
$lastBackupWriteTime = $feedBackFolder + "lastWriteTime.txt"
Add-DirIfNoPath -FullPath $lastBackupWriteTime -Type "File"


Set-ItemProperty $lastBackupWriteTime -Name IsReadOnly -Value $true    # Configure the access to be read-only

# Retrive the date for when the last backup on the 'D' disk happened. This date was stored on a file.
$lastBackup = Get-Content $lastBackupWriteTime

    # Check if a incremental backup is needed       -> CHANGE TO -lt for TEST PURPOSE
if ( (-Not $lastBackup) -or ($lastWriteTime -gt $lastBackup) ){


        # Try to connect to the disk if not connected
    if ( -Not (Test-Path $disk) ) {
        Get-Disk -Number 1 | Get-Partition -PartitionNumber 2 | Add-PartitionAccessPath -AccessPath $disk
    }

        # The disk is connected
    if ( Test-Path $disk ) {
        $backupSize = (Get-ChildItem $folder -Recurse | Measure-Object -Property Length -sum).Sum
        $availableDisk = (Get-PSDrive -Name D).Free

            #Check if there is avaliable space on the disk. If not, delete the oldest backup
        while ($backupSize -gt $availableDisk){
            $oldBackup = Get-ChildItem $backupPath | Sort-Object -Property LastWriteTime -Descending -bottom 1
            Remove-Item $oldBackup -Recurse

            $availableDisk = (Get-PSDrive -Name D).Free
        }

        # Call function to check if there is a directory on the disk for managing backups. If not, it will be created
        Add-DirIfNoPath -FullPath $backupPath -Type "Directory"

        $backup = $backupPath + ( Get-Date -Format dd/MM/yyyy-HH-mm)

        #Each backup will have its own folder. Call function to check for existense, and eventually create it.
        Add-DirIfNoPath -FullPath $backup -Type "Directory"

        Set-ItemProperty $lastBackupWriteTime -Name IsReadOnly -Value $false    # Allow access for write-permission
        $content = $folder + '*'
        Copy-Item $content $backup -Recurse

        #Saves the backup-date and store the info in a file. This action will overwrite the last date.
        $lastBackup = (Get-Date).ToString("dd/MM/yyyy/HH/mm")
        Write-Output $lastBackup | Out-File -FilePath $lastBackupWriteTime
        Set-ItemProperty $lastBackupWriteTime -Name IsReadOnly -Value $true     # Limit the access back to read-only

        # Was not able to connect to the disk
    } else {
        $errorText = (get-date) + "  ->  Error: Could not connect to disk: $disk"
        $errorFile = $feedBackFolder + "backupErrors.txt"

        # Call function to check if there is a file for managing disk errors. If not, it will be created
        Add-DirIfNoPath -FullPath $errorFile -Type "File"

        Write-Output $errorText | Out-File -FilePath $errorFile -Append
    }
}



