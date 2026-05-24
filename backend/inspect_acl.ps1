Set-StrictMode -Version Latest
$path = "C:\Users\Vert\Desktop\sbku_app\backend\sbkuapp_backend_kp.pem"
$fs   = Get-Item $path
$acl  = $fs.GetAccessControl("Access")
Write-Host "=== ACL Raw ==="
$acl.Access | Format-List *
Write-Host "=== Owner ==="
$acl.Owner
Write-Host "=== Group ==="
$acl.Group
Write-Host "=== IsProtected ==="
$acl.AreAccessRulesProtected
$acl.AccessRulesToString
