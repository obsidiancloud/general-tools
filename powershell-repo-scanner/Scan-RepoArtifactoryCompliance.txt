<#
.SYNOPSIS
    Scans GitHub repositories for external package references that don't use internal Artifactory.

.DESCRIPTION
    This script uses the GitHub CLI to scan repositories for references to external package
    repositories (specifically looking for "jfrog.io" references that indicate non-Artifactory usage).
    Results are displayed in a table and logged to a file.

.PARAMETER Organization
    The GitHub organization name to scan. If not provided, will prompt.

.PARAMETER Repository
    Optional specific repository name to scan. If not provided, scans all accessible repos.

.EXAMPLE
    .\Scan-RepoArtifactoryCompliance.ps1
    
.EXAMPLE
    .\Scan-RepoArtifactoryCompliance.ps1 -Organization "myorg" -Repository "myrepo"

.NOTES
    Requires: GitHub CLI (gh) to be installed and authenticated with a PAT
    Author: ObsidianCloud
    Version: 1.0.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Organization,
    
    [Parameter(Mandatory = $false)]
    [string]$Repository
)

# Script configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Initialize script directory and logging
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogDir = Join-Path $ScriptDir "logs"
$LogFile = Join-Path $LogDir "scan-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Ensure logs directory exists
if (-not (Test-Path $LogDir)) {
    try {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        Write-Host "✓ Created logs directory: $LogDir" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to create logs directory: $_"
        exit 1
    }
}

# Initialize results collection
$script:Results = @()
$script:ErrorCount = 0
$script:WarningCount = 0

#region Logging Functions

function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    # Write to log file
    try {
        Add-Content -Path $LogFile -Value $LogMessage -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to write to log file: $_"
    }
    
    # Write to console with color
    switch ($Level) {
        "ERROR" { 
            Write-Host $Message -ForegroundColor Red
            $script:ErrorCount++
        }
        "WARNING" { 
            Write-Host $Message -ForegroundColor Yellow
            $script:WarningCount++
        }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        default { Write-Host $Message -ForegroundColor White }
    }
}

#endregion

#region GitHub CLI Functions

function Test-GitHubCLI {
    <#
    .SYNOPSIS
        Verifies GitHub CLI is installed and authenticated
    #>
    try {
        Write-Log "Checking GitHub CLI installation..." -Level INFO
        
        $ghVersion = gh --version 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "GitHub CLI not found"
        }
        
        Write-Log "✓ GitHub CLI installed: $($ghVersion[0])" -Level SUCCESS
        
        # Check authentication
        Write-Log "Verifying GitHub CLI authentication..." -Level INFO
        $authStatus = gh auth status 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            throw "GitHub CLI not authenticated. Please run: gh auth login"
        }
        
        Write-Log "✓ GitHub CLI authenticated successfully" -Level SUCCESS
        return $true
    }
    catch {
        Write-Log "GitHub CLI check failed: $_" -Level ERROR
        Write-Log "Please install GitHub CLI from: https://cli.github.com/" -Level ERROR
        return $false
    }
}

function Get-OrganizationRepos {
    <#
    .SYNOPSIS
        Retrieves all repositories for the specified organization
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgName
    )
    
    try {
        Write-Log "Fetching repositories for organization: $OrgName" -Level INFO
        
        $repos = gh repo list $OrgName --limit 1000 --json name,url,isPrivate,updatedAt 2>&1 | ConvertFrom-Json
        
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to fetch repositories: $repos"
        }
        
        if ($repos.Count -eq 0) {
            Write-Log "No repositories found for organization: $OrgName" -Level WARNING
            return @()
        }
        
        Write-Log "✓ Found $($repos.Count) repositories" -Level SUCCESS
        return $repos
    }
    catch {
        Write-Log "Failed to fetch repositories: $_" -Level ERROR
        return @()
    }
}

function Search-RepoForPattern {
    <#
    .SYNOPSIS
        Searches a repository for the specified pattern using GitHub CLI
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$OrgName,
        
        [Parameter(Mandatory = $true)]
        [string]$RepoName,
        
        [Parameter(Mandatory = $true)]
        [string]$SearchPattern
    )
    
    try {
        Write-Log "Scanning repository: $RepoName" -Level INFO
        
        # Use GitHub CLI to search code in the repository
        $searchQuery = "$SearchPattern repo:$OrgName/$RepoName"
        $searchResults = gh search code $searchQuery --json repository,path,textMatches --limit 100 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            # Check if it's a "no results" error vs actual error
            if ($searchResults -match "no results matched your search") {
                Write-Log "  No matches found in $RepoName" -Level INFO
                return @()
            }
            else {
                throw "Search failed: $searchResults"
            }
        }
        
        $results = $searchResults | ConvertFrom-Json
        
        if ($results.Count -eq 0) {
            Write-Log "  No matches found in $RepoName" -Level INFO
            return @()
        }
        
        Write-Log "  ⚠ Found $($results.Count) file(s) with pattern '$SearchPattern'" -Level WARNING
        
        # Process results
        $findings = @()
        foreach ($result in $results) {
            $findings += [PSCustomObject]@{
                Repository = $RepoName
                FilePath   = $result.path
                URL        = "https://github.com/$OrgName/$RepoName/blob/main/$($result.path)"
            }
        }
        
        return $findings
    }
    catch {
        Write-Log "  Error scanning $RepoName : $_" -Level ERROR
        return @()
    }
}

