#!/usr/bin/env pwsh
# pre-migration.ps1 - Validation pré-migration

param(
    [switch]$Force = $false
)

Write-Host "🔍 ÉTAPE 1: PRÉ-MIGRATION VALIDATION" -ForegroundColor Blue
Write-Host "=====================================" -ForegroundColor Blue

$ErrorActionPreference = "Stop"
$script:errors = @()

function Test-Requirement {
    param($Name, $Test, $Fix = $null)
    
    Write-Host "🔍 Vérification: $Name..." -ForegroundColor Yellow
    
    try {
        $result = & $Test
        if ($result) {
            Write-Host "✅ $Name - OK" -ForegroundColor Green
            return $true
        } else {
            throw "Test failed"
        }
    } catch {
        Write-Host "❌ $Name - ÉCHEC" -ForegroundColor Red
        $script:errors += $Name
        
        if ($Fix -and $Force) {
            Write-Host "🔧 Tentative de correction..." -ForegroundColor Yellow
            try {
                & $Fix
                Write-Host "✅ $Name - CORRIGÉ" -ForegroundColor Green
                return $true
            } catch {
                Write-Host "❌ $Name - CORRECTION ÉCHOUÉE" -ForegroundColor Red
                return $false
            }
        }
        return $false
    }
}

# 1. Vérifier Git status
Test-Requirement "Git repository propre" {
    $status = git status --porcelain
    return [string]::IsNullOrEmpty($status)
} {
    git add .
    git commit -m "Pre-migration: Auto-commit before Railway migration"
}

# 2. Vérifier build local
Test-Requirement "Build local réussi" {
    $buildResult = pnpm run build 2>&1
    return $LASTEXITCODE -eq 0
}

# 3. Vérifier Node.js version
Test-Requirement "Node.js version compatible" {
    $nodeVersion = node --version
    $version = [version]($nodeVersion -replace "v", "")
    return $version.Major -ge 18
}

# 4. Vérifier pnpm
Test-Requirement "PNPM installé" {
    pnpm --version 2>$null
    return $LASTEXITCODE -eq 0
} {
    npm install -g pnpm
}

# 5. Vérifier structure du projet
Test-Requirement "Structure monorepo valide" {
    $required = @("apps/api", "apps/web", "apps/admin", "package.json", "pnpm-workspace.yaml")
    foreach ($path in $required) {
        if (!(Test-Path $path)) {
            return $false
        }
    }
    return $true
}

# 6. Vérifier variables d'environnement template
Test-Requirement "Variables d'environnement prêtes" {
    return (Test-Path "pipeline/config.json")
}

# 7. Backup configuration Vercel
Write-Host "💾 Backup configuration Vercel..." -ForegroundColor Yellow
if (Test-Path "vercel.json") {
    Copy-Item "vercel.json" "vercel.json.backup" -Force
    Write-Host "✅ Backup Vercel créé" -ForegroundColor Green
}

# 8. Test des endpoints API (si dev server disponible)
Test-Requirement "API endpoints accessibles (optionnel)" {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:4000/health" -Method GET -TimeoutSec 5
        return $response.status -eq "ok"
    } catch {
        # Pas critique si le serveur dev n'est pas lancé
        Write-Host "⚠️ Serveur dev non disponible (normal)" -ForegroundColor Yellow
        return $true
    }
}

# Résumé
Write-Host ""
Write-Host "📊 RÉSUMÉ VALIDATION PRÉ-MIGRATION" -ForegroundColor Blue
Write-Host "====================================" -ForegroundColor Blue

if ($script:errors.Count -eq 0) {
    Write-Host "✅ Toutes les validations passées" -ForegroundColor Green
    Write-Host "🚀 Prêt pour la migration Railway" -ForegroundColor Green
    
    # Créer marker de validation
    @{
        timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        validation = "passed"
        commit = (git rev-parse HEAD)
    } | ConvertTo-Json | Out-File "pipeline/.pre-migration-passed" -Encoding UTF8
    
    exit 0
} else {
    Write-Host "❌ Erreurs détectées:" -ForegroundColor Red
    foreach ($error in $script:errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "🔧 Pour corriger automatiquement: .\pre-migration.ps1 -Force" -ForegroundColor Yellow
    exit 1
}