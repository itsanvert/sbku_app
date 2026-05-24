$p = "C:\Users\Vert\Desktop\sbku_app\backend\sbkuapp_backend_kp.pem"
$fs = Get-Item $p
$acl = $fs.GetAccessControl("Access")

# Reset: inherit from parent, clear all explicit ACEs (drops the "bad" R,S entry)
$acl.SetAccessRuleProtection($false, $false)
$fs.SetAccessControl($acl)

# Verify inherited ACL
$acl2 = Get-Acl $p
Write-Host "SDDL: $($acl2.Sddl)"
icacls $p
