$good = Get-Acl "C:\Users\Vert\.ssh\test_fresh"
$bad  = Get-Acl "C:\Users\Vert\Desktop\sbku_app\backend\sbkuapp_backend_kp.pem"
Write-Host "=== GOOD KEY ACEs ==="
$good.Access | ForEach-Object { Write-Host "$($_.IdentityReference) | $($_.FileSystemRights) | $($_.AccessControlType) | Inherited=$($_.IsInherited) Flags=$($_.InheritanceFlags) Prop=$($_.PropagationFlags)" }
Write-Host "`n=== BAD KEY ACEs ==="
$bad.Access  | ForEach-Object { Write-Host "$($_.IdentityReference) | $($_.FileSystemRights) | $($_.AccessControlType) | Inherited=$($_.IsInherited) Flags=$($_.InheritanceFlags) Prop=$($_.PropagationFlags)" }
