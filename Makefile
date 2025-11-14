.PHONY: list list-previews restart logs cleanup-preview

HOST ?= 138.201.203.230

list:
	@echo "=== Production Deployments ==="
	@jq -r '.deployments | to_entries[] | "\(.key): \(.value.domain) (\(.value.image))"' registry.json

list-previews:
	@echo "=== Preview Deployments ==="
	@jq -r '.preview_deployments | to_entries[] | "PR #\(.value.pr_number) - \(.key): \(.value.domain) (\(.value.image))"' registry.json

restart:
	@test -n "$(APP)" || (echo "Usage: make restart APP=name" && exit 1)
	ssh root@$(HOST) "cd /opt/apps/$(APP) && docker compose restart"

logs:
	@test -n "$(APP)" || (echo "Usage: make logs APP=name" && exit 1)
	ssh root@$(HOST) "cd /opt/apps/$(APP) && docker compose logs -f"

cleanup-preview:
	@test -n "$(APP)" || (echo "Usage: make cleanup-preview APP=name" && exit 1)
	ssh root@$(HOST) "cd /opt/apps/$(APP) && docker compose down -v && rm -rf /opt/apps/$(APP)"