#endregion

#region Main Script Logic

function Start-ComplianceScan {
    <#
    .SYNOPSIS
        Main function to orchestrate the compliance scan
    #>
    
    Write-Host "`n" -NoNewline
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  GitHub Repository Artifactory Compliance Scanner" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Log "Starting compliance scan at $(Get-Date)" -Level INFO
    Write-Log "Log file: $LogFile" -Level INFO
    
    # Verify GitHub CLI
    if (-not (Test-GitHubCLI)) {
        exit 1
    }
    
    # Get organization name
    if (-not $script:Organization) {
        Write-Host ""
        $script:Organization = Read-Host "Enter GitHub organization name"
        
        if ([string]::IsNullOrWhiteSpace($script:Organization)) {
            Write-Log "Organization name is required" -Level ERROR
            exit 1
        }
    }
    
    Write-Log "Target organization: $($script:Organization)" -Level INFO
    
    # Get repository name (optional)
    if (-not $script:Repository) {
        Write-Host ""
        $repoInput = Read-Host "Enter specific repository name (or press Enter to scan all repos)"
        
        if (-not [string]::IsNullOrWhiteSpace($repoInput)) {
            $script:Repository = $repoInput
        }
    }
    
    # Define search pattern
    $searchPattern = "jfrog.io"
    Write-Log "Search pattern: $searchPattern" -Level INFO
    
    Write-Host ""
    Write-Host "─────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host ""
    
    # Determine repositories to scan
    $reposToScan = @()
    
    if ($script:Repository) {
        Write-Log "Scanning specific repository: $($script:Repository)" -Level INFO
        $reposToScan = @([PSCustomObject]@{ name = $script:Repository })
    }
    else {
        $reposToScan = Get-OrganizationRepos -OrgName $script:Organization
        
        if ($reposToScan.Count -eq 0) {
            Write-Log "No repositories to scan. Exiting." -Level ERROR
            exit 1
        }
    }
    
    # Scan repositories
    $totalRepos = $reposToScan.Count
    $currentRepo = 0
    
    foreach ($repo in $reposToScan) {
        $currentRepo++
        $repoName = $repo.name
        
        Write-Progress -Activity "Scanning Repositories" `
            -Status "Processing $repoName ($currentRepo of $totalRepos)" `
            -PercentComplete (($currentRepo / $totalRepos) * 100)
        
        $findings = Search-RepoForPattern -OrgName $script:Organization `
            -RepoName $repoName `
            -SearchPattern $searchPattern
        
        if ($findings.Count -gt 0) {
            $script:Results += $findings
        }
        
        # Rate limiting - be nice to GitHub API
        Start-Sleep -Milliseconds 500
    }
    
    Write-Progress -Activity "Scanning Repositories" -Completed
    
    # Display results
    Write-Host ""
    Write-Host "─────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host ""
    
    if ($script:Results.Count -eq 0) {
        Write-Log "✓ No non-compliant references found! All repositories are using Artifactory." -Level SUCCESS
    }
    else {
        Write-Log "⚠ Found $($script:Results.Count) file(s) with external references" -Level WARNING
        Write-Host ""
        
        # Display table
        $script:Results | Format-Table -Property Repository, FilePath -AutoSize
        
        # Log detailed results
        Write-Log "Detailed findings:" -Level INFO
        foreach ($result in $script:Results) {
            Write-Log "  - Repository: $($result.Repository)" -Level INFO
            Write-Log "    File: $($result.FilePath)" -Level INFO
            Write-Log "    URL: $($result.URL)" -Level INFO
        }
    }
    
    # Summary
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Scan Summary" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  Repositories Scanned: $totalRepos" -ForegroundColor White
    Write-Host "  Non-Compliant Files:  $($script:Results.Count)" -ForegroundColor $(if ($script:Results.Count -eq 0) { "Green" } else { "Yellow" })
    Write-Host "  Warnings:             $script:WarningCount" -ForegroundColor Yellow
    Write-Host "  Errors:               $script:ErrorCount" -ForegroundColor Red
    Write-Host "  Log File:             $LogFile" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Log "Scan completed at $(Get-Date)" -Level INFO
    Write-Log "Total findings: $($script:Results.Count)" -Level INFO
    
    # Export results to CSV if findings exist
    if ($script:Results.Count -gt 0) {
        $csvFile = Join-Path $LogDir "findings-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
        try {
            $script:Results | Export-Csv -Path $csvFile -NoTypeInformation -ErrorAction Stop
            Write-Log "Results exported to: $csvFile" -Level SUCCESS
        }
        catch {
            Write-Log "Failed to export CSV: $_" -Level ERROR
        }
    }
}

#endregion

# Execute main script
try {
    Start-ComplianceScan
}
catch {
    Write-Log "Unexpected error: $_" -Level ERROR
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level ERROR
    exit 1
}
