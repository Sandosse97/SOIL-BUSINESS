# 🚀 Déploiement SOIL-BUSINESS sur Vercel - Guide Prêt à l'Emploi

## ✅ Statut: Code prêt pour la production

Votre monorepo a été buildé avec succès et pushé sur GitHub. Voici les étapes pour déployer immédiatement.

## 🔗 Liens de déploiement

### 1. Connecter à Vercel (2 minutes)

1. **Allez sur [vercel.com](https://vercel.com)**
2. **Connectez-vous** avec votre compte GitHub
3. **Cliquez "New Project"**
4. **Sélectionnez** le repository `SOIL-BUSINESS`
5. **Cliquez "Deploy"** - Vercel détecte automatiquement la configuration

### 2. Configurer les variables d'environnement

Dans le dashboard Vercel → Settings → Environment Variables, ajoutez :

#### 🔧 Variables essentielles (minimum pour démarrer)
```bash
NODE_ENV=production
API_URL=https://votre-app.vercel.app
NEXT_PUBLIC_API_URL=https://votre-app.vercel.app/api
```

#### 🗄️ Base de données (choisir une option)

**Option A: PlanetScale (recommandé - gratuit)**
```bash
DATABASE_URL=mysql://username:password@host/database?sslaccept=strict
```

**Option B: Neon PostgreSQL (gratuit)**
```bash
DATABASE_URL=postgresql://username:password@host:5432/database?sslmode=require
```

**Option C: Supabase (gratuit)**
```bash
DATABASE_URL=postgresql://postgres:[password]@db.[ref].supabase.co:5432/postgres
```

#### 🔐 Sécurité (générer des clés aléatoires)
```bash
JWT_SECRET=votre-cle-secrete-longue-et-aleatoire-64-caracteres-minimum
```

#### 💳 Paiements Stripe (optionnel)
```bash
STRIPE_SECRET_KEY=sk_test_votre_cle_stripe
STRIPE_PUBLISHABLE_KEY=pk_test_votre_cle_publique_stripe
```

### 3. URLs après déploiement

Une fois déployé, votre application sera disponible sur :

```
🌐 Site Principal    : https://soil-business.vercel.app/
⚙️ Admin Dashboard   : https://soil-business.vercel.app/admin/
🔗 API Backend       : https://soil-business.vercel.app/api/
📊 Health Check      : https://soil-business.vercel.app/api/health
```

## 📋 Checklist de déploiement

### Avant le déploiement
- [x] ✅ Code buildé avec succès
- [x] ✅ Poussé sur GitHub
- [x] ✅ Configuration Vercel (`vercel.json`) présente
- [x] ✅ Scripts de build configurés

### Après le déploiement
- [ ] ⏳ Configurer les variables d'environnement
- [ ] ⏳ Tester l'API : `https://votre-app.vercel.app/api/health`
- [ ] ⏳ Tester le site web : `https://votre-app.vercel.app/`
- [ ] ⏳ Tester l'admin : `https://votre-app.vercel.app/admin/`
- [ ] ⏳ Configurer une base de données
- [ ] ⏳ Tester l'authentification

## 🗄️ Configuration Base de Données (Recommandations)

### PlanetScale (Le plus simple)
1. Allez sur [planetscale.com](https://planetscale.com)
2. Créez un compte gratuit
3. Créez une base `soil-business`
4. Copiez la connection string dans Vercel
5. Lancez les migrations : déployez puis allez dans Vercel Functions → Logs

### Neon (Alternative)
1. Allez sur [neon.tech](https://neon.tech)
2. Créez une base PostgreSQL
3. Copiez l'URL de connexion

## 🔧 Après déploiement - Actions recommandées

### 1. Tester les endpoints
```bash
# Health check
curl https://soil-business.vercel.app/api/health

# Authentification (dev)
curl -X POST https://soil-business.vercel.app/api/auth/request-otp \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'
```

### 2. Configurer le domaine personnalisé (optionnel)
1. **Vercel Dashboard** → Settings → Domains
2. **Ajouter** `meetloview.com` (ou votre domaine)
3. **Configurer DNS** selon les instructions Vercel

### 3. Monitoring et performance
- **Analytics** : Activés automatiquement dans Vercel
- **Error tracking** : Ajouter Sentry (optionnel)
- **Uptime monitoring** : UptimeRobot ou similar

## 🚨 Résolution de problèmes

### Build échoue
```bash
# Vérifiez localement
pnpm run build

# Vérifiez les logs Vercel dans le dashboard
```

### API ne répond pas
1. Vérifiez les variables d'environnement dans Vercel
2. Regardez les logs des Functions
3. Testez : `https://votre-app.vercel.app/api/health`

### Base de données connection
1. Vérifiez `DATABASE_URL` dans les variables Vercel
2. Assurez-vous que l'URL inclut SSL (`?sslmode=require`)

## 📞 Support

- **Documentation Vercel** : [vercel.com/docs](https://vercel.com/docs)
- **Status page** : [vercel-status.com](https://vercel-status.com)
- **Community** : [GitHub Discussions](https://github.com/vercel/vercel/discussions)

## 🎯 Étapes suivantes après déploiement

1. **Authentification réelle** : Remplacer les stubs par OAuth
2. **Données réelles** : Ajouter du contenu via l'admin
3. **Tests E2E** : Vérifier tous les flows
4. **Performance** : Optimiser avec Vercel Analytics
5. **SEO** : Ajouter metadata et sitemap

---

## ⚡ Déployment Rapide (TL;DR)

1. **Vercel.com** → Connect GitHub → Import `SOIL-BUSINESS`
2. **Deploy** (automatique)
3. **Settings** → Add env vars → `NODE_ENV=production`
4. **Tester** : `https://soil-business.vercel.app/api/health`

🎉 **Votre application est maintenant live !**