$p = "C:\Users\Vert\Desktop\sbku_app\backend\sbkuapp_backend_kp.pem"
$fs = Get-Item $p
$acl = $fs.GetAccessControl("Access")

# Remove any access rules for this SID explicitly  
$acl.Access | ForEach-Object { if ($_.IdentityReference.Value -eq "S-1-5-21-3727765307-3158816081-2652239281") { $acl.RemoveAccessRule($_) | Out-Null } }

# Re-enable inheritance, clear explicit rules
$acl.SetAccessRuleProtection($false, $false)
$fs.SetAccessControl($acl)

# Result
$final = Get-Acl $p
Write-Host "SDDL: $($final.Sddl)"
icacls $p
