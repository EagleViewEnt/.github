# Package Access Configuration

This document explains how to configure automatic repository access for NuGet packages published from this repository.

## Overview

When packages are published to GitHub Packages, the CI workflow automatically configures which repositories have access to consume them. This ensures that your packages are available to the right projects without manual configuration.

## Configuration

### Package Access File

Edit `.github/package-access.json` to specify which repositories should have access:

```json
{
  "repositories": [
    "EagleViewEnt/MyApp1",
    "EagleViewEnt/MyApp2",
    "EagleViewEnt/AnotherProject"
  ],
  "visibility": "private"
}
```

### Fields

- **repositories**: Array of repository names in `owner/repo` format that should have access to the packages
- **visibility**: Package visibility setting
  - `"private"` - Only accessible to specified repositories and organization members
  - `"public"` - Publicly accessible to everyone

## How It Works

1. When code is pushed to the `main` branch, the CI workflow:
   - Builds and tests the code
   - Creates NuGet packages
   - Publishes packages to GitHub Packages
   - Automatically configures repository access based on `.github/package-access.json`

2. The following packages are configured:
   - `EagleViewEnt.Utilities.Blazor.JSInterop`
   - `EagleViewEnt.Utilities.Blazor.RazorComponents`

## Adding a New Repository

1. Edit `.github/package-access.json`
2. Add the repository name to the `repositories` array:
   ```json
   {
     "repositories": [
       "EagleViewEnt/ExistingRepo1",
       "EagleViewEnt/NewRepository"  // <-- Add here
     ],
     "visibility": "private"
   }
   ```
3. Commit and push to `main` branch
4. The next CI run will automatically grant access to the new repository

## Removing Repository Access

1. Edit `.github/package-access.json`
2. Remove the repository from the `repositories` array
3. Commit and push to `main`

**Note**: Removing from the config file does NOT revoke existing access automatically. You need to manually revoke access through:
- GitHub UI: Organization ? Packages ? Package Settings ? Manage Access
- Or use the GitHub API to remove access

## Manual Configuration

### Using the PowerShell Script

For manual configuration or troubleshooting, use the provided script:

```powershell
# Navigate to repository root
cd path/to/Blazor

# Run the script with your GitHub token
.\scripts\Configure-PackageAccess.ps1 -Token "ghp_your_token_here"

# Or specify a custom config file
.\scripts\Configure-PackageAccess.ps1 -Token "ghp_your_token_here" -ConfigFile "custom-config.json"
```

**Token Requirements:**
- Personal Access Token (classic) with scopes: `write:packages`, `read:org`, `repo`
- Or Fine-grained token with permissions: `Packages: Read and Write`, `Contents: Read`

### Using GitHub UI

If you need to manually configure package access through the web interface:

1. Go to your organization on GitHub
2. Navigate to "Packages"
3. Select the package
4. Go to "Package settings"
5. Under "Manage Access", add or remove repositories

## Permissions Required

The workflow uses `GITHUB_TOKEN` which has the following permissions:
- `packages: write` - To publish and configure packages
- `contents: read` - To read the repository

These permissions are configured in `.github/workflows/ci.yml`.

## Troubleshooting

### Package not found error
If you see "Package not found or not yet available" in the logs:
- This is normal for first-time package publication
- The access configuration will be applied on subsequent pushes
- You can manually configure access for the first run using the script

### Access grant failed
If access grant fails:
- Verify the repository name format is correct (`owner/repo`)
- Ensure the repository exists and is accessible
- Check that the workflow has sufficient permissions
- Try running the manual script with a PAT to see more detailed error messages

### Token permissions
If you get permission errors:
- Ensure the workflow has `packages: write` permission
- For organization packages, ensure the organization allows workflow access
- Check that your PAT (if using manual script) has the required scopes

### Script execution errors

**PowerShell execution policy:**
```powershell
# If you get execution policy errors
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**API rate limiting:**
- GitHub API has rate limits (5,000 requests/hour for authenticated requests)
- If you hit rate limits, wait an hour or use a different token

## Alternative: Using PAT (Personal Access Token)

For more complex scenarios or if `GITHUB_TOKEN` doesn't have sufficient permissions, you can use a Personal Access Token:

### Creating a PAT

1. Go to GitHub Settings ? Developer Settings ? Personal Access Tokens ? Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a descriptive name (e.g., "Package Access Configuration")
4. Select scopes:
   - `write:packages` - Upload and manage packages
   - `read:org` - Read organization data
   - `repo` - Access repository information
5. Generate and copy the token

### Using PAT in Workflow

1. Add the PAT as a repository secret:
   - Go to repository Settings ? Secrets and variables ? Actions
   - Add new secret named `PACKAGES_TOKEN`
   - Paste your PAT as the value

2. Update `.github/workflows/ci.yml`:
   ```yaml
   - name: Configure package access
     env:
       GITHUB_TOKEN: ${{ secrets.PACKAGES_TOKEN }}  # Use PAT instead
   ```

## Example Configurations

### Public Packages
```json
{
  "repositories": [],
  "visibility": "public"
}
```

### Selective Private Access
```json
{
  "repositories": [
    "EagleViewEnt/ProductionApp",
    "EagleViewEnt/StagingApp",
    "EagleViewEnt/DevelopmentApp"
  ],
  "visibility": "private"
}
```

### Organization-wide Private Access
```json
{
  "repositories": [
    "EagleViewEnt/App1",
    "EagleViewEnt/App2",
    "EagleViewEnt/App3",
    "EagleViewEnt/Lib1",
    "EagleViewEnt/Lib2"
  ],
  "visibility": "private"
}
```

## Security Considerations

1. **Token Security**: Never commit tokens to the repository. Always use secrets.
2. **Minimal Permissions**: Use the minimum required permissions for tokens.
3. **Regular Rotation**: Rotate PATs regularly if you use them.
4. **Audit Access**: Regularly review which repositories have access to packages.
5. **Private by Default**: Keep packages private unless they need to be public.

## Related Links

- [GitHub Packages Documentation](https://docs.github.com/en/packages)
- [GitHub API - Packages](https://docs.github.com/en/rest/packages)
- [Managing access to packages](https://docs.github.com/en/packages/learn-github-packages/configuring-a-packages-access-control-and-visibility)
