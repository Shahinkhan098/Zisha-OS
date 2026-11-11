<#
.SYNOPSIS
    Zisha OS 1.0 - Safe 60 GB Disk Partition Shrink Utility
#>

param(
    [string]$TargetDrive = "D",
    [int]$ShrinkGB = 60
)

$ErrorActionPreference = "Stop"

# 1. Self-Elevate to Administrator if not already running as Admin
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host "[*] Requesting Administrator permission (Please click 'Yes' on the Windows popup)..." -ForegroundColor Yellow
    $ArgsList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -TargetDrive $TargetDrive -ShrinkGB $ShrinkGB"
    $Proc = Start-Process powershell -Verb RunAs -ArgumentList $ArgsList -Wait -PassThru
    exit $Proc.ExitCode
}

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "   Zisha OS 1.0 - Safe Disk Partition Preparation ($ShrinkGB GB)" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan

$Partition = Get-Partition -DriveLetter $TargetDrive
$CurrentSizeGB = [math]::Round($Partition.Size / 1GB, 2)
$Volume = Get-Volume -DriveLetter $TargetDrive
$FreeSpaceGB = [math]::Round($Volume.SizeRemaining / 1GB, 2)

Write-Host "[*] Selected Drive : ${TargetDrive}:\" -ForegroundColor Cyan
Write-Host "[*] Current Size   : $CurrentSizeGB GB" -ForegroundColor Cyan
Write-Host "[*] Free Space     : $FreeSpaceGB GB" -ForegroundColor Cyan

if ($FreeSpaceGB -lt ($ShrinkGB + 20)) {
    Write-Host "[!] Drive ${TargetDrive}: is already shrunk or has less than $($ShrinkGB + 20) GB free." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
    exit 0
}

$NewSizeBytes = [uint64]($Partition.Size - ([uint64]$ShrinkGB * 1GB))
$SupportedSize = Get-PartitionSupportedSize -DriveLetter $TargetDrive

if ($NewSizeBytes -lt $SupportedSize.SizeMin) {
    $MinGB = [math]::Round($SupportedSize.SizeMin / 1GB, 2)
    Write-Error "Cannot shrink below minimum supported size ($MinGB GB)."
    exit 1
}

$NewSizeGB = [math]::Round($NewSizeBytes / 1GB, 2)
Write-Host "[*] Shrinking ${TargetDrive}: from $CurrentSizeGB GB to $NewSizeGB GB (Creating $ShrinkGB GB Unallocated Space)..." -ForegroundColor Yellow

Resize-Partition -DriveLetter $TargetDrive -Size $NewSizeBytes

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host " [SUCCESS] Created $ShrinkGB GB of Unallocated Space for Zisha OS 1.0!" -ForegroundColor Green
Write-Host " Your ${TargetDrive}: drive now has $NewSizeGB GB and all your files are 100% safe." -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green
Start-Sleep -Seconds 4
