#!/usr/bin/env pwsh
# run-pipeline.ps1 - Script principal de la pipeline

param(
    [switch]$SkipValidation = $false,
    [switch]$Force = $false,
    [switch]$Rollback = $false,
    [string]$BackupCommit = ""
)

Write-Host "🚂 PIPELINE DE MIGRATION RAILWAY" -ForegroundColor Magenta
Write-Host "=================================" -ForegroundColor Magenta
Write-Host "SOIL-BUSINESS Migration vers Railway" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

# Fonction d'aide
function Show-Help {
    Write-Host "📋 UTILISATION:" -ForegroundColor Blue
    Write-Host "  .\run-pipeline.ps1                    # Migration complète"
    Write-Host "  .\run-pipeline.ps1 -SkipValidation    # Skip pré-validation"
    Write-Host "  .\run-pipeline.ps1 -Force             # Force avec corrections auto"
    Write-Host "  .\run-pipeline.ps1 -Rollback          # Rollback complet"
    Write-Host ""
    Write-Host "📋 ÉTAPES INDIVIDUELLES:" -ForegroundColor Blue
    Write-Host "  .\pre-migration.ps1                   # Étape 1: Validation"
    Write-Host "  .\railway-setup.ps1                   # Étape 2: Setup Railway"
    Write-Host "  .\migrate-services.ps1                # Étape 3: Migration services"
    Write-Host "  .\post-migration.ps1                  # Étape 4: Validation finale"
    Write-Host "  .\rollback.ps1                        # Rollback d'urgence"
}

# Rollback si demandé
if ($Rollback) {
    Write-Host "🔄 MODE ROLLBACK ACTIVÉ" -ForegroundColor Red
    & ".\pipeline\rollback.ps1" -Force:$Force -BackupCommit $BackupCommit
    exit $LASTEXITCODE
}

# Aide si demandée
if ($args -contains "-help" -or $args -contains "--help" -or $args -contains "-h") {
    Show-Help
    exit 0
}

Write-Host "🚀 Démarrage de la pipeline de migration..." -ForegroundColor Green
Write-Host "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

try {
    # ÉTAPE 1: Pré-migration (validation)
    if (!$SkipValidation) {
        Write-Host "▶️ ÉTAPE 1/4: PRÉ-MIGRATION" -ForegroundColor Blue
        & ".\pipeline\pre-migration.ps1" -Force:$Force
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Pré-migration échouée" -ForegroundColor Red
            exit 1
        }
        Write-Host "✅ Pré-migration terminée" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "⏭️ Pré-validation ignorée" -ForegroundColor Yellow
        Write-Host ""
    }

    # ÉTAPE 2: Setup Railway
    Write-Host "▶️ ÉTAPE 2/4: SETUP RAILWAY" -ForegroundColor Blue
    & ".\pipeline\railway-setup.ps1"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Setup Railway échoué" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Setup Railway terminé" -ForegroundColor Green
    Write-Host ""

    # ÉTAPE 3: Migration des services
    Write-Host "▶️ ÉTAPE 3/4: MIGRATION SERVICES" -ForegroundColor Blue
    & ".\pipeline\migrate-services.ps1"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Migration services échouée" -ForegroundColor Red
        Write-Host ""
        Write-Host "🔄 Pour rollback: .\run-pipeline.ps1 -Rollback" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "✅ Migration services terminée" -ForegroundColor Green
    Write-Host ""

    # ÉTAPE 4: Post-migration (validation)
    Write-Host "▶️ ÉTAPE 4/4: POST-MIGRATION" -ForegroundColor Blue
    & ".\pipeline\post-migration.ps1"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Post-migration échouée" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Post-migration terminée" -ForegroundColor Green

    # SUCCÈS FINAL
    Write-Host ""
    Write-Host "🎉🎉🎉 MIGRATION RAILWAY RÉUSSIE ! 🎉🎉🎉" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Votre application SOIL-BUSINESS est maintenant déployée sur Railway !" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔗 ACCÈS À VOS APPLICATIONS:" -ForegroundColor Blue
    Write-Host "   🔗 API      : https://soil-business-api.railway.app/" -ForegroundColor Gray
    Write-Host "   🌐 Web      : https://soil-business-web.railway.app/" -ForegroundColor Gray
    Write-Host "   ⚙️ Admin    : https://soil-business-admin.railway.app/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📊 MONITORING ET GESTION:" -ForegroundColor Blue
    Write-Host "   📊 Dashboard: https://railway.app/dashboard" -ForegroundColor Gray
    Write-Host "   📋 Logs     : railway logs --follow" -ForegroundColor Gray
    Write-Host "   ⚙️ Variables: railway variables" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💰 COÛT: ~$5/mois (vs $59/mois Vercel+DB)" -ForegroundColor Green
    Write-Host "🎯 ÉCONOMIES: ~$650/an" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎊 Félicitations ! Votre migration est terminée avec succès !" -ForegroundColor Magenta

} catch {
    Write-Host ""
    Write-Host "❌ ERREUR DANS LA PIPELINE" -ForegroundColor Red
    Write-Host "===========================" -ForegroundColor Red
    Write-Host "Erreur: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 ACTIONS POSSIBLES:" -ForegroundColor Yellow
    Write-Host "  1. Vérifier les logs détaillés ci-dessus" -ForegroundColor Gray
    Write-Host "  2. Corriger le problème et relancer" -ForegroundColor Gray
    Write-Host "  3. Rollback: .\run-pipeline.ps1 -Rollback" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📞 SUPPORT:" -ForegroundColor Cyan
    Write-Host "  Railway: https://help.railway.app" -ForegroundColor Gray
    Write-Host "  Documentation: .\docs\railway-migration-pipeline.md" -ForegroundColor Gray
    
    exit 1
}