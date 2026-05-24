$path = "C:\Users\Vert\Desktop\sbku_app\backend\sbkuapp_backend_kp.pem"
$sddl = "D:(A;;FR;;;OW)"
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class SecHelper {
    [StructLayout(LayoutKind.Sequential)]
    private struct SECURITY_DESCRIPTOR { }
    [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    private static extern bool SetFileSecurity(string lpFileName, uint SecurityInformation, IntPtr pSecurityDescriptor);
    public static void SetAcl(string path, string sddl) {
        IntPtr p = Marshal.StringToHGlobalUni(sddl);
        try {
            if (!SetFileSecurity(path, 4, p))
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
        } finally { if (p != IntPtr.Zero) Marshal.FreeHGlobal(p); }
    }
}
"@
# Verify the file still exists first
Get-Item $path | Out-Null
# Apply raw SDDL: single owner-read ACE, no flags
[SecHelper]::SetAcl($path, $sddl)
# Now check
$sd = (Get-Acl $path).Sddl
Write-Host "New SDDL: $sd"
icacls $path
