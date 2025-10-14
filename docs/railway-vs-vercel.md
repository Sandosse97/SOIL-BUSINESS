# 🚂 Railway vs Vercel - Guide de Migration

## ✅ Railway : Solution recommandée pour notre monorepo

Railway est **parfait pour notre cas d'usage** car il n'a pas les limitations de Vercel concernant les propriétés `functions` et `builds`.

### 🔥 Avantages de Railway pour SOIL-BUSINESS

1. **✅ Monorepo support natif** - pas de configuration complexe
2. **✅ Base de données incluse** - PostgreSQL gratuit intégré
3. **✅ Variables d'environnement partagées** entre services
4. **✅ Logs en temps réel** pour debugging
5. **✅ Déploiement git automatique** depuis GitHub
6. **✅ Pas de limite functions/builds** - peut tout faire

---

## 🚀 Guide de Migration vers Railway

### Étape 1 : Configuration Railway
```bash
# Installation CLI Railway
npm install -g @railway/cli

# Login
railway login

# Initialiser le projet
railway init
```

### Étape 2 : Configuration du projet

#### railway.json (configuration monorepo)
```json
{
  "deploy": {
    "startCommand": "pnpm start",
    "buildCommand": "pnpm run build"
  },
  "environments": {
    "production": {
      "variables": {
        "NODE_ENV": "production"
      }
    }
  }
}
```

#### Configuration par service

**API Service :**
```json
{
  "name": "soil-business-api",
  "source": "apps/api",
  "build": {
    "command": "pnpm run build",
    "output": "dist"
  },
  "start": {
    "command": "node dist/index.js"
  },
  "variables": {
    "PORT": "$PORT",
    "NODE_ENV": "production"
  }
}
```

**Web Service :**
```json
{
  "name": "soil-business-web", 
  "source": "apps/web",
  "build": {
    "command": "pnpm run build"
  },
  "start": {
    "command": "pnpm start"
  }
}
```

**Admin Service :**
```json
{
  "name": "soil-business-admin",
  "source": "apps/admin", 
  "build": {
    "command": "pnpm run build"
  },
  "start": {
    "command": "pnpm start"
  }
}
```

### Étape 3 : Base de données Railway

Railway fournit PostgreSQL gratuit :

```bash
# Ajouter une base de données
railway add postgresql

# Railway génère automatiquement :
# DATABASE_URL=postgresql://username:password@host:port/database
```

### Étape 4 : Variables d'environnement

Dans Railway Dashboard :

```env
# Partagées entre tous les services
NODE_ENV=production
JWT_SECRET=votre-cle-secrete-64-caracteres

# API
DATABASE_URL=${{Postgres.DATABASE_URL}}
PORT=${{PORT}}

# Web/Admin  
NEXT_PUBLIC_API_URL=${{soil-business-api.RAILWAY_PUBLIC_DOMAIN}}/api
```

### Étape 5 : Déploiement

```bash
# Déployer tout le monorepo
railway up

# Ou déployer service par service
railway up --service api
railway up --service web  
railway up --service admin
```

---

## 📊 Comparaison détaillée

| Fonctionnalité | Railway | Vercel |
|----------------|---------|--------|
| **Monorepo** | ✅ Natif | ⚠️ Complexe |
| **Base de données** | ✅ Incluse | ❌ Externe |
| **Functions + Builds** | ✅ Pas de conflit | ❌ Conflit |
| **Variables d'env** | ✅ Partagées | ⚠️ Par projet |
| **Logs temps réel** | ✅ Oui | ⚠️ Limités |
| **Next.js** | ✅ Support | ✅ Optimisé |
| **CDN Global** | ⚠️ Basique | ✅ Premium |
| **Prix** | ✅ $5/mois | ✅ Gratuit + limits |

---

## 🎯 Recommandation

**Pour SOIL-BUSINESS, Railway est le meilleur choix car :**

1. **✅ Résout le problème Vercel** (functions/builds)
2. **✅ Simplifie le déploiement** monorepo 
3. **✅ Base de données incluse** (économise PlanetScale)
4. **✅ Variables d'environnement** plus logiques
5. **✅ Debugging plus facile** (logs temps réel)

---

## 🚀 Migration rapide (15 minutes)

```bash
# 1. Installer Railway CLI
npm install -g @railway/cli

# 2. Login et init
railway login
railway init

# 3. Connect GitHub repo
railway connect

# 4. Ajouter base de données
railway add postgresql

# 5. Configurer variables d'environnement
railway variables set NODE_ENV=production

# 6. Déployer
railway up
```

**Résultat :** Application déployée avec URLs comme :
- API: `https://soil-business-api.railway.app`
- Web: `https://soil-business-web.railway.app`  
- Admin: `https://soil-business-admin.railway.app`

---

## 🔧 Migration depuis Vercel

Si vous avez déjà configuré Vercel, la migration est simple :

1. **Garder le code** exactement pareil
2. **Supprimer** `vercel.json` 
3. **Ajouter** `railway.json`
4. **Migrer** variables d'environnement
5. **Connecter** Railway au repo GitHub

**Aucun changement de code nécessaire !** 🎉

Railway respecte la structure existante et les scripts npm/pnpm.