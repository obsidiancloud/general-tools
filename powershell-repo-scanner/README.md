# GitHub Repository Artifactory Compliance Scanner

A PowerShell script that scans GitHub repositories for external package references that don't use your internal Artifactory configuration. Specifically identifies files containing "jfrog.io" references.

## 🎯 Purpose

This tool helps ensure that all repositories in your organization are using your internal Artifactory instance for package dependencies rather than external package repositories. It's particularly useful for:

- **Security Compliance**: Ensuring all dependencies come from trusted internal sources
- **Audit Requirements**: Documenting which repositories need remediation
- **Policy Enforcement**: Identifying non-compliant repositories quickly

## ✨ Features

- ✅ **Interactive Prompts**: User-friendly prompts for organization and repository names
- ✅ **Flexible Scanning**: Scan all repos in an org or target a specific repository
- ✅ **GitHub CLI Integration**: Uses official GitHub CLI for authenticated access
- ✅ **Comprehensive Logging**: Timestamped logs with severity levels
- ✅ **Tabular Output**: Clean, formatted results display
- ✅ **CSV Export**: Automatic export of findings for further analysis
- ✅ **Graceful Error Handling**: Robust error handling with detailed messages
- ✅ **Progress Indicators**: Visual feedback during long-running scans
- ✅ **Rate Limiting**: Built-in delays to respect GitHub API limits

## 📋 Prerequisites

### Required Software

1. **PowerShell 5.1+** (Windows) or **PowerShell Core 7+** (Cross-platform)
   ```powershell
   $PSVersionTable.PSVersion
   ```

2. **GitHub CLI (gh)**
   - Installation: https://cli.github.com/
   - Verify installation:
     ```bash
     gh --version
     ```

### Authentication

You must authenticate GitHub CLI with a Personal Access Token (PAT) that has access to the repositories you want to scan.

```bash
gh auth login
```

**Required PAT Scopes:**
- `repo` (Full control of private repositories)
- `read:org` (Read org and team membership)

## 🚀 Installation

1. Clone or download this repository to your local machine:
   ```bash
   cd /path/to/general-tools
   ```

2. Navigate to the scanner directory:
   ```bash
   cd powershell-repo-scanner
   ```

3. Ensure the script is executable (Linux/macOS):
   ```bash
   chmod +x Scan-RepoArtifactoryCompliance.ps1
   ```

## 📖 Usage

### Basic Usage (Interactive)

Simply run the script and follow the prompts:

```powershell
.\Scan-RepoArtifactoryCompliance.ps1
```

You'll be prompted for:
1. **Organization name** (required)
2. **Repository name** (optional - press Enter to scan all repos)

### Advanced Usage (Parameters)

#### Scan All Repositories in an Organization

```powershell
.\Scan-RepoArtifactoryCompliance.ps1 -Organization "obsidiancloud"
```

#### Scan a Specific Repository

```powershell
.\Scan-RepoArtifactoryCompliance.ps1 -Organization "obsidiancloud" -Repository "kandji-demo"
```

#### Get Help

```powershell
Get-Help .\Scan-RepoArtifactoryCompliance.ps1 -Full
```

## 📊 Output

### Console Output

The script provides real-time feedback with color-coded messages:

```
═══════════════════════════════════════════════════════════
  GitHub Repository Artifactory Compliance Scanner
═══════════════════════════════════════════════════════════

✓ GitHub CLI installed: gh version 2.40.0
✓ GitHub CLI authenticated successfully
✓ Found 15 repositories

Scanning repository: project-alpha
  No matches found in project-alpha
Scanning repository: project-beta
  ⚠ Found 2 file(s) with pattern 'jfrog.io'

─────────────────────────────────────────────────────────

Repository    FilePath
----------    --------
project-beta  package.json
project-beta  Dockerfile

═══════════════════════════════════════════════════════════
  Scan Summary
═══════════════════════════════════════════════════════════
  Repositories Scanned: 15
  Non-Compliant Files:  2
  Warnings:             1
  Errors:               0
  Log File:             logs/scan-20250103-093426.log
═══════════════════════════════════════════════════════════
```

### Log Files

All scan activity is logged to `logs/scan-YYYYMMDD-HHMMSS.log`:

