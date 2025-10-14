#!/usr/bin/env pwsh
# railway-setup.ps1 - Configuration Railway

Write-Host "🚂 ÉTAPE 2: SETUP RAILWAY" -ForegroundColor Blue
Write-Host "==========================" -ForegroundColor Blue

$ErrorActionPreference = "Stop"
$config = Get-Content "pipeline/config.json" | ConvertFrom-Json

function Invoke-RailwayCommand {
    param($Command, $Description)
    
    Write-Host "🔧 $Description..." -ForegroundColor Yellow
    
    try {
        $result = Invoke-Expression "railway $Command" 2>&1
        Write-Host "✅ $Description - Réussi" -ForegroundColor Green
        return $result
    } catch {
        Write-Host "❌ $Description - Échec: $_" -ForegroundColor Red
        throw
    }
}

# 1. Vérifier pré-migration
if (!(Test-Path "pipeline/.pre-migration-passed")) {
    Write-Host "❌ Pré-migration non validée. Lancez d'abord .\pre-migration.ps1" -ForegroundColor Red
    exit 1
}

# 2. Installer Railway CLI si nécessaire
Write-Host "📦 Vérification Railway CLI..." -ForegroundColor Yellow
try {
    railway --version | Out-Null
    Write-Host "✅ Railway CLI détecté" -ForegroundColor Green
} catch {
    Write-Host "📥 Installation Railway CLI..." -ForegroundColor Yellow
    npm install -g @railway/cli
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Erreur installation Railway CLI" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Railway CLI installé" -ForegroundColor Green
}

# 3. Authentification Railway
Write-Host "🔐 Authentification Railway..." -ForegroundColor Yellow
Write-Host "📌 Une page web va s'ouvrir pour l'authentification" -ForegroundColor Cyan

try {
    railway login
    Write-Host "✅ Authentification réussie" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur d'authentification Railway" -ForegroundColor Red
    exit 1
}

# 4. Initialiser le projet Railway
Invoke-RailwayCommand "init" "Initialisation projet Railway"

# 5. Connecter GitHub repository
Invoke-RailwayCommand "connect" "Connexion repository GitHub"

# 6. Ajouter base de données PostgreSQL
Write-Host "🗄️ Ajout base de données PostgreSQL..." -ForegroundColor Yellow
try {
    railway add postgresql
    Write-Host "✅ Base de données PostgreSQL ajoutée" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Base de données déjà présente ou erreur mineure" -ForegroundColor Yellow
}

# 7. Générer JWT secret si nécessaire
$jwtSecret = -join ((1..64) | ForEach {Get-Random -input ([char[]](48..57) + [char[]](65..90) + [char[]](97..122))})

# 8. Configurer variables d'environnement partagées
Write-Host "⚙️ Configuration variables d'environnement..." -ForegroundColor Yellow

$sharedVars = $config.environments.shared
foreach ($key in $sharedVars.PSObject.Properties.Name) {
    $value = $sharedVars.$key
    Invoke-RailwayCommand "variables set $key='$value'" "Variable $key"
}

# JWT Secret
Invoke-RailwayCommand "variables set JWT_SECRET='$jwtSecret'" "JWT Secret"

# 9. Créer marker de setup réussi
@{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    setup = "completed"
    jwtSecret = $jwtSecret
    services = $config.services.PSObject.Properties.Name
} | ConvertTo-Json | Out-File "pipeline/.railway-setup-completed" -Encoding UTF8

Write-Host ""
Write-Host "🎉 Setup Railway terminé avec succès !" -ForegroundColor Green
Write-Host "📊 Projet créé avec:" -ForegroundColor Blue
Write-Host "  - PostgreSQL database" -ForegroundColor Gray
Write-Host "  - Variables d'environnement configurées" -ForegroundColor Gray
Write-Host "  - GitHub repository connecté" -ForegroundColor Gray
Write-Host ""
Write-Host "🔗 Dashboard Railway: https://railway.app/dashboard" -ForegroundColor Cyan
Write-Host "➡️ Prochaine étape: .\migrate-services.ps1" -ForegroundColor Yellow