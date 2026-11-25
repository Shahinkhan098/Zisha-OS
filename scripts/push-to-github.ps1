param(
    [string]$CommitMessage = "chore: update Zisha OS configuration and bug fixes"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $ProjectRoot

# Normalize Linux scripts and configs to LF line endings
$linuxFiles = Get-ChildItem -Path "scripts", "config", "wifi-fix" -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -ne ".ps1" }
foreach ($f in $linuxFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName)
    $lfContent = $content -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText($f.FullName, $lfContent, (New-Object System.Text.UTF8Encoding $false))
}

$code = @'
using System;
using System.Runtime.InteropServices;
using System.Text;

public class CredHelper {
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

$Token = [CredHelper]::GetToken("git:https://github.com")
if (-not $Token) {
    Write-Error "Could not find GitHub credential in Windows Credential Manager."
    exit 1
}

git add -A
$Pending = git status --porcelain
if ($Pending) {
    git commit -m $CommitMessage
} else {
    Write-Host "[i] No new changes to commit." -ForegroundColor Yellow
}

try {
    git remote set-url origin "https://Shahinkhan098:$Token@github.com/Shahinkhan098/Zisha-OS.git"
    git push origin main
    Write-Host "[SUCCESS] Pushed updates to https://github.com/Shahinkhan098/Zisha-OS" -ForegroundColor Green
} finally {
    # Always scrub token from .git/config even if push fails
    git remote set-url origin "https://github.com/Shahinkhan098/Zisha-OS.git"
}
