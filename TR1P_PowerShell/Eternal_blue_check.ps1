﻿[reflection.assembly]::LoadWithPartialName("System.Version")
$os = Get-WmiObject -class Win32_OperatingSystem
$osName = $os.Caption
$s = "%systemroot%\system32\drivers\srv.sys"
$v = [System.Environment]::ExpandEnvironmentVariables($s)
If (Test-Path "$v")
    {
    Try
        {
        $versionInfo = (Get-Item $v).VersionInfo
        $versionString = "$($versionInfo.FileMajorPart).$($versionInfo.FileMinorPart).$($versionInfo.FileBuildPart).$($versionInfo.FilePrivatePart)"
        $fileVersion = New-Object System.Version($versionString)
        }
    Catch
        {
        Write-Host "Unable to retrieve file version info, please verify vulnerability state manually." -ForegroundColor Yellow
        Return
        }
    }
Else
    {
    Write-Host "Srv.sys does not exist, please verify vulnerability state manually." -ForegroundColor Yellow
    Return
    }
if ($osName.Contains("Windows 7") -or ($osName.Contains("2008 R2")))
    {
    $currentOS = "$osName LDR"
    $expectedVersion = New-Object System.Version("6.1.7601.23689")
    }
elseif ($osName.Contains("Windows 10"))
    {
    if ($os.BuildNumber -eq "10240")
        {
        $currentOS = "$osName TH1"
        $expectedVersion = New-Object System.Version("10.0.10240.17319")
        }
    elseif ($os.BuildNumber -eq "10586")
        {
        $currentOS = "$osName TH2"
        $expectedVersion = New-Object System.Version("10.0.10586.839")
        }
    elseif ($os.BuildNumber -eq "14393")
        {
        $currentOS = "$($osName) RS1"
        $expectedVersion = New-Object System.Version("10.0.14393.953")
        }
    elseif ($os.BuildNumber -eq "15063")
        {
        $currentOS = "$osName RS2"
        "No need to Patch. RS2 is released as patched. "
        return
        }
    }
else
    {
    Write-Host "Unable to determine OS applicability, please verify vulnerability state manually." -ForegroundColor Yellow
    $currentOS = "$osName"
    $expectedVersion = New-Object System.Version("9.9.9999.99999")
    }
Write-Host "`n`nCurrent OS: $currentOS (Build Number $($os.BuildNumber))" -ForegroundColor Cyan
Write-Host "`nExpected Version of srv.sys: $($expectedVersion.ToString())" -ForegroundColor Cyan
Write-Host "`nActual Version of srv.sys: $($fileVersion.ToString())" -ForegroundColor Cyan
If ($($fileVersion.CompareTo($expectedVersion)) -lt 0)
    {
    Write-Host "`n`n"
    Write-Host "System is NOT Patched" -ForegroundColor Red
    }
Else
    {
    Write-Host "`n`n"
    Write-Host "System is Patched" -ForegroundColor Green
    }