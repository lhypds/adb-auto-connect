if (Test-Path -Path adb_connect_temp) {
    Write-Host "Cleaning up adb_connect_temp..."
    rmdir -Recurse adb_connect_temp
}

mkdir adb_connect_temp
adb devices > adb_connect_temp\devices.txt

$devices_lines = Get-Content "adb_connect_temp\devices.txt"
for ($i = 1; $i -lt ($devices_lines.Count - 1); $i++)
{
    $name = ($devices_lines.Get($i).Split("	"))[0]
    if ($name.Contains("5555")) { continue }

    Write-Host "--- Android Deivce $i ---"
    Write-Host "Device Name:" $name
    adb -s $name shell ip addr show wlan0 > adb_connect_temp\ip-$name.txt
    adb -s $name tcpip 5555
    Start-Sleep -s 1

    Write-Host "Gettign device IP..."
    $ip_lines = Select-String -Path adb_connect_temp\ip-$name.txt -Pattern 'inet '
    $ip_line = $ip_lines[0]
    $startIndex = $ip_line.Line.IndexOf("inet ") + 5
    $endIndex = $ip_line.Line.IndexOf("/")
    $length = $endIndex - $startIndex
    $ip = $ip_line.Line.substring($startIndex, $length)
    Write-Host "Device IP:" $ip

    Write-Host "Connecting device..."
    adb connect $ip
}

if (Test-Path -Path adb_connect_temp) {
    Write-Host "Cleaning up adb_connect_temp..."
    rmdir -Recurse adb_connect_temp
}