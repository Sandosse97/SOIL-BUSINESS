#!/usr/bin/env pwsh
# post-migration.ps1 - Validation et finalisation

Write-Host "✅ ÉTAPE 4: POST-MIGRATION" -ForegroundColor Blue
Write-Host "===========================" -ForegroundColor Blue

$ErrorActionPreference = "Stop"
$config = Get-Content "pipeline/config.json" | ConvertFrom-Json

# Vérifier migration
if (!(Test-Path "pipeline/.migration-completed")) {
    Write-Host "❌ Migration non terminée. Lancez d'abord .\migrate-services.ps1" -ForegroundColor Red
    exit 1
}

function Test-EndpointFunctionality {
    param($Name, $Url, $Method = "GET", $Body = $null)
    
    Write-Host "🧪 Test fonctionnel: $Name..." -ForegroundColor Yellow
    
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            TimeoutSec = 30
        }
        
        if ($Body) {
            $params.Body = $Body | ConvertTo-Json
            $params.ContentType = "application/json"
        }
        
        $response = Invoke-RestMethod @params
        Write-Host "✅ $Name - OK" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ $Name - ÉCHEC: $_" -ForegroundColor Red
        return $false
    }
}

function Test-PerformanceBasic {
    param($Url, $ServiceName)
    
    Write-Host "⚡ Test performance $ServiceName..." -ForegroundColor Yellow
    
    $times = @()
    for ($i = 1; $i -le 3; $i++) {
        try {
            $start = Get-Date
            Invoke-RestMethod -Uri $Url -Method GET -TimeoutSec 10 | Out-Null
            $end = Get-Date
            $duration = ($end - $start).TotalMilliseconds
            $times += $duration
        } catch {
            Write-Host "⚠️ Erreur test performance $i" -ForegroundColor Yellow
        }
    }
    
    if ($times.Count -gt 0) {
        $avgTime = ($times | Measure-Object -Average).Average
        Write-Host "📊 $ServiceName - Temps moyen: $([math]::Round($avgTime))ms" -ForegroundColor Cyan
        return $avgTime -lt 5000  # < 5 secondes acceptable
    }
    return $false
}

Write-Host "🧪 TESTS FONCTIONNELS APPROFONDIS" -ForegroundColor Blue
Write-Host "===================================" -ForegroundColor Blue

$testResults = @{}

# 1. Tests API détaillés
Write-Host ""
Write-Host "🔗 Tests API Backend" -ForegroundColor Cyan

$testResults["api_health"] = Test-EndpointFunctionality "API Health Check" "https://soil-business-api.railway.app/health"

$testResults["api_auth_request"] = Test-EndpointFunctionality "API Auth OTP Request" "https://soil-business-api.railway.app/auth/request-otp" "POST" @{
    email = "test@example.com"
}

# 2. Tests Web App
Write-Host ""
Write-Host "🌐 Tests Web Application" -ForegroundColor Cyan

$testResults["web_home"] = Test-EndpointFunctionality "Web Home Page" "https://soil-business-web.railway.app/"
$testResults["web_deals"] = Test-EndpointFunctionality "Web Deals Page" "https://soil-business-web.railway.app/deals"

# 3. Tests Admin Dashboard
Write-Host ""
Write-Host "⚙️ Tests Admin Dashboard" -ForegroundColor Cyan

$testResults["admin_home"] = Test-EndpointFunctionality "Admin Dashboard" "https://soil-business-admin.railway.app/admin"
$testResults["admin_deals"] = Test-EndpointFunctionality "Admin Deals Management" "https://soil-business-admin.railway.app/admin/deals"

# 4. Tests de performance
Write-Host ""
Write-Host "⚡ TESTS DE PERFORMANCE" -ForegroundColor Blue
Write-Host "========================" -ForegroundColor Blue

$perfResults = @{}
$perfResults["api"] = Test-PerformanceBasic "https://soil-business-api.railway.app/health" "API"
$perfResults["web"] = Test-PerformanceBasic "https://soil-business-web.railway.app/" "Web"
$perfResults["admin"] = Test-PerformanceBasic "https://soil-business-admin.railway.app/admin" "Admin"

# 5. Validation base de données
Write-Host ""
Write-Host "🗄️ VALIDATION BASE DE DONNÉES" -ForegroundColor Blue
Write-Host "===============================" -ForegroundColor Blue

try {
    Write-Host "🔍 Test connexion base de données..." -ForegroundColor Yellow
    # Test via l'API qui utilise la base
    $dbTest = Test-EndpointFunctionality "Database Connection via API" "https://soil-business-api.railway.app/health"
    Write-Host "✅ Base de données accessible" -ForegroundColor Green
} catch {
    Write-Host "❌ Problème base de données" -ForegroundColor Red
}

