$p = "C:\Users\Vert\Desktop\sbku_app\backend\sbkuapp_backend_kp.pem"
# Remove all existing ACEs, set single owner-read ACE with a protected DACL
icacls $p /remove "Users" 2>$null | Out-Null
icacls $p /remove "Authenticated Users" 2>$null | Out-Null
icacls $p /remove "Everyone" 2>$null | Out-Null
# Take ownership if needed
takeown /f $p /a 2>$null | Out-Null
# Reset DACL: single entry for owner (OW) with read+sync, protected
icacls $p /inheritance:r /grant "OW:R" 2>$null | Out-Null
icacls $p /remove "Users" /remove "Authenticated Users" /remove "Everyone" /remove "BUILTIN\Administrators" /remove "NT AUTHORITY\SYSTEM" 2>$null | Out-Null
icacls $p
