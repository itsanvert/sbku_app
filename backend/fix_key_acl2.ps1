$path  = "C:\Users\Vert\Desktop\sbku_app\backend\sbkuapp_backend_kp.pem"
$ownerSid = "S-1-5-21-3727765307-3158816081-2652239281-1001"

# Desired SDDL: Owner=user, Group=None, DACL with a single ACE (owner read)
$newSddl = "O:$ownerSid`nG:ND`nD:(A;;FR;;;OW)"

# Rebuild via .NET FileSecurity
$fs = Get-Item $path
$acl = $fs.GetAccessControl("Access")   # map existing owner from disk object
# $acl.Owner = "VERT\Vert"  # keep existing (already matches $ownerSid)
# Clear current rules and add only the owner-read ACE
$acl.SetAccessRuleProtection($true, $false)  # protect=true, preserve=false
$acl.Access | Where-Object { $_.IdentityReference -ne '' } | ForEach-Object { $acl.RemoveAccessRule($_) | Out-Null }
$fs.SetAccessControl($acl)

# Now apply the raw SDDL override
$sd = New-Object System.Security.SecurityDescriptor
$sd.SetSecurityDescriptorSddlForm($newSddl)
$acl_sd = Get-Item $path
$acl_sd.SetAccessControl($acl)
$acl_sd.SetAccessControl($null)
# Use SetNamedSecurityInfo via P/Invoke approach
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class AclHelper {
    [StructLayout(LayoutKind.Sequential)]
    public struct SECURITY_DESCRIPTOR { }
    [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern bool SetFileSecurity(string lpFileName, uint SecurityInformation, IntPtr pSecurityDescriptor);
    [DllImport("advapi32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern bool GetFileSecurity(string lpFileName, uint SecurityInformation, IntPtr pSecurityDescriptor, uint nLength, out uint lpnLengthNeeded);
    public const uint DACL_SECURITY_INFORMATION = 0x00000004;
    public const uint OWNER_SECURITY_INFORMATION = 0x00000001;
    public static void SetAcl(string path, string sddl) {
        IntPtr sd = IntPtr.Zero;
        try {
            sd = Marshal.StringToHGlobalUni(sddl);
            if (!SetFileSecurity(path, DACL_SECURITY_INFORMATION | OWNER_SECURITY_INFORMATION, sd))
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
        } finally {
            if (sd != IntPtr.Zero) Marshal.FreeHGlobal(sd);
        }
    }
}
"@
[AclHelper]::SetAcl($path, $newSddl)
# Final display
icacls $path
