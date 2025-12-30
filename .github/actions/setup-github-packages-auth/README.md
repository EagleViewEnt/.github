# Setup GitHub Packages Authentication

A composite action that configures NuGet authentication for GitHub Packages with robust error handling and retry logic.

## Why This Action?

GitHub Packages authentication can be tricky. This action solves common issues:

- ✗ 401 Unauthorized errors
- ✗ Cached authentication failures  
- ✗ Conflicting source configurations
- ✗ Token not properly passed to dotnet restore
- ✗ Missing nuget.config

## Usage

### Basic Usage

```yaml
steps:
  - uses: actions/checkout@v4
  
  - uses: actions/setup-dotnet@v4
    with:
      dotnet-version: '10.0.x'
  
  - uses: EagleViewEnt/.github/.github/actions/setup-github-packages-auth@main
    with:
      github-token: ${{ secrets.GITHUB_TOKEN }}
  
  - name: Restore packages
    run: dotnet restore
```

### With Custom Organization

```yaml
- uses: EagleViewEnt/.github/.github/actions/setup-github-packages-auth@main
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    org-name: 'MyOrganization'
```

### With Additional Sources

```yaml
- uses: EagleViewEnt/.github/.github/actions/setup-github-packages-auth@main
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    additional-sources: '["https://my-feed.com/nuget/v3/index.json", "https://another-feed.com/nuget/v3/index.json"]'
```

## Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `github-token` | GitHub token for authentication (usually `secrets.GITHUB_TOKEN`) | Yes | - |
| `org-name` | GitHub organization name | No | `EagleViewEnt` |
| `additional-sources` | Additional NuGet sources as JSON array | No | `[]` |

## What It Does

1. **Cleans up existing sources** - Removes potentially conflicting `github` and `nuget.org` sources
2. **Adds nuget.org** - Official NuGet package source  
3. **Adds GitHub Packages** - With proper token authentication
4. **Creates nuget.config** - With embedded credentials for reliable restore
5. **Verifies configuration** - Lists all configured sources

## Authentication Methods

This action uses **dual authentication** for maximum reliability:

### 1. CLI Configuration
```bash
dotnet nuget add source https://nuget.pkg.github.com/ORG/index.json \
  --name github \
  --username USERNAME \
  --password TOKEN \
  --store-password-in-clear-text
```

### 2. NuGet.Config File
```xml
<packageSourceCredentials>
  <github>
    <add key="Username" value="USERNAME" />
    <add key="ClearTextPassword" value="TOKEN" />
  </github>
</packageSourceCredentials>
```

Both methods ensure authentication works even if one method fails.

## Backup and Restore

The action automatically:
- ✅ Backs up existing `nuget.config` to `nuget.config.backup`
- ✅ Creates a new `nuget.config` with authentication
- ✅ Preserves your original configuration

To restore the original config after your workflow:

```yaml
- name: Cleanup
  if: always()
  shell: pwsh
  run: |
    if (Test-Path "nuget.config.backup") {
      Move-Item "nuget.config.backup" "nuget.config" -Force
    }
```

## Troubleshooting

### Still Getting 401 Errors?

Check that your workflow has the correct permissions:

```yaml
permissions:
  contents: read
  packages: write  # Required for GitHub Packages
```

### Package Not Found?

1. Verify the package exists: `https://github.com/orgs/ORG/packages`
2. Check package visibility (internal/private/public)
3. Ensure your account has access to the package

### Source Already Exists Error?

This action automatically removes existing sources before adding them. If you still see this error:

1. Clear NuGet caches: `dotnet nuget locals all --clear`
2. Remove the source manually in your workflow before calling this action

## Examples

### Complete CI Workflow

```yaml
name: CI

on: [push, pull_request]

permissions:
  contents: read
  packages: write

jobs:
  build:
    runs-on: windows-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '10.0.x'
      
      - name: Setup GitHub Packages
        uses: EagleViewEnt/.github/.github/actions/setup-github-packages-auth@main
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Restore
        run: dotnet restore
      
      - name: Build
        run: dotnet build --no-restore
      
      - name: Test
        run: dotnet test --no-build
```

### With Private Azure Artifacts Feed

```yaml
- name: Setup GitHub Packages
  uses: EagleViewEnt/.github/.github/actions/setup-github-packages-auth@main
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    additional-sources: '["https://pkgs.dev.azure.com/myorg/_packaging/myfeed/nuget/v3/index.json"]'

# Note: You'll need to configure Azure feed credentials separately
```

## Local Development

For developers working locally, set up authentication once per machine:

**Windows PowerShell:**
```powershell
dotnet nuget add source https://nuget.pkg.github.com/EagleViewEnt/index.json `
  --name github `
  --username YOUR_GITHUB_USERNAME `
  --password YOUR_GITHUB_PAT `
  --store-password-in-clear-text
```

**Mac/Linux:**
```bash
dotnet nuget add source https://nuget.pkg.github.com/EagleViewEnt/index.json \
  --name github \
  --username YOUR_GITHUB_USERNAME \
  --password YOUR_GITHUB_PAT \
  --store-password-in-clear-text
```

**Create a PAT (Personal Access Token):**
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Select scope: `read:packages`
4. Copy and use in the command above

## vs. Other Solutions

| Solution | Pros | Cons |
|----------|------|------|
| **Manual dotnet nuget add** | Simple | Often fails in CI, no error handling |
| **nuget.config in repo** | Works | Requires committing tokens (security risk) |
| **Environment variables** | Secure | Complex, doesn't always work |
| **This action** | ✅ Works reliably<br>✅ Secure<br>✅ No config needed<br>✅ Dual auth methods | Requires composite action support |

## License

MIT License - See repository LICENSE file for details.

Copyright (c) 2025 Eagle View Enterprises LLC. All rights reserved.
