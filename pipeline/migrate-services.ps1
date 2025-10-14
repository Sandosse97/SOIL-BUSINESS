#!/usr/bin/env pwsh
# migrate-services.ps1 - Migration des services

Write-Host "🚀 ÉTAPE 3: MIGRATION SERVICES" -ForegroundColor Blue
Write-Host "===============================" -ForegroundColor Blue

$ErrorActionPreference = "Stop"
$config = Get-Content "pipeline/config.json" | ConvertFrom-Json

# Vérifier setup Railway
if (!(Test-Path "pipeline/.railway-setup-completed")) {
    Write-Host "❌ Setup Railway non terminé. Lancez d'abord .\railway-setup.ps1" -ForegroundColor Red
    exit 1
}

function Deploy-Service {
    param($ServiceName, $ServiceConfig)
    
    Write-Host ""
    Write-Host "🚀 Déploiement service: $ServiceName" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Gray
    
    # Variables spécifiques au service
    $envVars = $config.environments.$ServiceName
    if ($envVars) {
        Write-Host "⚙️ Configuration variables pour $ServiceName..." -ForegroundColor Yellow
        foreach ($key in $envVars.PSObject.Properties.Name) {
            $value = $envVars.$key
            Write-Host "  Setting $key..." -ForegroundColor Gray
            railway variables set "$key=$value" 2>&1 | Out-Null
        }
    }
    
    # Déploiement via Git push (Railway détecte automatiquement)
    Write-Host "📤 Déploiement $ServiceName via Railway..." -ForegroundColor Yellow
    
    try {
        # Railway up deploy tout automatiquement depuis GitHub
        railway up --service $ServiceName 2>&1
        Write-Host "✅ Service $ServiceName déployé" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ Erreur déploiement $ServiceName" -ForegroundColor Red
        Write-Host "Détails: $_" -ForegroundColor Red
        return $false
    }
}

function Test-ServiceHealth {
    param($ServiceName, $HealthUrl)
    
    Write-Host "🔍 Test santé $ServiceName..." -ForegroundColor Yellow
    
    $maxRetries = 10
    $retryDelay = 30
    
    for ($i = 1; $i -le $maxRetries; $i++) {
        try {
            Write-Host "  Tentative $i/$maxRetries..." -ForegroundColor Gray
            $response = Invoke-RestMethod -Uri $HealthUrl -Method GET -TimeoutSec 10
            Write-Host "✅ $ServiceName en ligne et opérationnel" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "⏳ $ServiceName pas encore prêt, attente ${retryDelay}s..." -ForegroundColor Yellow
            Start-Sleep $retryDelay
        }
    }
    
    Write-Host "❌ $ServiceName ne répond pas après $maxRetries tentatives" -ForegroundColor Red
    return $false
}

# Build local pour vérification
Write-Host "🔨 Build local avant déploiement..." -ForegroundColor Yellow
pnpm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build local échoué" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Build local réussi" -ForegroundColor Green

# Déploiement global (monorepo)
Write-Host ""
Write-Host "🚀 Déploiement monorepo complet..." -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Gray

try {
    # Railway détecte automatiquement le monorepo et crée les services
    railway up
    Write-Host "✅ Déploiement global lancé" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur déploiement global" -ForegroundColor Red
    Write-Host "Détails: $_" -ForegroundColor Red
    exit 1
}

# Attente stabilisation
Write-Host ""
Write-Host "⏳ Attente stabilisation des services (60s)..." -ForegroundColor Yellow
Start-Sleep 60

# Validation des services
Write-Host ""
Write-Host "🧪 VALIDATION DES SERVICES" -ForegroundColor Blue
Write-Host "===========================" -ForegroundColor Blue

$deploymentSuccess = $true
$serviceResults = @{}

# Tester chaque service
foreach ($serviceName in $config.services.PSObject.Properties.Name) {
    $healthUrl = $config.validation.healthchecks.$serviceName
    $isHealthy = Test-ServiceHealth $serviceName $healthUrl
    $serviceResults[$serviceName] = $isHealthy
    
    if (!$isHealthy) {
        $deploymentSuccess = $false
    }
}

# Résumé déploiement
Write-Host ""
Write-Host "📊 RÉSUMÉ DÉPLOIEMENT" -ForegroundColor Blue
Write-Host "=====================" -ForegroundColor Blue

foreach ($service in $serviceResults.Keys) {
    $status = if ($serviceResults[$service]) { "✅ OPÉRATIONNEL" } else { "❌ ÉCHEC" }
    $color = if ($serviceResults[$service]) { "Green" } else { "Red" }
    Write-Host "$service : $status" -ForegroundColor $color
}

if ($deploymentSuccess) {
    Write-Host ""
    Write-Host "🎉 MIGRATION RÉUSSIE !" -ForegroundColor Green
    Write-Host "======================" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "🔗 VOS APPLICATIONS SONT LIVE :" -ForegroundColor Cyan
    Write-Host "API      : https://soil-business-api.railway.app/" -ForegroundColor Gray
    Write-Host "Web      : https://soil-business-web.railway.app/" -ForegroundColor Gray
    Write-Host "Admin    : https://soil-business-admin.railway.app/" -ForegroundColor Gray
    
    # Créer marker de migration réussie
    @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        migration = "completed"
        services = $serviceResults
    } | ConvertTo-Json | Out-File "pipeline/.migration-completed" -Encoding UTF8
    
    Write-Host ""
    Write-Host "➡️ Prochaine étape: .\post-migration.ps1" -ForegroundColor Yellow
    
} else {
    Write-Host ""
    Write-Host "❌ MIGRATION PARTIELLEMENT ÉCHOUÉE" -ForegroundColor Red
    Write-Host "Consultez les logs Railway pour plus de détails" -ForegroundColor Yellow
    Write-Host "railway logs --follow" -ForegroundColor Gray
    exit 1
}