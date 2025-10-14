# 🚂 Pipeline de Migration Railway - SOIL-BUSINESS

## 🎯 Vue d'ensemble de la Pipeline

Cette pipeline automatise entièrement la migration de Vercel vers Railway avec validation, tests et rollback.

### 📋 Étapes de la Pipeline

1. **Pré-migration** - Validation et backup
2. **Setup Railway** - Installation et configuration
3. **Migration** - Déploiement des services
4. **Validation** - Tests et vérification
5. **Post-migration** - Cleanup et documentation

---

## 🔄 Pipeline Stages

### Stage 1: Pré-migration (Validation)
```yaml
validate:
  - ✅ Build local réussi
  - ✅ Tests passent
  - ✅ Variables d'environnement prêtes
  - ✅ Backup configuration Vercel
  - ✅ Git repo propre (committed)
```

### Stage 2: Setup Railway
```yaml
setup:
  - 🔧 Installation Railway CLI
  - 🔐 Authentification Railway
  - 🚀 Initialisation projet
  - 🔗 Connexion GitHub repo
  - 🗄️ Ajout base de données PostgreSQL
```

### Stage 3: Migration Services
```yaml
deploy:
  - 🔗 Service API (Node.js/Fastify)
  - 🌐 Service Web (Next.js)
  - ⚙️ Service Admin (Next.js)
  - 📱 Configuration Mobile (variables)
```

### Stage 4: Validation Post-migration
```yaml
validate:
  - 🧪 Health checks API
  - 🔍 Tests E2E sur chaque service
  - 📊 Monitoring et logs
  - ✅ Performance validation
```

### Stage 5: Finalisation
```yaml
finalize:
  - 📚 Documentation mise à jour
  - 🔄 DNS/domaines (si applicable)
  - 🗑️ Cleanup fichiers Vercel
  - 📊 Dashboard monitoring setup
```

---

## 🛠️ Fichiers de Pipeline

### GitHub Actions (.github/workflows/)
- `railway-migration.yml` - Pipeline principale
- `railway-deploy.yml` - Déploiement continu

### Scripts Pipeline (pipeline/)
- `run-pipeline.ps1` - Script principal orchestrateur
- `pre-migration.ps1` - Validation pré-migration
- `railway-setup.ps1` - Configuration Railway
- `migrate-services.ps1` - Migration des services
- `post-migration.ps1` - Validation et finalisation
- `rollback.ps1` - Procédure de rollback

### Configuration
- `pipeline/config.json` - Configuration pipeline
- `railway.json` - Configuration Railway
- `.env.railway` files - Variables par environnement

---

## 🚀 Utilisation de la Pipeline

### 🖥️ Exécution Locale (Recommandée)

```powershell
# Migration complète automatique
.\pipeline\run-pipeline.ps1

# Migration avec corrections automatiques
.\pipeline\run-pipeline.ps1 -Force

# Skip validation (déjà validé)
.\pipeline\run-pipeline.ps1 -SkipValidation

# Rollback complet
.\pipeline\run-pipeline.ps1 -Rollback
```

### ☁️ Exécution GitHub Actions

1. **Aller sur GitHub** → Actions tab
2. **Sélectionner** "Railway Migration Pipeline"
3. **Run workflow** avec options :
   - `migrate` - Migration complète
   - `rollback` - Rollback d'urgence
   - `validate-only` - Tests uniquement

### 🔧 Étapes individuelles

```powershell
# Exécution étape par étape
.\pipeline\pre-migration.ps1           # Validation
.\pipeline\railway-setup.ps1           # Setup Railway
.\pipeline\migrate-services.ps1        # Migration
.\pipeline\post-migration.ps1          # Finalisation
```

---

## ⚙️ Configuration Requise

### 🔐 Secrets GitHub (pour GitHub Actions)

Dans Settings → Secrets and variables → Actions :

```env
RAILWAY_TOKEN=your_railway_api_token
JWT_SECRET=your_64_character_jwt_secret
```

### 🛠️ Prérequis Locaux

```powershell
# Windows PowerShell
node --version    # v18+
pnpm --version    # v8+
git --version     # Any recent version
```

### 📦 Installation Automatique

La pipeline installe automatiquement :
- Railway CLI
- Toutes les dépendances npm/pnpm
- Configuration environnement

---

## 🧪 Tests et Validation

### 🔍 Tests Automatiques

