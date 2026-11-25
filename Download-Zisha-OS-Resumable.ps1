<#
.SYNOPSIS
    Zisha OS 1.0 - Resumable & Reliable Direct ISO Downloader
.DESCRIPTION
    Uses GitHub API with authentication to get a fresh download stream,
    and runs curl with automatic retries and resume support (-C -)
    so downloads never fail midway even on fluctuating connections.
#>

$ErrorActionPreference = "Stop"
$OutDir = "E:\Zisha-OS-Installer"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "   Zisha OS 1.0 — Reliable Resumable ISO Downloader (3.5 GB)" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan

# 1. Read GitHub token from Windows Credential Manager
$code = @'
using System;
using System.Runtime.InteropServices;
using System.Text;

public class CredReader {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct CREDENTIAL {
        public uint Flags;
        public uint Type;
        public string TargetName;
        public string Comment;
        public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten;
        public uint CredentialBlobSize;
        public IntPtr CredentialBlob;
        public uint Persist;
        public uint AttributeCount;
        public IntPtr Attributes;
        public string TargetAlias;
        public string UserName;
    }

    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    public static extern bool CredRead(string target, uint type, int reservedFlag, out IntPtr credentialPtr);

    [DllImport("advapi32.dll", SetLastError = true)]
    public static extern void CredFree([In] IntPtr cred);

    public static string GetToken(string target) {
        IntPtr credPtr;
        if (CredRead(target, 1, 0, out credPtr)) {
            CREDENTIAL cred = (CREDENTIAL)Marshal.PtrToStructure(credPtr, typeof(CREDENTIAL));
            byte[] passwordBytes = new byte[cred.CredentialBlobSize];
            Marshal.Copy(cred.CredentialBlob, passwordBytes, 0, (int)cred.CredentialBlobSize);
            CredFree(credPtr);
            return Encoding.UTF8.GetString(passwordBytes).Replace("\0", "");
        }
        return null;
    }
}
'@
Add-Type -TypeDefinition $code

$Token = [CredReader]::GetToken("git:https://github.com")
if (-not $Token) {
    Write-Error "Could not find GitHub credential in Windows Credential Manager."
    exit 1
}

$Headers = @{
    "Authorization" = "Bearer $Token"
    "Accept"        = "application/vnd.github+json"
    "User-Agent"    = "Zisha-OS-Downloader"
}

Write-Host "[1/3] Fetching latest Zisha OS (Wi-Fi 6 & All Tools) artifact..." -ForegroundColor Yellow
$ArtifactsResp = Invoke-RestMethod -Uri "https://api.github.com/repos/Shahinkhan098/Zisha-OS/actions/artifacts" -Headers $Headers
$IsoArtifact = $ArtifactsResp.artifacts | Where-Object { $_.name -eq "zisha-os-1.0-amd64-iso" -and -not $_.expired } | Select-Object -First 1

if (-not $IsoArtifact) {
    Write-Error "No active zisha-os-1.0-amd64-iso artifact found on GitHub."
    exit 1
}

$SizeMB = [math]::Round($IsoArtifact.size_in_bytes / 1MB, 2)
$SizeGB = [math]::Round($IsoArtifact.size_in_bytes / 1GB, 2)
$DownloadUrl = $IsoArtifact.archive_download_url
$ZipPath = Join-Path $OutDir "zisha-os-1.0-amd64-iso.zip"

Write-Host "[2/3] Downloading $SizeMB MB ($SizeGB GB) to: $ZipPath" -ForegroundColor Cyan
Write-Host "      Auto-retry & resume enabled. If internet drops, it will safely continue..." -ForegroundColor Yellow

# Use curl with:
# -L : Follow redirects
# --retry 20 : Retry up to 20 times on network failure
# --retry-delay 3 : Wait 3s between retries
# -C - : Automatically resume transfer if partially downloaded
curl.exe -L --retry 20 --retry-delay 3 --retry-all-errors -C - --progress-bar `
    -H "Authorization: Bearer $Token" `
    -H "Accept: application/vnd.github+json" `
    "$DownloadUrl" -o "$ZipPath"

Write-Host ""
Write-Host "[3/3] Extracting zisha-os-1.0-amd64.iso into $OutDir ..." -ForegroundColor Cyan
Expand-Archive -Path $ZipPath -DestinationPath $OutDir -Force

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host " [SUCCESS] Zisha OS 1.0 (3.5 GB) is downloaded & extracted successfully!" -ForegroundColor Green
Write-Host " Location: $OutDir\zisha-os-1.0-amd64.iso" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green

explorer.exe $OutDir
