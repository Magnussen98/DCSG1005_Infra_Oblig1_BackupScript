# Portifolio 1; Ransomware protection with PowerShell

THE GIT REPO FOR THIS PORTFOLIO 1 IS: https://gitlab.stud.iie.ntnu.no/andrefm/portifolio1

[[_TOC_]]

## Problem description / Goal of this project

I was assigned the task to write a ransomware-protection script in PowerShell. The requirments
given to me alloved me to interpret, analyse and implement the script based on my own reflection
and research. The goal of this project is to find the best-practises for ransomware protection, and being able to
implement these measures into a solid powershell script.    

## Design / Solution

I have a created a script whith multiple safety messaures for ransomware attacks. I am running my incremental backup script every 30 minutes by implementing [schedueld task.](https://docs.microsoft.com/en-us/powershell/module/scheduledtasks/start-scheduledtask?view=win10-ps) The different precautions I
have chosen to include in my script are;
1. [Controlled Folder Access](https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/enable-controlled-folders)
2. [Backup to external hardisk](https://www.computerweekly.com/feature/Top-five-ways-backup-can-protect-against-ransomware)
3. [Encryption](https://cyberx.tech/does-encryption-prevent-ransomware/) 

The first part of my script contains important variable declarations, and a function I will use multiple times. The next part 
of the script is dedicated to 'Controlled Folder Access'. My intension with this part is to ensure that 'Controlled Folder Access' is enabled and protecting my important folder. The first 'if' statement will check if 'Controlled Folder Access' is enabled. If it is disabled, the script will turn it on. The next step is to make sure that 'Powershell Core' is allowed to make changes to the protected folders. The final step of this part is to make sure that the folder I want to protect, is added to 'Controlled Folder Access'.

The main part of my script is dedicated to incremental backups. These backups will be saved to an external disk. The first lines of code will look at the folder I want a backup on, and then check when the last changes where made. This will allow me to create incremental beackups of the folder. The next part of the code will create a folder on the host machine, which will contain information about errors that may happen through the script. It will also contain a 'read-only' file which only contains the time of the last backup. I´ve tried to come up with a solution to check when the last backup was made to the external disk. I found out that the best option for me could be to save the time-date to a file. This will allow the script to only mount the disk when it´s needed. The script will then compare the last changes to the folder, with the last backup on the disk, and the decide if the incremental backup is needed or not. The next part will try to mount the external disk, if it´s unmounted. Then it checks if the disk is mounted one more time. 

Before I make a backup to the disk, I check if the disk has enough free space for the backup. If it does not, a while loop will erase the oldest backup from the disk until it´s enough space for the new backup. Then the backup is made to the external disk with the date and the time as the name of the backup. 

The last part of the script is writing an error message to a file saved on the host machine, if the disk wasn´t available for the machine.  

## Reflection on my saefty messaures
I chose to include 'Controlled Folder Acces' as a countermeasure against ransomware because this action will ensure that only [known and trusted applications](https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/controlled-folders) can access my protected folders. Every application that tries to access the folder will be checked against a list of trusted applications, resulting in minimized risk of a malicious applications trying to access and encrypt my folder. 

'Controlled Folder Access' is a preventative messaure against ransomware attacks, but it is still critical that you [backup your data](https://www.forbes.com/sites/forbestechcouncil/2020/03/18/how-to-protect-against-ransomware-in-2020/?sh=7cf177eb3417). This is because backup allows you to have a digital copy of your important files which can be used to [restore to the original content](https://learn.g2.com/what-is-backup) in case of data loss. My inital plan was to follow the [3-2-1 backup strategy](https://www.backblaze.com/blog/the-3-2-1-backup-strategy/), which will allow me to have at least three copies of my data. Two of the copies would then be stored on different storage media. One of theses copies should be stored offsite. I was therefore aiming for a solution, where I would store one of the copies in the cloud. After some research I found out that this solution would be too complicated for my script. I therefore decided to rely on [an air gap backup and recovery strategy](https://www.commvault.com/blogs/air-gapping-without-it-your-data-protection-strategy-is-at-risk). Making a backup to an external disk allows me to disconnect the disk after the backup is done. This ensures at least one backup is offline and physically seperated from my primary files. No hacker can corrupt my files, when my files are stored offline. My initial plan was also to make a seperate script where a full backup of the disk was made to another external disk. This backup was intended to run once a week. Because I had enough to work on with my final script, I decided to scratch the full-backup startegy for now. 

I have also chose to [encrypt](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cipher) my files. I used the powershell cipher algorithm, which is an EFS, or filesystem-level, encryption that enables users to encrypt induvidual files or folders. EFS encryption ties the files to the user of the machine. Which means that [other users will not have access to the encrypted files](https://www.windowscentral.com/how-use-efs-encryption-windows-10). Even though file encryption is not intendent to prevent ransomware attakcs, I chose to include it in my script because a good encryption strategy is going to prevent that my sensitve files are leaked online.  

## Discussion, incl security aspects

My script are working as indended, but it still have som improvements. I should have used bitlocker and EFS encryption together, because the [EFS encryption key is stored in the operating system,](https://www.howtogeek.com/236719/whats-the-difference-between-bitlocker-and-efs-encrypting-file-system-on-windows/) and hackers could be able to extract it. That is the reason why a full-drive encryption could be usefull as an extra messaure. My script are also relying on the external disk. If the external disk is destroyed, all of the backups will be lost. That is why the 3-2-1 backup strategy is the best option for backing up important files. 

## Conclusion and Reflection
I am overall hayppy with how this project turned out, even though my final script has some improvements. I started early by writing down thoughts on how I would like to attack this assignment, and I relfected on what kind of safety messaures I wanted to include. It didn´t take long until I realized that my inital planning was way too complicated. Therefore I had to start small, and progressively implement new meassurments. I had two versions of my script in total. The first version was dedicated to trying out different approaches, and then I cleaned up the code and refined my script in the second version. I also had a Teams meeting with a fellow student, named Kristoffer Lie, where we discussed different approaches to the script. And we discussed the best safety messaurments against attacks. Overall I am happy with how this assignment turned out.