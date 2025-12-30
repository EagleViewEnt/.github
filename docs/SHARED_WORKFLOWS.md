# Shared Workflows Guide

This repository contains reusable workflows and actions for EagleViewEnt projects.

## Table of Contents

- [Reusable .NET CI Workflow](#reusable-net-ci-workflow)
- [GitHub Packages Authentication Action](#github-packages-authentication-action)
- [Package Access Configuration](#package-access-configuration)
- [Troubleshooting](#troubleshooting)

## Reusable .NET CI Workflow

### Quick Start

Create `.github/workflows/ci.yml` in your repository:

```yaml
name: CI

on: 
  pull_request:
    branches: [ main ]
  push:
    branches: [ main ]

permissions:
  contents: read
  packages: write

jobs:
  ci:
    uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main
    with:
      dotnet-version: '10.0.x'
      package-projects: '["src/YourProject/YourProject.csproj"]'
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Configuration Options

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `dotnet-version` | .NET SDK version | No | `10.0.x` |
| `build-configuration` | Build configuration | No | `Release` |
| `run-tests` | Run unit tests | No | `true` |
| `enable-code-coverage` | Collect code coverage | No | `true` |
| `publish-packages` | Publish NuGet packages on main push | No | `true` |
| `package-projects` | JSON array of project paths to pack | No | `[]` (all) |
| `org-name` | GitHub organization name | No | `EagleViewEnt` |
| `package-access-config` | Path to package access config | No | `.github/package-access.json` |
| `additional-nuget-sources` | Additional NuGet sources (JSON array) | No | `[]` |
| `restore-retry-count` | Package restore retry attempts | No | `3` |

### Examples

#### Simple Library (Single Project)

```yaml
jobs:
  ci:
    uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main
    with:
      package-projects: '["src/MyLib/MyLib.csproj"]'
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Multiple Projects

```yaml
jobs:
  ci:
    uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main
    with:
      package-projects: '["src/Core/Core.csproj", "src/Extensions/Extensions.csproj", "src/Utils/Utils.csproj"]'
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### With Additional NuGet Sources

```yaml
jobs:
  ci:
    uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main
    with:
      package-projects: '["src/MyProject/MyProject.csproj"]'
      additional-nuget-sources: '["https://my-private-feed.com/nuget/v3/index.json"]'
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Different .NET Version with Custom Retry

```yaml
jobs:
  ci:
    uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main
    with:
      dotnet-version: '9.0.x'
      restore-retry-count: 5
      package-projects: '["src/MyProject/MyProject.csproj"]'
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## GitHub Packages Authentication Action

For custom workflows, you can use the authentication action separately.

### Usage

```yaml
steps:
  - uses: actions/checkout@v4
  
  - uses: actions/setup-dotnet@v4
    with:
      dotnet-version: '10.0.x'
  
  - name: Setup GitHub Packages Auth
    uses: EagleViewEnt/.github/.github/actions/setup-github-packages-auth@main
    with:
      github-token: ${{ secrets.GITHUB_TOKEN }}
      org-name: 'EagleViewEnt'
  
  - name: Restore
    run: dotnet restore
  
  - name: Build
    run: dotnet build
```

### Action Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `github-token` | GitHub token for authentication | Yes | - |
| `org-name` | GitHub organization name | No | `EagleViewEnt` |
| `additional-sources` | Additional NuGet sources (JSON array) | No | `[]` |

### What the Action Does

? **Removes conflicting NuGet sources** - Cleans up existing GitHub/nuget.org sources
? **Adds nuget.org** - Official NuGet package source
? **Configures GitHub Packages** - With proper authentication
? **Creates nuget.config** - With embedded credentials for restore
? **Backs up existing config** - Preserves your original nuget.config
? **Verifies configuration** - Lists all configured sources

## Package Access Configuration

Create `.github/package-access.json` in your repository:

### Internal Visibility (All Org Repos)

```json
{
  "repositories": [],
  "visibility": "internal"
}
```

### Private with Specific Repos

```json
{
  "repositories": [
    "EagleViewEnt/AppRepo1",
    "EagleViewEnt/AppRepo2"
  ],
  "visibility": "private"
}
```

### Public

```json
{
  "repositories": [],
  "visibility": "public"
}
```

## Authentication Deep Dive

### How Authentication Works

The reusable workflow handles authentication in multiple ways to ensure reliability:

1. **CLI Configuration** - Uses `dotnet nuget add source` with credentials
2. **NuGet.Config File** - Creates a config file with embedded credentials
3. **Automatic Cleanup** - Removes conflicting sources before adding new ones
4. **Retry Logic** - Attempts restore up to 3 times (configurable) with exponential backoff

### Authentication Flow

```
1. Remove existing "github" source (if any)
2. Remove existing "nuget.org" source (if any)
3. Add nuget.org without auth
4. Add GitHub Packages with token auth
5. Create nuget.config with credentials
6. Restore packages (with retry)
7. On failure: Clear cache, retry with detailed logging
```

### Why This Approach?

? **Common Issues We Solve:**
- Token not properly passed to restore
- Cached authentication failures
- Conflicting source configurations
- Intermittent network issues
- Missing or incorrect nuget.config

? **Our Solutions:**
- Multiple authentication methods (CLI + config file)
- Automatic cleanup of conflicting sources
- Retry logic with cache clearing
- Detailed error diagnostics
- Backup and restore of original config

## Troubleshooting

### Authentication Failures

**Symptoms:**
- `401 Unauthorized` errors
- `Unable to load the service index` errors
- Package not found errors for packages that exist

**Solutions:**

1. **Check workflow logs** - Look for the "Configure NuGet Authentication" step
2. **Verify token permissions** - Ensure `packages: write` is set
3. **Check package visibility** - Internal packages require org membership
4. **Retry the workflow** - Transient network issues are common

### Restore Failures

**Symptoms:**
- `NU1102: Unable to find package` errors
- Timeout errors
- Connection refused errors

**Solutions:**

The workflow automatically retries with:
- Cache clearing between attempts
- Exponential backoff (2s, 4s, 8s)
- Detailed logging on failures

**Manual retry:**
```yaml
with:
  restore-retry-count: 5  # Increase retry attempts
```

### Custom Authentication Scenarios

**Using with Private NuGet Feeds:**

```yaml
jobs:
  ci:
    uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main
    with:
      additional-nuget-sources: '["https://pkgs.dev.azure.com/myorg/_packaging/myfeed/nuget/v3/index.json"]'
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      NUGET_API_KEY: ${{ secrets.AZURE_DEVOPS_PAT }}  # For Azure DevOps feeds
```

**Local Development Authentication:**

For local development, developers should use:

```bash
# One-time setup per machine
dotnet nuget add source https://nuget.pkg.github.com/EagleViewEnt/index.json \
  --name github \
  --username YOUR_GITHUB_USERNAME \
  --password YOUR_GITHUB_PAT \
  --store-password-in-clear-text
```

Or create a `nuget.config` in their user profile:
- Windows: `%APPDATA%\NuGet\NuGet.Config`
- Mac/Linux: `~/.nuget/NuGet/NuGet.Config`

## Versioning

The workflow supports version pinning:

```yaml
# Latest (main branch) - recommended for testing
uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main

# Specific version tag - recommended for production
uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@v1.0.0

# Specific commit - for debugging
uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@abc123
```

## Migration Guide

### From Local Workflow to Shared

**Before:**
```yaml
# .github/workflows/ci.yml (60+ lines)
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-dotnet@v4
      - name: Authenticate to GitHub Packages
        run: |
          # ... complex authentication logic ...
      - name: Restore
        run: dotnet restore
      # ... many more steps ...
```

**After:**
```yaml
# .github/workflows/ci.yml (12 lines)
name: CI
on: [push, pull_request]
permissions:
  contents: read
  packages: write
jobs:
  ci:
    uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main
    with:
      package-projects: '["src/MyProject/MyProject.csproj"]'
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Benefits
- ? **90% less code** in each repository
- ? **Centralized authentication** - Fix once, applies everywhere
- ? **Automatic updates** - Pull latest improvements
- ? **Consistent behavior** - All repos work the same way
- ? **Built-in retry logic** - Handles transient failures
- ? **Better error messages** - Detailed diagnostics

## Support

For issues or questions about the shared workflows:
- Check the [troubleshooting section](#troubleshooting)
- Review workflow run logs for detailed diagnostics
- Create an issue in the `.github` repository
- Contact the DevOps team

## Contributing

To improve the shared workflows:

1. Test changes in a feature branch
2. Update documentation
3. Version with semantic versioning
4. Announce breaking changes to all teams
