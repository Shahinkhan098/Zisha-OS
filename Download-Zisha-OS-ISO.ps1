<#
.SYNOPSIS
    Zisha OS 1.0 - Direct Automated ISO Downloader & Extractor to E:\Zisha-OS-Installer
#>

$ErrorActionPreference = "Stop"
$OutDir = "E:\Zisha-OS-Installer"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "   Zisha OS 1.0 - Automated ISO Downloader to E:\Zisha-OS-Installer" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Cyan

# 1. Download Rufus Portable to E:\Zisha-OS-Installer
$RufusPath = Join-Path $OutDir "rufus-4.6p.exe"
if (-not (Test-Path $RufusPath)) {
    Write-Host "[1/4] Downloading Rufus Portable to $RufusPath ..." -ForegroundColor Yellow
    curl.exe -L -s "https://github.com/pbatard/rufus/releases/download/v4.6/rufus-4.6p.exe" -o "$RufusPath"
} else {
    Write-Host "[1/4] Rufus Portable already exists at $RufusPath" -ForegroundColor Green
}

# 2. Read saved GitHub credential from Windows Credential Manager
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
    Write-Error "Could not find saved GitHub credential in Windows Credential Manager."
    exit 1
}

$Headers = @{
    "Authorization" = "Bearer $Token"
    "Accept"        = "application/vnd.github+json"
    "User-Agent"    = "Zisha-OS-Downloader"
}

Write-Host "[2/4] Finding latest Zisha OS 1.0 ISO artifact on GitHub..." -ForegroundColor Yellow
$ArtifactsResp = Invoke-RestMethod -Uri "https://api.github.com/repos/Shahinkhan098/Zisha-OS/actions/artifacts" -Headers $Headers
$IsoArtifact = $ArtifactsResp.artifacts | Where-Object { $_.name -eq "zisha-os-1.0-amd64-iso" -and -not $_.expired } | Select-Object -First 1

if (-not $IsoArtifact) {
    Write-Error "No active zisha-os-1.0-amd64-iso artifact found on GitHub."
    exit 1
}

$SizeMB = [math]::Round($IsoArtifact.size_in_bytes / 1MB, 2)
$DownloadUrl = $IsoArtifact.archive_download_url
$ZipPath = Join-Path $OutDir "zisha-os-1.0-amd64-iso.zip"

Write-Host "[3/4] Downloading $($IsoArtifact.name) ($SizeMB MB) to: $ZipPath" -ForegroundColor Cyan
Write-Host "      Please wait while the 2.75 GB ISO downloads to E:\Zisha-OS-Installer..." -ForegroundColor Yellow

curl.exe -L --progress-bar -H "Authorization: Bearer $Token" -H "Accept: application/vnd.github+json" "$DownloadUrl" -o "$ZipPath"

Write-Host ""
Write-Host "[4/4] Extracting zisha-os-1.0-amd64.iso into $OutDir ..." -ForegroundColor Cyan
Expand-Archive -Path $ZipPath -DestinationPath $OutDir -Force

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Green
Write-Host " [SUCCESS] Zisha OS 1.0 ISO & Rufus are ready in: $OutDir" -ForegroundColor Green
Write-Host "======================================================================" -ForegroundColor Green

explorer.exe $OutDir
