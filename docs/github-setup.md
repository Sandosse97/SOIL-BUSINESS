# Guide: Importer SOIL-BUSINESS sur GitHub

## Méthode 1: Création directe depuis votre dossier local (Recommandée)

### Étape 1: Vérifier Git
```powershell
# Vérifier si Git est installé
git --version

# Si pas installé, téléchargez depuis: https://git-scm.com/download/win
```

### Étape 2: Initialiser le repository local
```powershell
# Naviguer vers votre projet
cd C:\Users\exauc\SOIL-BUSINESS

# Initialiser Git (si pas déjà fait)
git init

# Configurer votre identité Git
git config user.name "Votre Nom"
git config user.email "votre.email@example.com"
```

### Étape 3: Créer le repository sur GitHub
1. **Allez sur [github.com](https://github.com)**
2. **Cliquez "New repository"** (bouton vert)
3. **Nom du repository**: `SOIL-BUSINESS`
4. **Description**: "Application de prise de rendez-vous - Meetloview"
5. **Visibilité**: Public ou Private (selon votre préférence)
6. **⚠️ Important**: **NE cochez PAS** "Add a README file", "Add .gitignore", ou "Choose a license"
7. **Cliquez "Create repository"**

### Étape 4: Préparer les fichiers
```powershell
# Ajouter tous les fichiers au staging
git add .

# Créer le premier commit
git commit -m "Initial commit: SOIL-BUSINESS monorepo with API, web, admin, and mobile apps"
```

### Étape 5: Connecter et pousser vers GitHub
```powershell
# Ajouter l'origin remote (remplacez USERNAME par votre nom GitHub)
git remote add origin https://github.com/USERNAME/SOIL-BUSINESS.git

# Renommer la branche principale (optionnel, pour être conforme)
git branch -M main

# Pousser vers GitHub
git push -u origin main
```

---

## Méthode 2: Import depuis un autre repository existant

Si vous avez déjà un repository ailleurs:

### Via GitHub Interface
1. **GitHub** → "New repository"
2. **Cliquez "Import a repository"**
3. **URL source**: l'URL de votre repo existant
4. **Nouveau nom**: `SOIL-BUSINESS`
5. **Cliquez "Begin import"**

### Via ligne de commande
```powershell
# Cloner le repo existant
git clone --bare https://github.com/ancien-username/ancien-repo.git

# Naviguer dans le dossier
cd ancien-repo.git

# Pousser vers le nouveau repo
git push --mirror https://github.com/nouveau-username/SOIL-BUSINESS.git

# Nettoyer
cd ..
rmdir /s ancien-repo.git
```

---

## Fichiers à ajouter avant le push

### 1. .gitignore (racine du projet)
```gitignore
# Dependencies
node_modules/
.pnp
.pnp.js

# Production builds
dist/
build/
.next/
out/

# Environment variables
.env
.env.local
.env.production
.env.staging
*.env

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Prisma
.env

# Expo
.expo/
web-build/

# Vercel
.vercel

# Database
*.db
*.sqlite
*.sqlite3
```

### 2. README.md (racine du projet)
Créons un README principal pour le monorepo.

---

## Configuration recommandée après push

### 1. Protection de la branche main
1. **GitHub** → Votre repo → **Settings** → **Branches**
2. **Add rule** pour `main`
3. **Cochez**:
   - "Require a pull request before merging"
   - "Require status checks to pass before merging"

### 2. Secrets pour CI/CD
1. **Settings** → **Secrets and variables** → **Actions**
2. **Ajoutez**:
   - `DATABASE_URL`
   - `JWT_SECRET`
   - `VERCEL_TOKEN` (si vous utilisez Vercel)

### 3. GitHub Actions (optionnel)
Workflow pour tests automatiques sur chaque PR.

---

## Commandes utiles après setup

```powershell
# Vérifier le statut
git status

# Voir l'historique
git log --oneline

# Créer une nouvelle branche
git checkout -b feature/oauth-implementation

# Pousser une nouvelle branche
git push -u origin feature/oauth-implementation

# Synchroniser avec le remote
git pull origin main
```

---

## Troubleshooting

### Erreur: "remote origin already exists"
```powershell
git remote remove origin
git remote add origin https://github.com/USERNAME/SOIL-BUSINESS.git
```

### Erreur: "failed to push some refs"
```powershell
# Forcer le push (attention: écrase l'historique remote)
git push -f origin main

# Ou merger d'abord
git pull origin main --allow-unrelated-histories
git push origin main
```

### Gros fichiers ou node_modules déjà committés
```powershell
# Supprimer du cache Git
git rm -r --cached node_modules
git commit -m "Remove node_modules from tracking"

# Ajouter au .gitignore
echo "node_modules/" >> .gitignore
git add .gitignore
git commit -m "Add .gitignore"
```

---

## Prochaines étapes après GitHub

1. **Connecter Vercel**: Import depuis GitHub pour déploiement automatique
2. **Setup CI/CD**: GitHub Actions pour tests
3. **Issues/Projects**: Organiser les tâches de développement
4. **Collaborateurs**: Inviter d'autres développeurs si besoin

Le repository sera accessible à: `https://github.com/VOTRE-USERNAME/SOIL-BUSINESS`