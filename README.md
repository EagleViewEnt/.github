# :rocket: EagleViewEnt Organization Workflows

This repository contains shared workflows, actions, and templates used across all EagleViewEnt repositories.

## :dart: Purpose

- **Centralize CI/CD workflows** - Update once, apply everywhere
- **Standardize processes** - Consistent behavior across all repos
- **Simplify maintenance** - Single source of truth
- **Enable workflow templates** - Starter workflows in Actions tab

## :file_folder: Repository Structure

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

## :rocket: Quick Start

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

## :gear: Available Workflows

### reusable-dotnet-ci.yml

Complete CI/CD pipeline for .NET projects:

**Features:**
- :white_check_mark: Build and test
- :white_check_mark: Code coverage collection
- :white_check_mark: NuGet package creation
- :white_check_mark: GitHub Packages publishing
- :white_check_mark: Automatic authentication
- :white_check_mark: Conditional packaging

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

## :lock: Authentication

The reusable workflows automatically handle GitHub Packages authentication. No additional setup required!

The workflow:
1. :white_check_mark: Removes conflicting NuGet sources
2. :white_check_mark: Adds nuget.org
3. :white_check_mark: Adds GitHub Packages with authentication
4. :white_check_mark: Uses `GITHUB_TOKEN` (automatically available)

## :package: Package Publishing

### Internal Visibility (Recommended)

Packages are automatically set to **internal visibility**, making them available to all repositories in the EagleViewEnt organization.

### Conditional Publishing

The workflow only publishes packages when:
- :white_check_mark: `publish-packages: true` is set
- :white_check_mark: Push is to `main` branch
- :white_check_mark: Not a pull request

This means the same workflow works for both libraries and applications!

## :book: Documentation

Comprehensive guides are available:

- **[Shared Workflows Guide](docs/SHARED_WORKFLOWS.md)** - Complete usage examples
- **[Centralized CI/CD](docs/CENTRALIZED_CICD.md)** - Overview and architecture
- **[Workflow Configuration](docs/WORKFLOW_CONFIG.md)** - All configuration options
- **[Package Access](docs/PACKAGE_ACCESS.md)** - Managing package visibility
- **[Migration Guide](docs/MIGRATION_GUIDE.md)** - Migrating existing repos

## :art: Workflow Templates

Starter workflows appear automatically in the Actions tab when creating new workflows:

1. Go to repository :arrow_right: Actions :arrow_right: New workflow
2. See "EagleViewEnt workflows" section
3. Choose ".NET CI Workflow"
4. Customize for your project

## :arrows_counterclockwise: Updating Workflows

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

## :bar_chart: What Gets Built

When a workflow runs:

1. **On Pull Requests:**
   - :white_check_mark: Build
   - :white_check_mark: Test
   - :white_check_mark: Code coverage
   - :no_entry_sign: Skip packaging/publishing

2. **On Main Branch Push:**
   - :white_check_mark: Build
   - :white_check_mark: Test
   - :white_check_mark: Code coverage
   - :white_check_mark: Pack (if `publish-packages: true`)
   - :white_check_mark: Publish (if `publish-packages: true`)

## :hammer_and_wrench: Examples

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

## :handshake: Contributing

To improve the shared workflows:

1. Create a branch in this repository
2. Make your changes
3. Test in a feature branch of a consuming repository
4. Create pull request
5. Document breaking changes
6. Tag releases with semantic versioning

## :telephone_receiver: Support

For workflow issues:
1. Check the [documentation](docs/)
2. Review [troubleshooting guide](docs/SHARED_WORKFLOWS.md#troubleshooting)
3. Check workflow run logs
4. Contact DevOps team

## :tada: Benefits

Using these shared workflows provides:

- :white_check_mark: **90% less code** per repository
- :white_check_mark: **Consistent behavior** across all projects
- :white_check_mark: **Automatic updates** when workflows improve
- :white_check_mark: **Built-in authentication** for GitHub Packages
- :white_check_mark: **Conditional packaging** - one workflow for all repo types
- :white_check_mark: **Battle-tested** - proven in production

## :memo: License

Copyright (c) 2025 Eagle View Enterprises LLC. All rights reserved.

---

**Last Updated:** December 30, 2025  
**Maintained By:** EagleViewEnt DevOps Team
