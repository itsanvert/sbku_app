$p1 = "C:\Users\Vert\Desktop\sbku_app\backend\sbkuapp_backend_kp.pem"
$p2 = "C:\Users\Vert\.ssh\test_fresh"
Write-Host "=== PROBLEM KEY SDDL ==="
(Get-Acl $p1).Sddl
Write-Host "=== KNOWN-GOOD KEY SDDL ==="
(Get-Acl $p2).Sddl
Write-Host "=== PROBLEM KEY ACL ==="
icacls $p1
Write-Host "=== KNOWN-GOOD KEY ACL ==="
icacls $p2
