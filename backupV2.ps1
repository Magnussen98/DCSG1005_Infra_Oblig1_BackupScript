## Til neste gang:
#   - Endre access Permission på "lastWrite" filen
#   - Sjekk om While løkka fungerer som den skal
#   - Sjekke opp controlled folder access
#   - Fikse opp i if/else systemet. Bruke funksjon?
#   - Scheduled task
#
$disk = 'D:\'
$backupPath = 'D:\backupFolder\'  
$folder = 'C:\Users\Admin\Documents\'
$lastWriteTime = ((Get-Item C:\Users\Admin\Documents\).LastWriteTime).ToString("dd/MM/yyyy/HH/mm")


if (-Not (Test-Path ($feedBackFolder = $folder + "backup\")) ){
    New-Item -Type Directory $feedBackFolder
}

if (-Not (Test-Path ($lastBackupWriteTime = $feedBackFolder + "lastWriteTime.txt")) ){
    New-Item -Path $feedBackFolder -Name "lastWriteTime.txt" -ItemType "file"
}

$lastBackup = Get-Content $lastBackupWriteTime

    # Check if a backup is needed
if ( (-Not $lastBackup) -or ($lastWriteTime -lt $lastBackup) ){

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
            $oldBackup = Get-ChildItem D:\backupFolder\ | Sort-Object -Property LastWriteTime -Bottom 1
            Remove-Item $oldBackup -Recurse
        }
            #Check if there is a parent backupfolder
        if ( -Not (Test-Path $backupPath) ) {
            New-Item -Type Directory $backupPath
        } else {



    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!       #Write error message her!!!!!!!!!!!!!!!!!!!!!!!!



        }

        $backup = $backupPath + ( Get-Date -Format dd/MM/yyyy-HH-mm)

            #Check if there is a subfolder
        if (-Not (Test-Path $backup) ) {
            New-Item -Type Directory $backup
        }
        
        Copy-Item C:\Users\Admin\Documents\* $backup -Recurse
         #Saves the backup date and store the info in a file
        $lastBackup = (Get-Date).ToString("dd/MM/yyyy/HH/mm")             
        Write-Output $lastBackup | Out-File -FilePath $lastBackupWriteTime


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