```
[2025-01-03 09:34:26] [INFO] Starting compliance scan at 01/03/2025 09:34:26
[2025-01-03 09:34:26] [INFO] Log file: logs/scan-20250103-093426.log
[2025-01-03 09:34:27] [SUCCESS] ✓ GitHub CLI authenticated successfully
[2025-01-03 09:34:28] [INFO] Target organization: obsidiancloud
[2025-01-03 09:34:30] [SUCCESS] ✓ Found 15 repositories
[2025-01-03 09:34:35] [WARNING]   ⚠ Found 2 file(s) with pattern 'jfrog.io'
```

### CSV Export

When findings are detected, results are automatically exported to `logs/findings-YYYYMMDD-HHMMSS.csv`:

```csv
Repository,FilePath,URL
project-beta,package.json,https://github.com/obsidiancloud/project-beta/blob/main/package.json
project-beta,Dockerfile,https://github.com/obsidiancloud/project-beta/blob/main/Dockerfile
```

## 🔧 Configuration

### Customizing Search Pattern

To search for different patterns, modify the `$searchPattern` variable in the `Start-ComplianceScan` function:

```powershell
# Current pattern (line ~235)
$searchPattern = "jfrog.io"

# Example: Search for multiple patterns
$searchPattern = "jfrog.io OR maven.org OR npmjs.com"
```

### Adjusting Rate Limiting

To modify the delay between repository scans, change the sleep duration (line ~285):

```powershell
# Current: 500ms delay
Start-Sleep -Milliseconds 500

# Faster scanning (may hit rate limits)
Start-Sleep -Milliseconds 100

# Slower scanning (more conservative)
Start-Sleep -Milliseconds 1000
```

## 🛠️ Troubleshooting

### GitHub CLI Not Found

**Error**: `GitHub CLI not found`

**Solution**: Install GitHub CLI from https://cli.github.com/

### Authentication Failed

**Error**: `GitHub CLI not authenticated`

**Solution**: 
```bash
gh auth login
```
Follow the prompts to authenticate with your PAT.

### No Repositories Found

**Error**: `No repositories found for organization: <org-name>`

**Possible Causes**:
1. Organization name is misspelled
2. Your PAT doesn't have access to the organization
3. Organization has no repositories

**Solution**: Verify organization name and PAT permissions.

### Rate Limiting

**Error**: `API rate limit exceeded`

**Solution**: 
1. Increase the sleep delay between scans
2. Wait for rate limit to reset (check with `gh api rate_limit`)
3. Use a PAT with higher rate limits

### Permission Denied

**Error**: `Resource not accessible by personal access token`

**Solution**: Ensure your PAT has the required scopes:
- `repo` (Full control of private repositories)
- `read:org` (Read org and team membership)

## 📁 Directory Structure

```
powershell-repo-scanner/
├── Scan-RepoArtifactoryCompliance.ps1  # Main scanner script
├── README.md                            # This file
└── logs/                                # Auto-created on first run
    ├── scan-YYYYMMDD-HHMMSS.log        # Detailed scan logs
    └── findings-YYYYMMDD-HHMMSS.csv    # CSV export of findings
```

## 🔐 Security Considerations

1. **PAT Security**: Never commit your PAT to version control. Use `gh auth login` to store credentials securely.
2. **Log Files**: Log files may contain repository names and file paths. Treat them as sensitive.
3. **CSV Exports**: CSV files contain URLs to potentially sensitive code. Store securely.

## 🤝 Contributing

Suggestions and improvements are welcome! Common enhancement areas:

- Additional search patterns (Maven, NPM, PyPI, etc.)
- Support for GitHub Enterprise Server
- Parallel repository scanning
- Integration with CI/CD pipelines
- Slack/Teams notifications

## 📝 License

This tool is part of the ObsidianCloud general-tools repository. Refer to the repository's LICENSE file for details.

## 📞 Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review GitHub CLI documentation: https://cli.github.com/manual/
3. Contact your DevOps/Platform team

## 🔄 Version History

### v1.0.0 (2025-01-03)
- Initial release
- GitHub CLI integration
- Interactive prompts
- Comprehensive logging
- CSV export functionality
- Graceful error handling
- Progress indicators

---

**Made with ❤️ by ObsidianCloud Engineering**
