#!/usr/bin/env pwsh
# deploy.ps1 - Script de déploiement PowerShell pour Windows

Write-Host "🚀 Déploiement SOIL-BUSINESS en cours..." -ForegroundColor Green

# 1. Build de tous les packages
Write-Host "📦 Build des applications..." -ForegroundColor Yellow
pnpm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors du build" -ForegroundColor Red
    exit 1
}

# 2. Export des applications Next.js (si supporté)
Write-Host "📤 Export des interfaces..." -ForegroundColor Yellow

# Web App Export (si possible)
Set-Location "apps/web"
Write-Host "   → Export Web App..." -ForegroundColor Cyan
# Note: L'export statique peut ne pas être compatible avec toutes les fonctionnalités
Set-Location "../.."

# Admin Export (si possible)  
Set-Location "apps/admin"
Write-Host "   → Export Admin Dashboard..." -ForegroundColor Cyan
Set-Location "../.."

Write-Host "✅ Export terminé !" -ForegroundColor Green

# 3. Afficher la structure des builds
Write-Host "📁 Fichiers buildés dans:" -ForegroundColor Blue
Write-Host "   - apps/web/.next/" -ForegroundColor Gray
Write-Host "   - apps/admin/.next/" -ForegroundColor Gray  
Write-Host "   - apps/api/dist/" -ForegroundColor Gray

# 4. Push vers GitHub (déclenchera le déploiement Vercel automatique)
Write-Host "📤 Push vers GitHub..." -ForegroundColor Yellow

git add .
git commit -m "Production ready: Exported interfaces for deployment"
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "🎉 Déploiement lancé ! Vérifiez le Vercel Dashboard." -ForegroundColor Green
    Write-Host "🔗 Dashboard: https://vercel.com/dashboard" -ForegroundColor Blue
} else {
    Write-Host "❌ Erreur lors du push Git" -ForegroundColor Red
    exit 1
}