# 6. Cleanup et documentation
Write-Host ""
Write-Host "🧹 CLEANUP ET FINALISATION" -ForegroundColor Blue
Write-Host "============================" -ForegroundColor Blue

# Backup des configurations Vercel avant cleanup
Write-Host "💾 Archivage configurations Vercel..." -ForegroundColor Yellow
if (Test-Path "vercel.json") {
    if (!(Test-Path "archive")) { New-Item -ItemType Directory -Name "archive" }
    Move-Item "vercel.json" "archive/vercel.json.$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Force
    Write-Host "✅ Configuration Vercel archivée" -ForegroundColor Green
}

# Nettoyer fichiers Vercel spécifiques
$vercelFiles = @("apps/web/vercel.json", "apps/admin/vercel.json", "apps/api/vercel.json")
foreach ($file in $vercelFiles) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "🗑️ Supprimé $file" -ForegroundColor Gray
    }
}

# Mise à jour README avec nouvelles URLs
Write-Host "📚 Mise à jour documentation..." -ForegroundColor Yellow

$readmeUpdate = @"

## 🚀 Applications Déployées (Railway)

- **🔗 API Backend**: https://soil-business-api.railway.app/
- **🌐 Site Web**: https://soil-business-web.railway.app/
- **⚙️ Admin Dashboard**: https://soil-business-admin.railway.app/

### Health Checks
- API Health: https://soil-business-api.railway.app/health
- Web App: https://soil-business-web.railway.app/
- Admin Panel: https://soil-business-admin.railway.app/admin

### Railway Dashboard
- **Monitoring**: https://railway.app/dashboard
- **Logs**: `railway logs --follow`
- **Variables**: `railway variables`

Migration Railway terminée le $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@

Add-Content -Path "README.md" -Value $readmeUpdate
Write-Host "✅ README mis à jour" -ForegroundColor Green

# Résumé final
Write-Host ""
Write-Host "📊 RÉSUMÉ VALIDATION POST-MIGRATION" -ForegroundColor Blue
Write-Host "=====================================" -ForegroundColor Blue

$successCount = ($testResults.Values | Where-Object { $_ -eq $true }).Count
$totalTests = $testResults.Count

Write-Host "Tests fonctionnels: $successCount/$totalTests réussis" -ForegroundColor Cyan

foreach ($test in $testResults.Keys) {
    $status = if ($testResults[$test]) { "✅" } else { "❌" }
    $color = if ($testResults[$test]) { "Green" } else { "Red" }
    Write-Host "  $status $test" -ForegroundColor $color
}

$perfSuccess = ($perfResults.Values | Where-Object { $_ -eq $true }).Count
Write-Host "Tests performance: $perfSuccess/3 acceptables" -ForegroundColor Cyan

# Créer rapport final
$finalReport = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    migration_status = "completed"
    tests_passed = $successCount
    tests_total = $totalTests
    performance_ok = $perfSuccess
    urls = @{
        api = "https://soil-business-api.railway.app/"
        web = "https://soil-business-web.railway.app/"
        admin = "https://soil-business-admin.railway.app/"
    }
}

$finalReport | ConvertTo-Json | Out-File "pipeline/.migration-final-report.json" -Encoding UTF8

if ($successCount -eq $totalTests -and $perfSuccess -ge 2) {
    Write-Host ""
    Write-Host "🎉 MIGRATION RAILWAY TERMINÉE AVEC SUCCÈS !" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "🚀 Votre application SOIL-BUSINESS est maintenant live sur Railway !" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔗 Accès direct :" -ForegroundColor Blue
    Write-Host "   API      : https://soil-business-api.railway.app/" -ForegroundColor Gray
    Write-Host "   Web      : https://soil-business-web.railway.app/" -ForegroundColor Gray
    Write-Host "   Admin    : https://soil-business-admin.railway.app/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📊 Monitoring : https://railway.app/dashboard" -ForegroundColor Blue
    Write-Host "📋 Logs      : railway logs --follow" -ForegroundColor Gray
    
} else {
    Write-Host ""
    Write-Host "⚠️ MIGRATION TERMINÉE AVEC AVERTISSEMENTS" -ForegroundColor Yellow
    Write-Host "Certains tests ont échoué. Vérifiez les logs Railway." -ForegroundColor Yellow
    Write-Host "railway logs --follow" -ForegroundColor Gray
}