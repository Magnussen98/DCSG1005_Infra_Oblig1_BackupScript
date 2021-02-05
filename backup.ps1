$todaysDate = Get-Date -Format dd/MM/yyyy-HH-mm
$EliminationDate = (Get-Date).Addmin(-5)
$disk = 'D:\'
$backupFolder = $disk + 'backupFolder\'
$newBackup = $backupFolder + $todaysDate

# Tester om pathen til disken eksisterer
if ( ! (Test-Path $disk) ) {
    Get-Disk -Number 1 | Get-Partition -PartitionNumber 2 | Add-PartitionAccessPath -AccessPath $disk

    #Sjekker om det finnes en backup mappe
    if ( ! (Test-Path $backupFolder)) {
        New-Item -Type Directory $backupFolder
    }

    if (! (Test-Path $newBackup)) {
        New-Item -Type Directory $newBackup
        Copy-Item C:\Users\Admin\Documents\* $newBackup -Recurse
        
        # Sletter gamle backupfiler for å ikke sprenge lagringskapasiteten på disken
        $oldBackups = Get-ChildItem D:\backupFolder\ | Where-Object {$_.LastWriteTime -lt $EliminationDate}
        foreach ($backup in $oldBackups) {
            remove-item $backup -Recurse
        }   

    } else {
        $backupVersion = $newBackup + '-V' + ( (Get-ChildItem D:\backupFolder\ | Select-Object -Property Name | Select-String -Pattern $todaysDate | Measure-Object -Line).Lines + 1)
        Write-Output $backupVersion
        New-Item -type Directory $backupVersion
        Copy-Item C:\Users\Admin\Documents\* $backupVersion -Recurse
    }
    
} else {
    Get-Volume -Drive D | Get-Partition | Remove-PartitionAccessPath -AccessPath $disk
    Write-Output "Disk Removed"
}