1. **Pré-migration** :
   - Structure projet valide
   - Build réussi
   - Git propre

2. **Post-migration** :
   - Health checks API/Web/Admin
   - Tests fonctionnels endpoints
   - Performance basique
   - Connexion base de données

3. **Monitoring continu** :
   - Availability checks
   - Response time monitoring
   - Error rate tracking

### 📊 Métriques de Réussite

- ✅ **Build** : 100% réussite
- ✅ **Health Checks** : 3/3 services opérationnels
- ✅ **Performance** : < 5s response time
- ✅ **Fonctionnel** : Endpoints key testés

---

## 🔄 Procédures de Rollback

### 🚨 Rollback Automatique

```powershell
# Rollback complet avec scripts
.\pipeline\run-pipeline.ps1 -Rollback

# Rollback vers commit spécifique
.\pipeline\rollback.ps1 -BackupCommit abc123
```

### 🛠️ Rollback Manuel

1. **Railway Dashboard** :
   - Suspendre tous les services
   - Supprimer le projet

2. **Vercel Restoration** :
   - Restaurer `vercel.json`
   - Reconfigurer variables env
   - Redéployer

3. **Git Rollback** :
   ```bash
   git reset --hard COMMIT_HASH
   ```

---

## 📊 Monitoring et Observabilité

### 🔍 Logs et Debugging

```powershell
# Logs Railway temps réel
railway logs --follow

# Status des services
railway status

# Variables d'environnement
railway variables
```

### 📈 Métriques Importantes

- **Uptime** : 99.9% target
- **Response Time** : < 2s average
- **Error Rate** : < 1%
- **Database Connections** : Healthy

### 🚨 Alertes

- Health check failures
- Performance degradation
- Error rate spikes
- Resource usage alerts

---

## 🎯 Résultats Attendus

### ✅ Post-Migration Success

```
🎉 MIGRATION RAILWAY RÉUSSIE !
================================

🔗 Applications Live:
   API      : https://soil-business-api.railway.app/
   Web      : https://soil-business-web.railway.app/
   Admin    : https://soil-business-admin.railway.app/

📊 Métriques:
   Build Time    : ~5 minutes
   Health Checks : 3/3 passed
   Performance   : < 2s response
   Cost Saving   : $54/month vs Vercel

🚀 Next Steps:
   - Configure custom domains
   - Set up monitoring alerts
   - Optimize performance
   - Scale as needed
```

### 📋 Checklist Post-Migration

- [ ] ✅ Tous les services opérationnels
- [ ] ✅ Base de données connectée
- [ ] ✅ Variables d'environnement configurées
- [ ] ✅ DNS/domaines configurés (optionnel)
- [ ] ✅ Monitoring activé
- [ ] ✅ Documentation mise à jour
- [ ] ✅ Équipe informée des nouvelles URLs

---

## 📞 Support et Troubleshooting

### 🔧 Problèmes Courants

1. **Railway Authentication Failed**
   ```powershell
   # Solution: Régénérer token Railway
   railway login
   ```

2. **Build Failures**
   ```powershell
   # Solution: Vérifier dépendances
   pnpm install
   pnpm run build
   ```

3. **Health Checks Failed**
   ```powershell
   # Solution: Vérifier logs
   railway logs --follow
   ```

### 📚 Documentation

- **Pipeline** : `docs/railway-migration-pipeline.md`
- **Railway** : [docs.railway.app](https://docs.railway.app)
- **Troubleshooting** : `docs/railway-vs-vercel.md`

### 🆘 Support Channels

- **Railway** : [help.railway.app](https://help.railway.app)
- **Discord** : [railway.app/discord](https://railway.app/discord)
- **GitHub Issues** : Pour bugs pipeline

---

## 🏆 Avantages de Cette Pipeline

### ✅ **Automatisation Complète**
- Zero-touch migration
- Validation automatique
- Rollback sécurisé
- Tests intégrés

### ✅ **Robustesse**
- Error handling
- Retry mechanisms
- Health monitoring
- Performance validation

### ✅ **Flexibilité**
- Local ou CI/CD
- Étapes individuelles
- Configuration modulaire
- Multiple environnements

### ✅ **Observabilité**
- Logs détaillés
- Métriques temps réel
- Alertes automatiques
- Dashboard intégré

**🚀 Cette pipeline garantit une migration Railway sûre, rapide et réversible !**