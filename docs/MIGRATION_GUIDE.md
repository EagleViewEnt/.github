# Migration Guide: package-access.json ? workflow-config.json

## Why the Change?

The configuration file has evolved beyond just package access to include:
- **Workflow settings** (.NET version, build config, testing)
- **Package publishing** (visibility, access control)
- **Authentication** (organization, NuGet sources)
- **Retry logic** (restore retry configuration)

The new name `workflow-config.json` better reflects its comprehensive purpose.

## Quick Migration

### Step 1: Create New Config File

**Before** (`.github/package-access.json`):
```json
{
  "repositories": [],
  "visibility": "internal"
}
```

**After** (`.github/workflow-config.json`):
```json
{
  "workflow": {
    "dotnet-version": "10.0.x",
    "build-configuration": "Release",
    "run-tests": true,
    "enable-code-coverage": true,
    "restore-retry-count": 3
  },
  "packages": {
    "publish": true,
    "visibility": "internal",
    "repositories": []
  },
  "authentication": {
    "org-name": "EagleViewEnt",
    "additional-sources": []
  }
}
```

### Step 2: Update Workflow Reference

**Before**:
```yaml
jobs:
  ci:
    uses: ./.github/workflows/reusable-dotnet-ci.yml
    with:
      dotnet-version: '10.0.x'
      build-configuration: 'Release'
      run-tests: true
      enable-code-coverage: true
      publish-packages: true
      package-projects: '["src/Project/Project.csproj"]'
      org-name: 'EagleViewEnt'
      package-access-config: '.github/package-access.json'
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**After**:
```yaml
jobs:
  ci:
    uses: ./.github/workflows/reusable-dotnet-ci.yml
    with:
      workflow-config: '.github/workflow-config.json'
      package-projects: '["src/Project/Project.csproj"]'
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Step 3: Remove Old File

```bash
git rm .github/package-access.json
git add .github/workflow-config.json
git commit -m "Migrate to centralized workflow-config.json"
```

## Automated Migration Script

```powershell
# migrate-config.ps1
param(
    [string]$RepoPath = "."
)

Set-Location $RepoPath

Write-Host "=== Migrating to workflow-config.json ===" -ForegroundColor Cyan

# Check if old config exists
if (-not (Test-Path ".github/package-access.json")) {
    Write-Host "No package-access.json found. Creating new workflow-config.json..." -ForegroundColor Yellow
    $oldConfig = @{
        visibility = "internal"
        repositories = @()
    }
} else {
    # Load old config
    $oldConfig = Get-Content ".github/package-access.json" | ConvertFrom-Json
    Write-Host "Loaded existing package-access.json" -ForegroundColor Green
}

# Create new config structure
$newConfig = @{
    workflow = @{
        "dotnet-version" = "10.0.x"
        "build-configuration" = "Release"
        "run-tests" = $true
        "enable-code-coverage" = $true
        "restore-retry-count" = 3
    }
    packages = @{
        publish = $true
        visibility = $oldConfig.visibility
        repositories = $oldConfig.repositories
    }
    authentication = @{
        "org-name" = "EagleViewEnt"
        "additional-sources" = @()
    }
}

# Write new config
$newConfigJson = $newConfig | ConvertTo-Json -Depth 10
New-Item -ItemType Directory -Force -Path ".github" | Out-Null
Set-Content -Path ".github/workflow-config.json" -Value $newConfigJson

Write-Host "? Created workflow-config.json" -ForegroundColor Green

# Backup old config
if (Test-Path ".github/package-access.json") {
    Move-Item ".github/package-access.json" ".github/package-access.json.backup" -Force
    Write-Host "? Backed up package-access.json" -ForegroundColor Green
}

Write-Host "`nMigration complete!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review .github/workflow-config.json"
Write-Host "2. Update workflow files to use 'workflow-config' input"
Write-Host "3. Test the workflow"
Write-Host "4. Delete .github/package-access.json.backup"
```

## Conversion Table

| Old (package-access.json) | New (workflow-config.json) | Notes |
|---------------------------|----------------------------|-------|
| `visibility` | `packages.visibility` | Same values |
| `repositories` | `packages.repositories` | Same structure |
| N/A | `workflow.*` | New settings section |
| N/A | `packages.publish` | New boolean flag |
| N/A | `authentication.*` | New auth section |

## What's New in workflow-config.json

### 1. Workflow Section
Controls build and test behavior:
- .NET version selection
- Build configuration (Debug/Release)
- Test execution
- Code coverage collection
- Retry logic configuration

### 2. Expanded Package Settings
Beyond just access control:
- Enable/disable publishing
- Visibility control
- Repository access

### 3. Authentication Configuration
Centralized auth settings:
- Organization name
- Additional NuGet sources
- Ready for future auth enhancements

## Benefits

### Before (Multiple Files/Settings)

```yaml
# Scattered across workflow file
jobs:
  ci:
    with:
      dotnet-version: '10.0.x'           # Here
      build-configuration: 'Release'      # Here
      run-tests: true                     # Here
      enable-code-coverage: true          # Here
      publish-packages: true              # Here
      org-name: 'EagleViewEnt'           # Here
      package-access-config: '...'        # Separate file
```

### After (Single Config File)

```yaml
# Clean workflow file
jobs:
  ci:
    with:
      workflow-config: '.github/workflow-config.json'  # Everything here
      package-projects: '["src/Project/Project.csproj"]'
```

```json
// All settings in one place
{
  "workflow": { "dotnet-version": "10.0.x", ... },
  "packages": { "visibility": "internal", ... },
  "authentication": { "org-name": "EagleViewEnt", ... }
}
```

## Backward Compatibility

The reusable workflow still supports the old approach:

```yaml
# Old style still works (but not recommended)
jobs:
  ci:
    uses: ./.github/workflows/reusable-dotnet-ci.yml@main
    with:
      dotnet-version: '10.0.x'
      build-configuration: 'Release'
      package-access-config: '.github/package-access.json'
      # ... all individual settings
```

However, we recommend migrating to the new structure for:
- ? Cleaner workflow files
- ? Centralized configuration
- ? Better organization
- ? Future enhancements

## Testing the Migration

1. **Create workflow-config.json** in your repository
2. **Update ci.yml** to reference it
3. **Push to a test branch**
4. **Verify workflow runs** successfully
5. **Check package publishing** (if applicable)
6. **Merge to main** once confirmed

## Rollback

If you need to rollback:

```bash
# Restore old config
git mv .github/package-access.json.backup .github/package-access.json

# Revert workflow changes
git checkout HEAD~1 .github/workflows/ci.yml

git commit -m "Rollback workflow config migration"
```

## Support

For migration issues:
- Review [Workflow Configuration Guide](WORKFLOW_CONFIG.md)
- Check [Shared Workflows Guide](SHARED_WORKFLOWS.md)
- Test in a feature branch first
- Contact DevOps team if blocked

## Timeline

- **Immediate**: New repositories should use `workflow-config.json`
- **Q1 2025**: Migrate existing repositories
- **Q2 2025**: Deprecate `package-access-config` input
- **Q3 2025**: Remove backward compatibility

Start migrating today to stay ahead! ??
