# PowerShell backup script
$Date = Get-Date -Format 'yyyy-MM-dd'
$BackupDir = Join-Path $HOME "backup_$Date"
New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
Get-ChildItem -Path . -Filter *.txt -File | Copy-Item -Destination $BackupDir -Force -ErrorAction SilentlyContinue
Write-Output "Backup completed to $BackupDir"
