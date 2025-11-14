# AstroJones Deployments

Central registry for all deployed applications.

## Structure

- `registry.json` - Production & preview deployment metadata
- `Makefile` - Management commands

## Usage

```bash
# List all deployments
make list
make list-previews

# Restart service
make restart APP=myapp

# View logs
make logs APP=myapp

# Cleanup preview
make cleanup-preview APP=myapp-pr-123
```

## Registry Format

```json
{
  "deployments": {
    "app-name": {
      "domain": "app.astrojones.com",
      "subdomain": "app",
      "image": "ghcr.io/astrojones/app:sha",
      "deployed_at": "2025-11-14T10:00:00Z",
      "commit": "abc123"
    }
  },
  "preview_deployments": {
    "app-name-pr-42": {
      "domain": "42.app.preview.astrojones.com",
      "pr_number": 42,
      "base_domain": "astrojones.com",
      "subdomain": "app",
      "image": "ghcr.io/astrojones/app:pr-42",
      "deployed_at": "2025-11-14T10:00:00Z"
    }
  }
}
```
