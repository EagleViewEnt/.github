# Configure-PackageAccess.ps1
# Script to manually configure GitHub Packages access for specified repositories

param(
    [Parameter(Mandatory=$true)]
    [string]$Token,
    
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = ".github/package-access.json"
)

Write-Host "=== GitHub Packages Access Configuration ===" -ForegroundColor Cyan
Write-Host ""

# Read configuration
if (-not (Test-Path $ConfigFile)) {
    Write-Host "Error: Configuration file not found: $ConfigFile" -ForegroundColor Red
    exit 1
}

$config = Get-Content -Path $ConfigFile | ConvertFrom-Json
$repositories = $config.repositories
$visibility = $config.visibility

# Package names
$packages = @(
    "EagleViewEnt.Utilities.Blazor.JSInterop",
    "EagleViewEnt.Utilities.Blazor.RazorComponents"
)

$org = "EagleViewEnt"
$headers = @{
    "Authorization" = "Bearer $Token"
    "Accept" = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

Write-Host "Organization: $org" -ForegroundColor Yellow
Write-Host "Packages: $($packages -join ', ')" -ForegroundColor Yellow
Write-Host "Visibility: $visibility" -ForegroundColor Yellow
Write-Host "Repositories: $($repositories -join ', ')" -ForegroundColor Yellow
Write-Host ""

$successCount = 0
$failureCount = 0

foreach ($package in $packages) {
    Write-Host "Processing package: $package" -ForegroundColor Cyan
    
    # Check if package exists
    try {
        $packageInfo = Invoke-RestMethod -Uri "https://api.github.com/orgs/$org/packages/nuget/$package" -Headers $headers -Method Get -ErrorAction Stop
        Write-Host "  ? Package found (ID: $($packageInfo.id))" -ForegroundColor Green
    } catch {
        Write-Host "  ? Package not found: $_" -ForegroundColor Red
        $failureCount++
        continue
    }
    
    # Set package visibility
    Write-Host "  Setting visibility to: $visibility" -ForegroundColor Gray
    try {
        $body = @{
            "visibility" = $visibility
        } | ConvertTo-Json
        
        Invoke-RestMethod -Uri "https://api.github.com/orgs/$org/packages/nuget/$package" `
            -Headers $headers `
            -Method Patch `
            -Body $body `
            -ContentType "application/json" `
            -ErrorAction Stop | Out-Null
        
        Write-Host "  ? Visibility updated" -ForegroundColor Green
    } catch {
        Write-Host "  ? Failed to set visibility: $_" -ForegroundColor Red
    }
    
    # Configure repository access
    foreach ($repo in $repositories) {
        Write-Host "  Configuring access for: $repo" -ForegroundColor Gray
        
        try {
            # Get repository ID
            $repoInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo" -Headers $headers -Method Get -ErrorAction Stop
            $repoId = $repoInfo.id
            
            # Grant access
            Invoke-RestMethod -Uri "https://api.github.com/orgs/$org/packages/nuget/$package/repositories/$repoId" `
                -Headers $headers `
                -Method Put `
                -ErrorAction Stop | Out-Null
            
            Write-Host "    ? Access granted" -ForegroundColor Green
            $successCount++
        } catch {
            Write-Host "    ? Failed: $_" -ForegroundColor Red
            $failureCount++
        }
    }
    
    Write-Host ""
}

Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Successful operations: $successCount" -ForegroundColor Green
Write-Host "Failed operations: $failureCount" -ForegroundColor Red

if ($failureCount -eq 0) {
    Write-Host "`nAll operations completed successfully!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nSome operations failed. Please review the output above." -ForegroundColor Yellow
    exit 1
}
