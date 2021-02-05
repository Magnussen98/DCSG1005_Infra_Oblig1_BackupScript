## Til neste gang:
#   - Sjekke opp controlled folder access
#   - Fikse opp i if/else systemet. Bruke funksjon?
#   - Scheduled task
#
$disk = 'D:\'
$backupPath = 'D:\backupFolder\'  
$folder = 'C:\Users\Admin\Documents\'
$lastWriteTime = ( (Get-ChildItem $folder).LastWriteTime | Sort-Object -Bottom 1).ToString("dd/MM/yyyy/HH/mm")
$lastWriteTimeParent = ((Get-Item $folder).LastWriteTime).ToString("dd/MM/yyyy/HH/mm")

# If a file/dir has been deleten in subfolder. Then the "lastWriteTime" needs to be added in an extra check
if($lastWriteTime -lt $lastWriteTimeParent) {
    $lastWriteTime = $lastWriteTimeParent
}

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


#Call function to check path, and eventually create a dir
$feedBackFolder = $folder + "backup\"
Add-DirIfNoPath -FullPath $feedBackFolder -Type "Directory"

#Call function to check path, and eventually create a fiel
$lastBackupWriteTime = $feedBackFolder + "lastWriteTime.txt"
Add-DirIfNoPath -FullPath $lastBackupWriteTime -Type "File"



Set-ItemProperty $lastBackupWriteTime -Name IsReadOnly -Value $true    # Configure the access to be read-only        

$lastBackup = Get-Content $lastBackupWriteTime

    # Check if a backup is needed       -> CHANGE TO -lt for TEST PURPOSE
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
            $oldBackup = Get-ChildItem D:\backupFolder\ | Sort-Object -Property LastWriteTime -Descending -bottom 1
            Remove-Item $oldBackup -Recurse

            $availableDisk = (Get-PSDrive -Name D).Free
        }

        Add-DirIfNoPath -FullPath $backupPath -Type "Directory"


        #    #Check if there is a parent backupfolder
        #if ( -Not (Test-Path $backupPath) ) {
        #    New-Item -Type Directory $backupPath
        #}

        $backup = $backupPath + ( Get-Date -Format dd/MM/yyyy-HH-mm)

            #Check if there is a subfolder
        if (-Not (Test-Path $backup) ) {
            New-Item -Type Directory $backup
        } else {
            #Error i backuperror filen
        }

        Set-ItemProperty $lastBackupWriteTime -Name IsReadOnly -Value $false    # Gives access for write-permission
        Copy-Item C:\Users\Admin\Documents\* $backup -Recurse
         #Saves the backup date and store the info in a file
        $lastBackup = (Get-Date).ToString("dd/MM/yyyy/HH/mm")
        
        
        Write-Output $lastBackup | Out-File -FilePath $lastBackupWriteTime
        Set-ItemProperty $lastBackupWriteTime -Name IsReadOnly -Value $true     # Limit the access back to read-only


        # Was not able to connect to the disk
    } else {
        $errorText = (get-date) + "  ->  Error: Could not connect to disk: $disk"
        $errorFile = $feedBackFolder + "backupErrors.txt"

        #Check if the error file exist
        if (-Not (Test-Path $errorFile) ){
            New-Item -Path $feedBackFolder -Name "backupErrors.txt" -ItemType "file"
        }  

        Write-Output $errorText | Out-File -FilePath $errorFile -Append

    }
}
