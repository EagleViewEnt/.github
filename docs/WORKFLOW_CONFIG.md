# Workflow Configuration Guide

## Overview

The `.github/workflow-config.json` file provides centralized configuration for all CI/CD workflows in EagleViewEnt repositories.

## Benefits of Centralized Configuration

? **Single source of truth** - All workflow settings in one file  
? **Version controlled** - Track changes to CI/CD configuration  
? **Overridable** - Can override in workflow file when needed  
? **Reusable** - Same config structure across all repos  
? **Self-documenting** - Clear structure shows all options  

## Configuration File Structure

### Full Example

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

### Section: `workflow`

General workflow behavior settings.

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `dotnet-version` | string | `"10.0.x"` | .NET SDK version to use |
| `build-configuration` | string | `"Release"` | Build configuration (Debug/Release) |
| `run-tests` | boolean | `true` | Whether to run unit tests |
| `enable-code-coverage` | boolean | `true` | Collect code coverage |
| `restore-retry-count` | number | `3` | Number of restore retry attempts |

### Section: `packages`

NuGet package publishing and access settings.

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `publish` | boolean | `true` | Publish packages on main push |
| `visibility` | string | `"internal"` | Package visibility (internal/private/public) |
| `repositories` | array | `[]` | Repos with access (for private packages) |

**Visibility Options:**
- `"internal"` - All organization repositories (recommended)
- `"private"` - Only specified repositories
- `"public"` - Anyone can access

### Section: `authentication`

NuGet authentication and source configuration.

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `org-name` | string | `"EagleViewEnt"` | GitHub organization name |
| `additional-sources` | array | `[]` | Additional NuGet feed URLs |

## Usage Examples

### Simple Configuration

```json
{
  "workflow": {
    "dotnet-version": "10.0.x"
  },
  "packages": {
    "visibility": "internal"
  },
  "authentication": {
    "org-name": "EagleViewEnt"
  }
}
```

### Development Repository (No Publishing)

```json
{
  "workflow": {
    "dotnet-version": "10.0.x",
    "build-configuration": "Debug",
    "run-tests": true,
    "enable-code-coverage": false
  },
  "packages": {
    "publish": false
  },
  "authentication": {
    "org-name": "EagleViewEnt"
  }
}
```

### Private Package with Specific Access

```json
{
  "workflow": {
    "dotnet-version": "10.0.x"
  },
  "packages": {
    "publish": true,
    "visibility": "private",
    "repositories": [
      "EagleViewEnt/ProductionApp",
      "EagleViewEnt/StagingApp"
    ]
  },
  "authentication": {
    "org-name": "EagleViewEnt"
  }
}
```

### With Additional NuGet Sources

```json
{
  "workflow": {
    "dotnet-version": "10.0.x",
    "restore-retry-count": 5
  },
  "packages": {
    "publish": true,
    "visibility": "internal"
  },
  "authentication": {
    "org-name": "EagleViewEnt",
    "additional-sources": [
      "https://pkgs.dev.azure.com/myorg/_packaging/myfeed/nuget/v3/index.json",
      "https://my-private-nuget.com/v3/index.json"
    ]
  }
}
```

### .NET 9 Project

```json
{
  "workflow": {
    "dotnet-version": "9.0.x",
    "build-configuration": "Release"
  },
  "packages": {
    "publish": true,
    "visibility": "internal"
  },
  "authentication": {
    "org-name": "EagleViewEnt"
  }
}
```

## Overriding Configuration

You can override any setting in your workflow file:

```yaml
# .github/workflows/ci.yml
jobs:
  ci:
    uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main
    with:
      workflow-config: '.github/workflow-config.json'
      # Overrides:
      dotnet-version: '11.0.x'  # Override for preview testing
      build-configuration: 'Debug'  # Override for debug build
      publish-packages: false  # Disable publishing for this workflow
```

## Migration from Old Structure

### Before (`package-access.json`)

```json
{
  "repositories": [],
  "visibility": "internal"
}
```

### After (`workflow-config.json`)

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

**Migration Steps:**

1. Create `.github/workflow-config.json` with new structure
2. Update workflow to reference `workflow-config` instead of `package-access-config`
3. Delete old `.github/package-access.json` file
4. Test the workflow

## Best Practices

### ? Do

- **Keep defaults in config file** - Minimize workflow file complexity
- **Version control the config** - Track CI/CD changes
- **Use internal visibility** - Simplest for organization packages
- **Document custom settings** - Add comments to your config (as JSON doesn't support them, use a README)

### ? Don't

- **Don't hardcode in workflow** - Use config file instead
- **Don't duplicate settings** - Let config file be the source of truth
- **Don't commit secrets** - Never put tokens in config file
- **Don't use public visibility** - Unless package is truly open-source

## Validation

To validate your configuration file structure:

```powershell
# PowerShell validation script
$config = Get-Content .github/workflow-config.json | ConvertFrom-Json

# Check required sections
if (-not $config.workflow) { Write-Error "Missing 'workflow' section" }
if (-not $config.packages) { Write-Error "Missing 'packages' section" }
if (-not $config.authentication) { Write-Error "Missing 'authentication' section" }

# Check visibility value
$validVisibility = @('internal', 'private', 'public')
if ($config.packages.visibility -notin $validVisibility) {
  Write-Error "Invalid visibility: $($config.packages.visibility). Must be one of: $($validVisibility -join ', ')"
}

Write-Host "? Configuration is valid" -ForegroundColor Green
```

## Troubleshooting

### Config file not found

**Error:** `Config file not found, using defaults`

**Solution:** Ensure `.github/workflow-config.json` exists in repository root

### Invalid JSON

**Error:** `ConvertFrom-Json: Invalid JSON primitive`

**Solution:** Validate JSON syntax using `Get-Content .github/workflow-config.json | ConvertFrom-Json`

### Visibility not taking effect

**Issue:** Package visibility doesn't match config

**Solution:** 
1. Check the "Configure package access" step logs
2. Verify GitHub token has `packages: write` permission
3. Package visibility can only be changed after initial publish

## Related Documentation

- [Shared Workflows Guide](SHARED_WORKFLOWS.md) - Complete workflow usage
- [Centralized CI/CD](CENTRALIZED_CICD.md) - Overview and benefits
- [Authentication Setup](.github/actions/setup-github-packages-auth/README.md) - Authentication details

## Support

For configuration issues:
1. Validate JSON syntax
2. Check workflow logs for configuration loading step
3. Verify all required sections are present
4. Review override values in workflow file
