# Export et Déploiement - Script d'automatisation

## 🚀 Script de déploiement automatique

```bash
#!/bin/bash
# deploy.sh - Script de déploiement SOIL-BUSINESS

echo "🚀 Déploiement SOIL-BUSINESS en cours..."

# 1. Build de tous les packages
echo "📦 Build des applications..."
pnpm run build

# 2. Export des applications statiques
echo "📤 Export des interfaces..."

# Export Next.js Web App
cd apps/web
npx next export
cd ../..

# Export Next.js Admin
cd apps/admin  
npx next export
cd ../..

echo "✅ Export terminé !"
echo "📁 Fichiers exportés dans:"
echo "   - apps/web/out/"
echo "   - apps/admin/out/"

# 3. Push vers GitHub (déclenchera le déploiement Vercel)
echo "📤 Push vers GitHub..."
git add .
git commit -m "Production export: Ready for deployment"
git push origin main

echo "🎉 Déploiement lancé ! Vérifiez Vercel Dashboard."
```

## 🎯 Export manuel des interfaces

### Web Application (Site principal)
```bash
cd apps/web
npx next build
npx next export
```

### Admin Dashboard  
```bash
cd apps/admin
npx next build
npx next export
```

### API (déjà buildé)
```bash
cd apps/api
pnpm run build
# Génère dist/ pour déploiement
```

## 📁 Structure après export

```
apps/
├── web/
│   ├── out/           # 🌐 Site exporté (statique)
│   │   ├── index.html
│   │   ├── deals/
│   │   └── _next/
│   └── .next/         # Build cache
├── admin/
│   ├── out/           # ⚙️ Admin exporté (statique)  
│   │   ├── index.html
│   │   ├── deals/
│   │   └── _next/
│   └── .next/         # Build cache
└── api/
    └── dist/          # 🔗 API compilée (TypeScript → JS)
        ├── index.js
        ├── routes/
        └── lib/
```

## 🔗 URLs de production (après Vercel)

- **Site Web** : https://soil-business.vercel.app/
- **Admin** : https://soil-business.vercel.app/admin/  
- **API** : https://soil-business.vercel.app/api/
- **Health** : https://soil-business.vercel.app/api/health

## ⚡ Export rapide

```bash
# Tout en une commande
pnpm run build && echo "✅ Applications prêtes pour déploiement"
```