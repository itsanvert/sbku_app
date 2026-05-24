$path = "C:\Users\Vert\Desktop\sbku_app\backend\sbkuapp_backend_kp.pem"
$ownerSid = "S-1-5-21-3727765307-3158816081-2652239281-1001"

# Manually construct: O:1001 G:513 D:(A;;FR;;;OW)
$rawSddl = "O:$ownerSid`nG:S-1-5-21-3727765307-3158816081-2652239281-513`nD:(A;;FR;;;OW)"

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class SecHelper2 {
    [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    private static extern bool SetFileSecurity(string lpFileName, uint SecurityInformation, IntPtr pSecurityDescriptor);
    public static void SetAcl(string path, string sddl) {
        IntPtr p = Marshal.StringToHGlobalUni(sddl);
        try {
            if (!SetFileSecurity(path, 7, p))
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
        } finally { if (p != IntPtr.Zero) Marshal.FreeHGlobal(p); }
    }
}
"@
[SecHelper2]::SetAcl($path, $rawSddl)
# Verify
$new = (Get-Acl $path).Sddl
Write-Host "SDDL after raw set: $new"
icacls $path
