# 🚂 Guide de Déploiement Railway - SOLUTION COMPLÈTE

## ✅ Pourquoi Railway résout nos problèmes

Railway **n'a pas les limitations de Vercel** concernant `functions` vs `builds`. Vous pouvez utiliser **les deux propriétés ensemble** sans conflit !

---

## 🚀 Déploiement Railway en 5 étapes

### Étape 1 : Installation et Setup (2 minutes)

```bash
# Installer Railway CLI
npm install -g @railway/cli

# Se connecter
railway login

# Dans le répertoire du projet
cd C:\Users\exauc\SOIL-BUSINESS
railway init
```

### Étape 2 : Connecter GitHub (1 minute)

```bash
# Connecter le repository GitHub existant
railway connect

# Railway détecte automatiquement le monorepo
```

### Étape 3 : Configurer les Services (3 minutes)

Railway va créer **3 services automatiquement** :

#### 🔗 **API Service**
- **Source** : `apps/api/`
- **Build** : `pnpm run build`
- **Start** : `node dist/index.js`
- **Port** : `4000`

#### 🌐 **Web Service** 
- **Source** : `apps/web/`
- **Build** : `pnpm run build`
- **Start** : `pnpm start`
- **Framework** : Next.js détecté automatiquement

#### ⚙️ **Admin Service**
- **Source** : `apps/admin/`
- **Build** : `pnpm run build` 
- **Start** : `pnpm start`
- **Framework** : Next.js détecté automatiquement

### Étape 4 : Base de Données (1 minute)

```bash
# Ajouter PostgreSQL gratuit
railway add postgresql

# Railway génère automatiquement DATABASE_URL
```

### Étape 5 : Variables d'Environnement (3 minutes)

Dans Railway Dashboard, ajouter :

#### **Partagées (tous services) :**
```env
NODE_ENV=production
JWT_SECRET=votre-cle-secrete-64-caracteres-aleatoire
```

#### **API Service :**
```env
PORT=${{RAILWAY_PUBLIC_PORT}}
DATABASE_URL=${{Postgres.DATABASE_URL}}
```

#### **Web Service :**
```env
NEXT_PUBLIC_API_URL=${{api.RAILWAY_PUBLIC_DOMAIN}}/api
```

#### **Admin Service :**
```env
NEXT_PUBLIC_API_URL=${{api.RAILWAY_PUBLIC_DOMAIN}}/api
```

---

## 🎯 Déploiement Final

```bash
# Déployer tout le monorepo
railway up

# Ou service par service
railway deploy --service api
railway deploy --service web
railway deploy --service admin
```

---

## 🔗 URLs Finales

Après déploiement, vos applications seront disponibles sur :

```
🔗 API Backend       : https://soil-business-api.railway.app/
🌐 Site Principal    : https://soil-business-web.railway.app/
⚙️ Admin Dashboard   : https://soil-business-admin.railway.app/
📊 Health Check      : https://soil-business-api.railway.app/health
```

---

## 🧪 Tests Post-Déploiement

```bash
# Test API Health
curl https://soil-business-api.railway.app/health

# Test Auth API
curl -X POST https://soil-business-api.railway.app/auth/request-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'

# Test Web (navigateur)
# https://soil-business-web.railway.app/

# Test Admin (navigateur)
# https://soil-business-admin.railway.app/
```

---

## 💰 Coûts Railway

- **Starter Plan** : Gratuit (500 heures/mois)
- **Developer Plan** : $5/mois (illimité)
- **PostgreSQL** : Inclus dans tous les plans
- **Bande passante** : Illimitée

**Comparé à Vercel + PlanetScale = $0 + $39/mois → Railway = $5/mois tout inclus !**

---

## 🔧 Avantages spécifiques pour notre projet

### ✅ **Problèmes Vercel résolus :**
- **Functions + Builds** : Pas de conflit
- **Monorepo** : Support natif
- **Variables env** : Partagées entre services
- **Base de données** : Incluse (PostgreSQL)

### ✅ **Nouveaux avantages :**
- **Logs temps réel** : Debugging facile
- **Auto-scaling** : Adapte automatiquement
- **Zero-config** : Détection automatique des frameworks
- **Git integration** : Push = deploy automatique

---

## 🚨 Migration depuis Vercel

Si vous voulez migrer :

1. **Gardez** tout le code exactement pareil
2. **Supprimez** les fichiers `vercel.json` 
3. **Ajoutez** `railway.json` (optionnel)
4. **Connectez** Railway au repo GitHub
5. **Migrez** les variables d'environnement
6. **Testez** les nouvelles URLs

**Aucun changement de code requis !** 🎉

---

## 🎯 Commandes Rapides

```bash
# Setup complet en 3 commandes
railway login
railway init
railway up

# Vérifier le déploiement
railway status

# Voir les logs en temps réel
railway logs --follow

# Gérer les variables
railway variables set KEY=value
```

---

## 🏆 Résumé : Railway pour SOIL-BUSINESS

**Railway est la solution idéale** car :

1. ✅ **Résout le problème Vercel** (functions/builds)
2. ✅ **Base de données incluse** (économise $39/mois)
3. ✅ **Monorepo natif** (configuration simple)
4. ✅ **Variables partagées** (logique)
5. ✅ **Logs temps réel** (debugging facile)
6. ✅ **Auto-deploy** (push Git = deploy)
7. ✅ **$5/mois tout inclus** vs Vercel + DB external

**Prêt à migrer ? Ça prend 10 minutes ! 🚀**