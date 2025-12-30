# EagleViewEnt Organization Workflows

This repository contains shared workflows, actions, and templates used across all EagleViewEnt repositories.

## ?? Purpose

- **Centralize CI/CD workflows** - Update once, apply everywhere
- **Standardize processes** - Consistent behavior across all repos
- **Simplify maintenance** - Single source of truth
- **Enable workflow templates** - Starter workflows in Actions tab

## ?? Repository Structure

```
.github/
??? workflows/
?   ??? reusable-dotnet-ci.yml      # Main reusable .NET CI/CD workflow
??? actions/
?   ??? setup-github-packages-auth/ # GitHub Packages authentication
?       ??? action.yml
?       ??? README.md
workflow-templates/
??? dotnet-ci.yml                    # .NET CI starter template
??? dotnet-ci.properties.json        # Template metadata
docs/
??? SHARED_WORKFLOWS.md              # Complete usage guide
??? CENTRALIZED_CICD.md              # Overview and benefits
??? WORKFLOW_CONFIG.md               # Configuration reference
??? PACKAGE_ACCESS.md                # Package visibility management
??? MIGRATION_GUIDE.md               # Migration instructions
scripts/
??? Configure-PackageAccess.ps1      # Manual package access config
```

## ?? Quick Start

### For .NET Libraries (with NuGet Packages)

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
      publish-packages: true
      package-projects: '["src/MyLib/MyLib.csproj"]'
      org-name: 'EagleViewEnt'
```

### For .NET Applications (no packages)

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
      publish-packages: false
      org-name: 'EagleViewEnt'
```

## ?? Available Workflows

### reusable-dotnet-ci.yml

Complete CI/CD pipeline for .NET projects:

**Features:**
- ? Build and test
- ? Code coverage collection
- ? NuGet package creation
- ? GitHub Packages publishing
- ? Automatic authentication
- ? Conditional packaging

**Inputs:**

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `dotnet-version` | string | `10.0.x` | .NET SDK version |
| `build-configuration` | string | `Release` | Build configuration |
| `run-tests` | boolean | `true` | Run unit tests |
| `enable-code-coverage` | boolean | `true` | Collect code coverage |
| `publish-packages` | boolean | `true` | Publish NuGet packages |
| `package-projects` | string | `[]` | Projects to pack (JSON array) |
| `org-name` | string | `EagleViewEnt` | GitHub organization |

## ?? Authentication

The reusable workflows automatically handle GitHub Packages authentication. No additional setup required!

The workflow:
1. ? Removes conflicting NuGet sources
2. ? Adds nuget.org
3. ? Adds GitHub Packages with authentication
4. ? Uses `GITHUB_TOKEN` (automatically available)

## ?? Package Publishing

### Internal Visibility (Recommended)

Packages are automatically set to **internal visibility**, making them available to all repositories in the EagleViewEnt organization.

### Conditional Publishing

The workflow only publishes packages when:
- ? `publish-packages: true` is set
- ? Push is to `main` branch
- ? Not a pull request

This means the same workflow works for both libraries and applications!

## ?? Documentation

Comprehensive guides are available:

- **[Shared Workflows Guide](docs/SHARED_WORKFLOWS.md)** - Complete usage examples
- **[Centralized CI/CD](docs/CENTRALIZED_CICD.md)** - Overview and architecture
- **[Workflow Configuration](docs/WORKFLOW_CONFIG.md)** - All configuration options
- **[Package Access](docs/PACKAGE_ACCESS.md)** - Managing package visibility
- **[Migration Guide](docs/MIGRATION_GUIDE.md)** - Migrating existing repos

## ?? Workflow Templates

Starter workflows appear automatically in the Actions tab when creating new workflows:

1. Go to repository ? Actions ? New workflow
2. See "EagleViewEnt workflows" section
3. Choose ".NET CI Workflow"
4. Customize for your project

## ?? Updating Workflows

### Using Latest Version (Recommended)

```yaml
uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main
```

Always uses the latest version. Updates apply automatically.

### Pinning to Specific Version

```yaml
uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@v1.0.0
```

Use when you need stability and want to control updates.

### Using Specific Commit

```yaml
uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@abc123
```

For testing or troubleshooting specific versions.

## ?? What Gets Built

When a workflow runs:

1. **On Pull Requests:**
   - ? Build
   - ? Test
   - ? Code coverage
   - ?? Skip packaging/publishing

2. **On Main Branch Push:**
   - ? Build
   - ? Test
   - ? Code coverage
   - ? Pack (if `publish-packages: true`)
   - ? Publish (if `publish-packages: true`)

## ??? Examples

### Single Library Project

```yaml
jobs:
  ci:
    uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main
    with:
      package-projects: '["src/MyLibrary/MyLibrary.csproj"]'
```

### Multiple Projects

```yaml
jobs:
  ci:
    uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main
    with:
      package-projects: '["src/Core/Core.csproj", "src/Extensions/Extensions.csproj"]'
```

### .NET 9 Project

```yaml
jobs:
  ci:
    uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main
    with:
      dotnet-version: '9.0.x'
      package-projects: '["src/MyProject/MyProject.csproj"]'
```

### Debug Build (Development)

```yaml
jobs:
  ci:
    uses: EagleViewEnt/.github/.github/workflows/reusable-dotnet-ci.yml@main
    with:
      build-configuration: 'Debug'
      publish-packages: false
```

## ?? Contributing

To improve the shared workflows:

1. Create a branch in this repository
2. Make your changes
3. Test in a feature branch of a consuming repository
4. Create pull request
5. Document breaking changes
6. Tag releases with semantic versioning

## ?? Support

For workflow issues:
1. Check the [documentation](docs/)
2. Review [troubleshooting guide](docs/SHARED_WORKFLOWS.md#troubleshooting)
3. Check workflow run logs
4. Contact DevOps team

## ?? Benefits

Using these shared workflows provides:

- ? **90% less code** per repository
- ? **Consistent behavior** across all projects
- ? **Automatic updates** when workflows improve
- ? **Built-in authentication** for GitHub Packages
- ? **Conditional packaging** - one workflow for all repo types
- ? **Battle-tested** - proven in production

## ?? License

Copyright (c) 2025 Eagle View Enterprises LLC. All rights reserved.

---

**Last Updated:** December 30, 2025  
**Maintained By:** EagleViewEnt DevOps Team
