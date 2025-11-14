# AstroJones Deployments

**Central deployment orchestration and registry for all AstroJones applications**

## 🎯 Purpose

This repository serves as the deployment control plane:

1. **Build Orchestrator:** Receives dispatch events from app repos, checks out code, builds Docker images
2. **Deployment Manager:** Pushes images to GHCR, SSH deploys to host with generated docker-compose.yml
3. **Registry:** Tracks all deployments via `registry.json` + GitHub Topics
4. **Security Hub:** Centralizes SSH/Registry credentials - app repos only need dispatch permissions

## 🏗️ Architecture

```
App Repo (push/PR) → repository_dispatch → This Repo → Checkout → Build → Push GHCR → SSH Deploy
                                              ↓
                                         registry.json
                                              ↓
                                        GitHub Topics
```

## 📋 Workflows

### `deploy-service.yml`

Handles three dispatch event types:

- **deploy-prod:** Build + deploy production
- **deploy-preview:** Build + deploy PR preview
- **cleanup-preview:** Remove PR preview deployment

**Payload structure:**
```json
{
  "repository": "astrojones/my-app",
  "ref": "abc123",
  "app_name": "my-app",
  "domain": "app.astrojones.com",
  "image": "ghcr.io/astrojones/my-app:abc123",
  "port": "80"
}
```

## 🗂️ Registry

### `registry.json`

**Production deployments:**
```json
{
  "deployments": {
    "app-name": {
      "domain": "app.astrojones.com",
      "subdomain": "app",
      "base_domain": "astrojones.com",
      "image": "ghcr.io/astrojones/app:sha",
      "deployed_at": "2025-11-14T10:00:00Z",
      "commit": "abc123"
    }
  }
}
```

**Preview deployments:**
```json
{
  "preview_deployments": {
    "app-name-pr-42": {
      "domain": "42.app.preview.astrojones.com",
      "pr_number": 42,
      "base_domain": "astrojones.com",
      "subdomain": "app",
      "image": "ghcr.io/astrojones/app:pr-42",
      "deployed_at": "2025-11-14T10:00:00Z",
      "pr_url": "https://github.com/astrojones/my-app/pull/42"
    }
  }
}
```

### GitHub Topics

Each app repo gets tagged:
- `deployed` - Has active deployments
- `env-prod` - Has production deployment
- `env-preview` - Has preview deployments
- `domain-{domain-with-dashes}` - Domain mapping
- `has-preview-pr-{number}` - Specific PR previews

## 🛠️ Management Commands

```bash
# List all deployments
make list
make list-previews

# Restart service (SSH required)
make restart APP=myapp HOST=138.201.203.230

# View logs (SSH required)
make logs APP=myapp HOST=138.201.203.230

# Manual preview cleanup (SSH required)
make cleanup-preview APP=myapp-pr-123 HOST=138.201.203.230
```

## 🔒 Required Secrets

Set these in GitHub repo settings:

- `SSH_PRIVATE_KEY`: SSH key for deployment user
- `SSH_USER`: SSH username (non-root recommended)

## 📊 Required Variables

- `HOST_IP`: Target deployment server (e.g., 138.201.203.230)

## 🚀 Creating New App

1. Use `astrojones/deployment-template`
2. Configure domain variables in app repo
3. Set `DEPLOYMENTS_TOKEN` in app repo (write access to this repo)
4. Push to main → automatic deployment

## 📍 Host Requirements

- Traefik running with `edge` network
- Let's Encrypt configured (HTTP-01)
- Docker & Docker Compose installed
- SSH access for deployment user
- `/opt/apps/` directory writable by deploy user

## 🔍 Querying Deployments

**Via GitHub CLI:**
```bash
# All deployed repos
gh search repos --topic deployed --owner astrojones

# Find repo by domain
gh search repos --topic domain-app-astrojones-com --owner astrojones

# Active previews
gh search repos --topic env-preview --owner astrojones
```

**Via registry.json:**
```bash
# Production domains
jq -r '.deployments | to_entries[] | "\(.key): \(.value.domain)"' registry.json

# Preview URLs
jq -r '.preview_deployments | to_entries[] | "PR #\(.value.pr_number): \(.value.domain)"' registry.json
```

---

**Template:** [`astrojones/deployment-template`](https://github.com/astrojones/deployment-template)
