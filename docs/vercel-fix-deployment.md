# 🚀 Guide de Déploiement Vercel - SOLUTION CORRIGÉE

## ❌ Problème résolu : `functions` vs `builds`

Le problème était que Vercel ne permet pas d'utiliser `functions` et `builds` ensemble dans le même `vercel.json`. 

## ✅ Solution mise en place

### 1. Configuration simplifiée - Approche par App

Au lieu d'un monorepo complexe, nous déployons chaque application séparément :

#### 📱 **Option A : Déploiement par application (Recommandé)**

1. **Site Web Principal** (apps/web)
   ```bash
   # Déployer le site web
   cd apps/web
   vercel --prod
   ```

2. **Admin Dashboard** (apps/admin)
   ```bash
   # Déployer l'admin
   cd apps/admin 
   vercel --prod
   ```

3. **API Backend** (apps/api)
   ```bash
   # Déployer l'API
   cd apps/api
   vercel --prod
   ```

#### 🔗 **Option B : Monorepo unifié (Alternative)**

Si vous préférez garder tout ensemble, utilisez cette configuration :

1. **Connectez le repo complet** à Vercel
2. **Root Directory** : Laissez vide
3. **Framework** : Other
4. **Build Command** : `pnpm run build`
5. **Output Directory** : `apps/web/.next`

### 2. Variables d'environnement par projet

#### Pour chaque déploiement, ajoutez :

**Site Web & Admin :**
```env
NODE_ENV=production
NEXT_PUBLIC_API_URL=https://votre-api.vercel.app/api
```

**API :**
```env
NODE_ENV=production
JWT_SECRET=votre-cle-secrete-64-caracteres
DATABASE_URL=votre-url-database
```

### 3. URLs finales

Si déployé séparément :
```
🌐 Site Web     : https://soil-business-web.vercel.app/
⚙️ Admin        : https://soil-business-admin.vercel.app/
🔗 API          : https://soil-business-api.vercel.app/
```

Si déployé ensemble :
```
🌐 Tout-en-un   : https://soil-business.vercel.app/
```

## 🛠️ Déploiement Rapide (Méthode Recommandée)

### Étape 1 : Déployer l'API d'abord
```bash
cd apps/api
vercel --prod
# Notez l'URL : https://soil-business-api.vercel.app
```

### Étape 2 : Déployer le site web
```bash
cd ../web
# Mettre à jour NEXT_PUBLIC_API_URL dans les settings Vercel
vercel --prod
```

### Étape 3 : Déployer l'admin
```bash
cd ../admin
# Mettre à jour NEXT_PUBLIC_API_URL dans les settings Vercel
vercel --prod
```

## 🔧 Test de la solution

```bash
# Test API
curl https://soil-business-api.vercel.app/health

# Test Site Web (dans le navigateur)
# https://soil-business-web.vercel.app/

# Test Admin (dans le navigateur)  
# https://soil-business-admin.vercel.app/
```

## 📝 Avantages de cette approche

✅ **Pas de conflit** entre `functions` et `builds`
✅ **Déploiement plus simple** - une app à la fois
✅ **Meilleure isolation** - chaque service indépendant
✅ **Scaling séparé** - optimisations par service
✅ **Debugging facile** - logs séparés par service

## 🎯 Prochaines étapes

1. **Choisir la méthode** (séparée recommandée)
2. **Déployer l'API** en premier
3. **Noter l'URL API** 
4. **Déployer web/admin** avec la bonne URL API
5. **Tester** chaque service individuellement

Cette approche résout complètement le problème Vercel ! 🚀