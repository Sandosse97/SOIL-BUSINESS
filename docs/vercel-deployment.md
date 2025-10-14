# Déploiement Vercel - Guide complet

## Prérequis

1. **Compte Vercel**: Créez un compte sur [vercel.com](https://vercel.com)
2. **GitHub connecté**: Liez votre repo GitHub à Vercel
3. **Base de données**: PlanetScale, Neon, ou Supabase (PostgreSQL)
4. **CLI Vercel** (optionnel): `npm i -g vercel`

## Configuration automatique (Recommandée)

### Étape 1: Préparer le monorepo

Le fichier `vercel.json` est déjà configuré pour déployer:
- **API**: `apps/api` → Functions serverless
- **Web**: `apps/web` → Site Next.js principal  
- **Admin**: `apps/admin` → Dashboard admin

### Étape 2: Variables d'environnement

Dans le dashboard Vercel, ajoutez ces variables:

```bash
# Database (PlanetScale/Neon/Supabase)
DATABASE_URL=postgresql://user:pass@host:5432/database

# API Configuration  
NODE_ENV=production
API_URL=https://votre-app.vercel.app

# Authentication
JWT_SECRET=your-super-long-random-secret-key-here
OAUTH_CLIENT_ID=your-oauth-client-id
OAUTH_CLIENT_SECRET=your-oauth-client-secret
OAUTH_REDIRECT_URI=https://votre-app.vercel.app/api/auth/callback

# Email/Notifications
SMTP_HOST=smtp.sendgrid.net
SMTP_USER=apikey
SMTP_PASS=your-sendgrid-api-key
```

### Étape 3: Déploiement GitHub

1. **Connecter le repo**: Allez sur vercel.com → "New Project" → Importez votre repo GitHub
2. **Configuration automatique**: Vercel détecte le monorepo
3. **Deploy**: Cliquez "Deploy" - première build en ~2-5 minutes

## Configuration manuelle (CLI)

Si vous préférez utiliser la CLI:

```bash
# Installer Vercel CLI
npm i -g vercel

# Se connecter
vercel login

# Déployer depuis la racine du projet
cd C:\Users\exauc\SOIL-BUSINESS
vercel

# Suivre les prompts:
# - Set up and deploy? Yes
# - Link to existing project? No  
# - Project name: soil-business
# - Directory: ./
```

## Structure des routes

Avec la config actuelle:

```
https://votre-app.vercel.app/          → apps/web (site principal)
https://votre-app.vercel.app/admin/    → apps/admin (dashboard)
https://votre-app.vercel.app/api/      → apps/api (API serverless)
```

## Base de données (Options)

### Option A: PlanetScale (Recommandée)
```bash
# Installer PlanetScale CLI
npm i -g @planetscale/cli

# Se connecter
pscale auth login

# Créer une DB
pscale database create soil-business

# Obtenir la connection string
pscale connect soil-business main --port 3309
# Puis copiez l'URL dans Vercel env vars
```

### Option B: Neon (Alternative)
1. Allez sur [neon.tech](https://neon.tech)
2. Créez une base PostgreSQL
3. Copiez la connection string dans les env vars Vercel

### Option C: Supabase
1. Allez sur [supabase.com](https://supabase.com)
2. Nouveau projet PostgreSQL
3. Copiez l'URL de connection

## Migration Prisma sur Vercel

Ajoutez ce script dans `apps/api/package.json`:

```json
{
  "scripts": {
    "vercel-build": "prisma generate && prisma migrate deploy && npm run build"
  }
}
```

Ou créez `apps/api/vercel-build.sh`:
```bash
#!/bin/bash
cd apps/api
npx prisma generate
npx prisma migrate deploy  
npm run build
```

## Optimisations Vercel

### 1. Mise en cache
Ajoutez dans `vercel.json`:
```json
{
  "headers": [
    {
      "source": "/api/static/(.*)",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=86400"
        }
      ]
    }
  ]
}
```

### 2. Redirections
```json
{
  "redirects": [
    {
      "source": "/old-path",
      "destination": "/new-path",
      "permanent": true
    }
  ]
}
```

## CI/CD avec GitHub

Vercel se déploie automatiquement:
- **Push sur `main`**: Déploiement production
- **Pull requests**: Preview deployments
- **Autres branches**: Preview deployments

## Domaine personnalisé

1. **Dashboard Vercel**: Settings → Domains
2. **Ajouter domaine**: `meetloview.com`
3. **DNS**: Pointer CNAME vers `cname.vercel-dns.com`
4. **SSL**: Automatique via Vercel

Avec Cloudflare:
```
Type    Name    Content                 Proxy
CNAME   @       cname.vercel-dns.com    🟡 DNS only
CNAME   www     meetloview.com          🟡 DNS only
```

## Monitoring

### Analytics Vercel (inclus)
- Trafic et performance
- Core Web Vitals
- Edge Functions metrics

### Monitoring externe
- **Uptime**: UptimeRobot
- **Errors**: Sentry (add to `apps/api` et `apps/web`)
- **Logs**: Vercel Functions logs

## Coûts Vercel

### Hobby (Gratuit)
- 100GB bandwidth/mois
- Functions: 100GB-hours
- Parfait pour MVP/test

### Pro ($20/mois)
- 1TB bandwidth
- Analytics avancées
- Support email
- Domaines illimités

## Troubleshooting

### Build fails
```bash
# Vérifier localement
cd apps/api
npm run build

cd ../web  
npm run build
```

### Database connection
- Vérifiez `DATABASE_URL` dans env vars
- Test connection: `npx prisma db push`

### Functions timeout
- Augmentez `maxDuration` dans `vercel.json`
- Optimisez les requêtes DB

## Commandes utiles

```bash
# Déployer preview
vercel

# Déployer production  
vercel --prod

# Voir les logs
vercel logs

# Variables d'environnement
vercel env add DATABASE_URL

# Rollback
vercel rollback [deployment-url]
```

---

## Prochaine étape recommandée

1. **Créez votre DB** (PlanetScale/Neon)
2. **Connectez GitHub** à Vercel
3. **Ajoutez les env vars** dans le dashboard
4. **Première deployment** automatique

Le déploiement sera disponible à `https://soil-business.vercel.app` en quelques minutes !