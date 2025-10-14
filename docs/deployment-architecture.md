# SOIL-BUSINESS Deployment Architecture

## Overview

This document outlines the production deployment architecture for the SOIL-BUSINESS / Meetloview application.

## Architecture Flow

```
[Browser/Mobile App] 
    ↓
Cloudflare (DNS + Proxy + SSL + CDN)
    ↓
Backend Host (API + Web App)
    ↓
Database (PostgreSQL)
```

## Components

### 1. Frontend Layer - Cloudflare
- **DNS Management**: Route domain to backend host
- **SSL/TLS**: Automatic HTTPS certificates
- **CDN**: Global content delivery for static assets
- **DDoS Protection**: Built-in security
- **Analytics**: Traffic and performance metrics

### 2. Backend Hosting Options

#### Option A: Render (Recommended for MVP)
- **Pros**: Simple deployment, PostgreSQL included, automatic builds
- **Cons**: Cold starts on free tier
- **Cost**: ~$7-25/month for production
- **Setup**: Connect GitHub repo, auto-deploy on push

#### Option B: Railway
- **Pros**: Excellent DX, built-in PostgreSQL, fast deploys
- **Cons**: Pricing can scale quickly
- **Cost**: ~$5-20/month for small apps
- **Setup**: Railway CLI or GitHub integration

#### Option C: Vercel (API) + PlanetScale (DB)
- **Pros**: Serverless, excellent performance, generous free tier
- **Cons**: Vendor lock-in, complexity for full-stack apps
- **Cost**: Free tier available, ~$20/month for production
- **Setup**: Vercel CLI, PlanetScale CLI

#### Option D: VPS (DigitalOcean/Linode)
- **Pros**: Full control, predictable pricing
- **Cons**: Requires DevOps knowledge
- **Cost**: ~$5-10/month + management time
- **Setup**: Docker Compose + reverse proxy

## Recommended Tech Stack

### Backend (API)
- **Runtime**: Node.js (Fastify)
- **Database**: PostgreSQL + Prisma ORM
- **Auth**: JWT + OAuth (Clerk/Auth0)
- **Environment**: Docker containers

### Frontend (Web)
- **Framework**: Next.js (React)
- **Hosting**: Static generation + API routes
- **CDN**: Cloudflare for assets

### Mobile
- **Framework**: Expo (React Native)
- **Distribution**: Expo EAS Build
- **Updates**: Expo OTA updates

## Environment Configuration

### Production Environment Variables
```bash
# Database
DATABASE_URL=postgresql://username:password@host:5432/database

# API Configuration
NODE_ENV=production
PORT=4000
API_URL=https://api.yourdomain.com

# Authentication
JWT_SECRET=your-long-random-secret
OAUTH_CLIENT_ID=your-oauth-client-id
OAUTH_CLIENT_SECRET=your-oauth-client-secret
OAUTH_REDIRECT_URI=https://api.yourdomain.com/auth/callback

# Cloudflare (if using API)
CLOUDFLARE_API_TOKEN=your-cloudflare-token
CLOUDFLARE_ZONE_ID=your-zone-id

# Email/Notifications
SMTP_HOST=smtp.sendgrid.net
SMTP_USER=apikey
SMTP_PASS=your-sendgrid-key
```

### Cloudflare Configuration

#### DNS Records
```
Type    Name    Content                     Proxy
A       @       your-backend-ip             ✅ Proxied
CNAME   api     your-backend-host.com       ✅ Proxied
CNAME   www     yourdomain.com              ✅ Proxied
```

#### Page Rules
```
# Cache API responses (optional)
api.yourdomain.com/*
- Cache Level: Standard
- Edge Cache TTL: 2 hours

# Force HTTPS
http://*yourdomain.com/*
- Always Use HTTPS: On
```

## Deployment Process

### 1. Initial Setup
1. **Domain**: Register domain, point nameservers to Cloudflare
2. **Backend**: Choose hosting provider, create account
3. **Database**: Provision PostgreSQL instance
4. **Repository**: Connect GitHub to hosting provider

### 2. Configuration
1. **Environment Variables**: Set production env vars
2. **Database**: Run Prisma migrations
3. **DNS**: Configure Cloudflare records
4. **SSL**: Verify HTTPS works end-to-end

### 3. CI/CD Pipeline
```yaml
# Example GitHub Action (.github/workflows/deploy.yml)
name: Deploy to Production
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: pnpm install
      
      - name: Run tests
        run: pnpm test
      
      - name: Build API
        run: pnpm --filter api build
      
      - name: Deploy to Render
        # Render auto-deploys on push to main
        run: echo "Deployment triggered"
```

## Security Considerations

### Cloudflare Security
- Enable "Under Attack Mode" if needed
- Configure Bot Fight Mode
- Set up rate limiting rules
- Enable DNSSEC

### Backend Security
- Use environment variables for secrets
- Enable CORS with specific origins
- Implement rate limiting
- Use HTTPS everywhere
- Regular security updates

### Database Security
- Use connection pooling
- Enable SSL connections
- Regular backups
- Restrict network access

## Monitoring & Observability

### Recommended Tools
- **Uptime**: UptimeRobot or Cloudflare Analytics
- **Errors**: Sentry for error tracking
- **Logs**: Hosting provider logs + structured logging
- **Performance**: Lighthouse CI for web vitals

### Health Checks
```javascript
// apps/api/src/routes/health.ts
app.get('/health', async (request, reply) => {
  return {
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version,
    database: await checkDatabaseConnection()
  }
})
```

## Cost Estimation (Monthly)

### MVP/Small Scale
- Cloudflare: Free
- Render: $7 (Starter)
- Database: Included with Render
- **Total**: ~$7/month

### Growing Business
- Cloudflare Pro: $20
- Railway/Render: $25-50
- Monitoring: $10-20
- **Total**: ~$55-90/month

### Production Scale
- Cloudflare Business: $200
- Dedicated hosting: $50-200
- Monitoring/Tools: $50-100
- **Total**: ~$300-500/month

## Next Steps

1. **Choose hosting provider** based on budget and requirements
2. **Set up staging environment** for testing
3. **Configure domain and DNS** through Cloudflare
4. **Implement health checks and monitoring**
5. **Set up automated deployments**
6. **Test disaster recovery procedures**

---

*Last updated: October 2025*