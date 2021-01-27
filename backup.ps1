$todaysDate = Get-Date -Format dd/MM/yyyy-HH-mm
$EliminationDate = (Get-Date).AddMinutes(-5)
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
        throw "Du har allerede kjørt en backup"
    }
    
} else {
    Get-Volume -Drive D | Get-Partition | Remove-PartitionAccessPath -AccessPath $disk
    Write-Output "Disk Removed"
}

