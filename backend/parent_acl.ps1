$parent = "C:\Users\Vert\Desktop\sbku_app\backend"
Get-Acl $parent | Format-List *
$parent | icacls
