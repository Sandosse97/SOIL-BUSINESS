# Guide de développement - SOIL-BUSINESS

## 🚀 Démarrage rapide (environnement visuel)

Maintenant que votre monorepo build avec succès, voici comment voir votre application en action :

### 1. Démarrer tous les services

#### Terminal 1 - API Backend
```powershell
cd C:\Users\exauc\SOIL-BUSINESS
pnpm --filter api dev
```
- **URL**: http://localhost:4000
- **Health check**: http://localhost:4000/health
- **Status**: ✅ En cours d'exécution

#### Terminal 2 - Application Web
```powershell
cd C:\Users\exauc\SOIL-BUSINESS
pnpm --filter web dev
```
- **URL**: http://localhost:3000
- **Description**: Site web principal Next.js
- **Status**: ✅ En cours d'exécution

#### Terminal 3 - Dashboard Admin
```powershell
cd C:\Users\exauc\SOIL-BUSINESS
pnpm --filter admin dev
```
- **URL**: http://localhost:3001
- **Description**: Interface d'administration
- **Status**: ✅ En cours d'exécution

#### Terminal 4 - App Mobile (optionnel)
```powershell
cd C:\Users\exauc\SOIL-BUSINESS\apps\mobile
npm run web
```
- **URL**: http://localhost:19006 (généralement)
- **Description**: Preview web de l'app mobile Expo

### 2. URLs d'accès rapide

| Service | URL | Description |
|---------|-----|-------------|
| 🔗 **API** | http://localhost:4000 | Backend Fastify |
| 🌐 **Web** | http://localhost:3000 | Site principal |
| ⚙️ **Admin** | http://localhost:3001 | Dashboard admin |
| 📱 **Mobile** | http://localhost:19006 | Preview Expo |

### 3. Endpoints API disponibles

```
GET  /health                    # Status de l'API
GET  /deals/auctions           # Liste des enchères
POST /auth/request-otp         # Demande OTP (dev)
POST /auth/verify-otp          # Vérification OTP (dev)
POST /payments/checkout        # Session Stripe
```

### 4. Pages web disponibles

**App Web (port 3000):**
- http://localhost:3000/ - Page d'accueil
- http://localhost:3000/deals - Liste des deals
- http://localhost:3000/deals/[id] - Détail d'un deal

**App Admin (port 3001):**
- http://localhost:3001/ - Dashboard admin
- http://localhost:3001/auth - Authentification
- http://localhost:3001/deals - Gestion des deals
- http://localhost:3001/deals/[id] - Détail et enchères

### 5. Données de test

L'API utilise des données de développement. L'authentification est en mode "dev" avec un utilisateur fictif :
```json
{
  "id": "dev-user-1",
  "email": "dev@example.com",
  "role": "ADMIN"
}
```

### 6. Prochaines étapes recommandées

#### A. Intégration base de données
1. **Configurer PostgreSQL** (local ou cloud)
2. **Mettre à jour `DATABASE_URL`** dans `.env`
3. **Lancer les migrations** : `pnpm --filter api prisma:migrate`

#### B. Authentification réelle
1. **Implémenter OAuth callback** (todo #2)
2. **Configurer JWT** avec des vraies clés
3. **Tester le flow complet**

#### C. Déploiement
1. **Pousser sur GitHub** : `git push origin main`
2. **Connecter à Vercel** avec le repo GitHub
3. **Configurer les variables d'environnement**

### 7. Commandes utiles

```powershell
# Tout builder
pnpm run build

# Lancer les tests
pnpm test

# Générer Prisma Client
pnpm --filter api prisma:generate

# Voir les logs en temps réel
# (dans chaque terminal de service)

# Arrêter tous les services
# Ctrl+C dans chaque terminal
```

### 8. Résolution de problèmes

#### Port déjà utilisé
```powershell
netstat -ano | findstr :4000
taskkill /F /PID [PID_NUMBER]
```

#### Prisma Client manquant
```powershell
cd apps/api
pnpm prisma:generate
```

#### Dépendances manquantes
```powershell
pnpm install
```

---

## ✅ État actuel

🎉 **Votre monorepo est opérationnel !**

- ✅ API Backend (Fastify + TypeScript)
- ✅ Application Web (Next.js)
- ✅ Dashboard Admin (Next.js)
- ✅ App Mobile (Expo, prête)
- ✅ Build production réussi
- ✅ Configuration Vercel prête

**Vous pouvez maintenant voir et tester visuellement votre application !**

Pour continuer le développement, consultez la todo list ou implémentez l'authentification OAuth.