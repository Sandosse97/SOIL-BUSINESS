#!/usr/bin/env pwsh
# migrate-to-railway.ps1 - Script de migration automatique vers Railway

Write-Host "🚂 Migration SOIL-BUSINESS vers Railway" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Blue

# Vérifier si Railway CLI est installé
Write-Host "📦 Vérification de Railway CLI..." -ForegroundColor Yellow

try {
    railway --version | Out-Null
    Write-Host "✅ Railway CLI détecté" -ForegroundColor Green
} catch {
    Write-Host "❌ Railway CLI non trouvé. Installation..." -ForegroundColor Red
    npm install -g @railway/cli
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erreur lors de l'installation de Railway CLI" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Railway CLI installé" -ForegroundColor Green
}

# Login Railway
Write-Host "🔐 Connexion à Railway..." -ForegroundColor Yellow
Write-Host "📌 Ouvrez votre navigateur pour vous connecter" -ForegroundColor Cyan

railway login

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur de connexion Railway" -ForegroundColor Red
    exit 1
}

# Initialiser le projet Railway
Write-Host "🚀 Initialisation du projet Railway..." -ForegroundColor Yellow

railway init

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors de l'initialisation" -ForegroundColor Red
    exit 1
}

# Connecter GitHub repository
Write-Host "🔗 Connexion au repository GitHub..." -ForegroundColor Yellow

railway connect

# Ajouter PostgreSQL
Write-Host "🗄️ Ajout de la base de données PostgreSQL..." -ForegroundColor Yellow

railway add postgresql

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Base de données déjà présente ou erreur" -ForegroundColor Yellow
}

# Configuration des variables d'environnement
Write-Host "⚙️ Configuration des variables d'environnement..." -ForegroundColor Yellow

# Variables partagées
railway variables set NODE_ENV=production
railway variables set JWT_SECRET=(([char[]](48..57) + [char[]](65..90) + [char[]](97..122) | Get-Random -Count 64) -join '')

Write-Host "✅ Variables d'environnement configurées" -ForegroundColor Green

# Build et test local avant déploiement
Write-Host "🔨 Build local pour vérification..." -ForegroundColor Yellow

pnpm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors du build local" -ForegroundColor Red
    Write-Host "🔧 Vérifiez les erreurs ci-dessus avant de continuer" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Build local réussi" -ForegroundColor Green

# Déploiement
Write-Host "🚀 Déploiement vers Railway..." -ForegroundColor Yellow
Write-Host "⏳ Cela peut prendre quelques minutes..." -ForegroundColor Cyan

railway up

if ($LASTEXITCODE -eq 0) {
    Write-Host "🎉 Déploiement Railway réussi !" -ForegroundColor Green
    Write-Host "🔗 Vérifiez vos services sur : https://railway.app/dashboard" -ForegroundColor Blue
    
    Write-Host ""
    Write-Host "📱 Vos applications sont maintenant disponibles :" -ForegroundColor Blue
    Write-Host "   🔗 API      : https://soil-business-api.railway.app/" -ForegroundColor Gray
    Write-Host "   🌐 Web      : https://soil-business-web.railway.app/" -ForegroundColor Gray
    Write-Host "   ⚙️ Admin    : https://soil-business-admin.railway.app/" -ForegroundColor Gray
    
    Write-Host ""
    Write-Host "🧪 Test rapide de l'API :" -ForegroundColor Yellow
    Write-Host "   curl https://soil-business-api.railway.app/health" -ForegroundColor Gray
    
    Write-Host ""
    Write-Host "📊 Commandes utiles :" -ForegroundColor Blue
    Write-Host "   railway logs --follow    # Logs en temps réel" -ForegroundColor Gray
    Write-Host "   railway status           # Statut des services" -ForegroundColor Gray
    Write-Host "   railway variables        # Variables d'environnement" -ForegroundColor Gray
    
} else {
    Write-Host "❌ Erreur lors du déploiement Railway" -ForegroundColor Red
    Write-Host "🔧 Vérifiez les logs Railway : railway logs" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🏆 Migration terminée avec succès !" -ForegroundColor Green
Write-Host "🔗 Dashboard Railway : https://railway.app/dashboard" -ForegroundColor Blue