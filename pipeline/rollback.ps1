#!/usr/bin/env pwsh
# rollback.ps1 - Procédure de rollback d'urgence

param(
    [switch]$Force = $false,
    [string]$BackupCommit = ""
)

Write-Host "🔄 PROCÉDURE DE ROLLBACK RAILWAY" -ForegroundColor Red
Write-Host "=================================" -ForegroundColor Red

$ErrorActionPreference = "Stop"

if (!$Force) {
    Write-Host ""
    Write-Host "⚠️ ATTENTION: Cette procédure va:" -ForegroundColor Yellow
    Write-Host "  - Restaurer la configuration Vercel" -ForegroundColor Gray
    Write-Host "  - Supprimer les services Railway" -ForegroundColor Gray
    Write-Host "  - Revenir au commit précédent" -ForegroundColor Gray
    Write-Host ""
    $confirm = Read-Host "Confirmer le rollback? (tapez 'ROLLBACK' pour confirmer)"
    
    if ($confirm -ne "ROLLBACK") {
        Write-Host "❌ Rollback annulé" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "🔄 Début du rollback..." -ForegroundColor Yellow

# 1. Sauvegarder l'état Railway actuel
Write-Host "💾 Sauvegarde état Railway..." -ForegroundColor Yellow
if (Test-Path "pipeline/.migration-completed") {
    Copy-Item "pipeline/.migration-completed" "pipeline/.rollback-backup-$(Get-Date -Format 'yyyyMMddHHmmss').json"
}

# 2. Restaurer fichiers Vercel
Write-Host "📦 Restauration configuration Vercel..." -ForegroundColor Yellow

# Restaurer vercel.json principal
if (Test-Path "vercel.json.backup") {
    Copy-Item "vercel.json.backup" "vercel.json" -Force
    Write-Host "✅ vercel.json restauré" -ForegroundColor Green
} else {
    # Recréer configuration Vercel basique
    @{
        version = 2
        env = @{
            NODE_ENV = "production"
        }
    } | ConvertTo-Json | Out-File "vercel.json" -Encoding UTF8
    Write-Host "✅ vercel.json recréé" -ForegroundColor Green
}

# Restaurer configurations par service
$vercelConfigs = @{
    "apps/web/vercel.json" = @{
        framework = "nextjs"
        env = @{
            NODE_ENV = "production"
        }
    }
    "apps/admin/vercel.json" = @{
        framework = "nextjs"
        env = @{
            NODE_ENV = "production"
        }
    }
    "apps/api/vercel.json" = @{
        functions = @{
            "src/index.ts" = @{
                maxDuration = 30
                runtime = "nodejs18.x"
            }
        }
    }
}

foreach ($file in $vercelConfigs.Keys) {
    $vercelConfigs[$file] | ConvertTo-Json | Out-File $file -Encoding UTF8
    Write-Host "✅ $file restauré" -ForegroundColor Green
}

# 3. Rollback Git si demandé
if ($BackupCommit) {
    Write-Host "🔄 Rollback Git vers $BackupCommit..." -ForegroundColor Yellow
    try {
        git reset --hard $BackupCommit
        Write-Host "✅ Rollback Git réussi" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erreur rollback Git: $_" -ForegroundColor Red
    }
}

# 4. Nettoyer fichiers Railway
Write-Host "🧹 Nettoyage fichiers Railway..." -ForegroundColor Yellow

$railwayFiles = @(
    "railway.json",
    "apps/api/.env.railway",
    "apps/web/.env.railway", 
    "apps/admin/.env.railway",
    "pipeline/.railway-setup-completed",
    "pipeline/.migration-completed"
)

foreach ($file in $railwayFiles) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "🗑️ Supprimé $file" -ForegroundColor Gray
    }
}

# 5. Instructions manuelles Railway
Write-Host ""
Write-Host "⚠️ ACTIONS MANUELLES REQUISES:" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "🚂 Railway Dashboard: https://railway.app/dashboard" -ForegroundColor Cyan
Write-Host "   1. Supprimer le projet 'SOIL-BUSINESS'" -ForegroundColor Gray
Write-Host "   2. Ou suspendre tous les services" -ForegroundColor Gray
Write-Host ""
Write-Host "⚡ Vercel Dashboard: https://vercel.com/dashboard" -ForegroundColor Cyan
Write-Host "   1. Re-connecter le repository GitHub" -ForegroundColor Gray
Write-Host "   2. Configurer les variables d'environnement" -ForegroundColor Gray
Write-Host "   3. Relancer le déploiement" -ForegroundColor Gray

# 6. Test Vercel (si possible)
Write-Host ""
Write-Host "🧪 Test configuration Vercel..." -ForegroundColor Yellow

try {
    # Vérifier si Vercel CLI est disponible
    vercel --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "📦 Vercel CLI détecté" -ForegroundColor Green
        Write-Host "🚀 Pour redéployer sur Vercel:" -ForegroundColor Cyan
        Write-Host "   vercel --prod" -ForegroundColor Gray
    } else {
        Write-Host "📦 Installer Vercel CLI: npm install -g vercel" -ForegroundColor Cyan
    }
} catch {
    Write-Host "📦 Vercel CLI non détecté" -ForegroundColor Yellow
}

# 7. Build test local
Write-Host ""
Write-Host "🔨 Test build local..." -ForegroundColor Yellow
try {
    pnpm run build | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build local réussi" -ForegroundColor Green
    } else {
        Write-Host "❌ Build local échoué" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur build local: $_" -ForegroundColor Red
}

# 8. Créer rapport rollback
$rollbackReport = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    action = "rollback"
    reason = "manual_rollback"
    vercel_restored = (Test-Path "vercel.json")
    git_commit = if ($BackupCommit) { $BackupCommit } else { "no_rollback" }
    status = "completed"
}

$rollbackReport | ConvertTo-Json | Out-File "pipeline/.rollback-report.json" -Encoding UTF8

Write-Host ""
Write-Host "✅ ROLLBACK TERMINÉ" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Résumé des actions:" -ForegroundColor Blue
Write-Host "  ✅ Configuration Vercel restaurée" -ForegroundColor Green
Write-Host "  ✅ Fichiers Railway supprimés" -ForegroundColor Green
Write-Host "  ✅ Build local testé" -ForegroundColor Green
Write-Host ""
Write-Host "🔄 Actions manuelles restantes:" -ForegroundColor Yellow
Write-Host "  1. Supprimer projet Railway" -ForegroundColor Gray
Write-Host "  2. Reconfigurer Vercel" -ForegroundColor Gray
Write-Host "  3. Tester déploiement Vercel" -ForegroundColor Gray
Write-Host ""
Write-Host "📞 Support:" -ForegroundColor Cyan
Write-Host "  Railway: https://help.railway.app" -ForegroundColor Gray
Write-Host "  Vercel: https://vercel.com/docs" -ForegroundColor Gray