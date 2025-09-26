## Workflow Overview

The GitHub Actions workflow (`.github/workflows/deploy.yml`) consists of three main jobs:

### 1. Build Job
- Runs on every push to main and pull requests
- Checks out code and sets up PowerShell environment
- Executes the build script with version management
- Validates the module manifest
- Creates NuGet package
- Uploads build artifacts

### 2. Test Job
- Depends on successful build
- Installs Pester testing framework
- Runs module tests and unit tests (if they exist)
- Publishes test results as GitHub checks

### 3. Deploy Job
- Only runs on pushes to main branch (not PRs)
- Depends on both build and test jobs passing
- Downloads build artifacts
- Deploys NuGet package to Azure DevOps Artifacts

## Build Script Features

The `build.ps1` script supports both CI/CD and local development:

### CI/CD Mode (Default)
```powershell
.\build.ps1 -BuildVersion "1.2.3"
```
- Updates module version in manifest
- Auto-populates `FunctionsToExport` from Public folder
- Prepares module for packaging

### Local Development Mode
```powershell
.\build.ps1 -Local [-IncrementVersion] [-Test]
```
- Creates isolated build directory
- Allows testing without modifying source
- Optional version increment for local testing
- Optional test execution

## Version Management

- Source manifest uses `<ModuleVersion>` placeholder
- Build script replaces placeholder with actual version
- CI/CD uses `0.3.${{ github.run_number }}` pattern
- Local builds can increment version for testing

## Function Export Management

- `FunctionsToExport` array in manifest starts empty with comment indicating auto-population
- Build script scans `Public/` folder for .ps1 files
- Automatically populates function names in manifest during build
- Eliminates need to manually maintain function export list


## Key Improvements Over Previous Setup

1. **Better error handling** with colored output and detailed logging
2. **Artifact management** with proper retention policies
3. **Test result publishing** with GitHub integration
4. **Environment-specific deployment** (only deploys from main branch)
5. **Updated Actions versions** (v4 instead of v2/v3)
6. **Improved NuGet handling** for Linux runners
7. **Manifest validation** during build process
8. **Function export automation** eliminating manual maintenance

## Local Testing

For local development and testing:

```powershell
# Test the build process locally
.\build.ps1 -Local -Test

# Import the locally built module
Import-Module .\build\SPSFreshService\SPSFreshService.psd1 -Force

# Verify functions are exported correctly
Get-Module SPSFreshService | Select-Object -ExpandProperty ExportedFunctions
```

This setup provides a robust, maintainable CI/CD pipeline that scales with the module's development needs.

---

## FreshService Knowledge Base GitHub Sync (Legacy)

For knowledge base synchronization functionality, see the SPSFreshService module documentation and the following functions:
- `Export-FsKnowledgeBase`
- `Import-FsKnowledgeBase` 
- `Sync-FsKnowledgeBase`
