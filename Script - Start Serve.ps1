#!/usr/bin/env pwsh

# 1. Chargement de la configuration depuis config.ini
$ConfigFile = "./config.ini"
$HostName = "localhost"  # Valeur par défaut
$Port = 8080             # Valeur par défaut

if (Test-Path $ConfigFile) {
    $Config = ConvertFrom-StringData (Get-Content $ConfigFile -Raw)
    if ($Config.Host) { $HostName = $Config.Host.Trim() }
    if ($Config.Port) { $Port = [int]$Config.Port.Trim() }
} else {
    Write-Warning "Fichier config.ini introuvable, utilisation des valeurs par défaut."
}

$Url = "http://$($HostName):$Port"

# miniserve nécessite une IP pure. Si l'hôte est 'localhost', on le mappe sur '127.0.0.1'
$BindInterface = $HostName
if ($HostName -eq "localhost") {
    $BindInterface = "127.0.0.1"
}

# 2. Détection de l'OS et définition du binaire
if ($IsWindows) {
    $MiniservePath = ".\miniserve\miniserve-0.35.0-x86_64-pc-windows-msvc.exe"
}
elseif ($IsLinux) {
    $MiniservePath = "./miniserve/miniserve-0.35.0-x86_64-unknown-linux-gnu"
    if (Test-Path $MiniservePath) {
        chmod +x $MiniservePath
    }
}
else {
    Write-Error "Système d'exploitation non pris en charge."
    exit 1
}

if (-not (Test-Path $MiniservePath)) {
    Write-Error "Le fichier miniserve est introuvable à l'emplacement : $MiniservePath"
    exit 1
}

# 3. Libération absolue du port défini dans le fichier de config
Write-Host "Vérification et libération forcée du port $Port..." -ForegroundColor Yellow

if ($IsWindows) {
    $NetstatResult = netstat -ano | Select-String "LISTENING" | Select-String ":$Port\s"
    if ($NetstatResult) {
        $PidToKill = ($NetstatResult.Line -split '\s+')[-1]
        Write-Host "Port occupé par le PID $PidToKill. Arrêt du processus..." -ForegroundColor Cyan
        Stop-Process -Id $PidToKill -Force
        Start-Sleep -Seconds 1
    }
}
elseif ($IsLinux) {
    if (Get-Command fuser -ErrorAction SilentlyContinue) {
        fuser -k $Port/tcp 2>$null
        Start-Sleep -Seconds 1
    }
    elseif (Get-Command lsof -ErrorAction SilentlyContinue) {
        $PidToKill = (lsof -t -i :$Port)
        if ($PidToKill) {
            Write-Host "Port occupé par le PID $PidToKill. Arrêt du processus..." -ForegroundColor Cyan
            kill -9 $PidToKill
            Start-Sleep -Seconds 1
        }
    }
}

# 4. Ouverture du navigateur par défaut
Write-Host "Ouverture du navigateur sur $Url..." -ForegroundColor Yellow
if ($IsWindows) {
    Start-Process $Url
}
elseif ($IsLinux) {
    Start-Process "xdg-open" $Url -ErrorAction SilentlyContinue
}

# 5. Démarrage du serveur miniserve lié à l'interface IP et au port configurés
Write-Host "Démarrage de miniserve sur $Url..." -ForegroundColor Green
& $MiniservePath . --interfaces $BindInterface -p $Port --index index.html

