# Contributing to SCUM Server Setup Script

🎉 **Thank you for your interest in contributing to the SCUM Server Setup Script!**

We welcome contributions from the community and appreciate your help in making this tool better for everyone.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)
- [Testing](#testing)

## 📜 Code of Conduct

This project adheres to a code of conduct that we all pledge to follow. Please be respectful, inclusive, and professional in all interactions.

### Our Standards

- **Be respectful**: Treat everyone with respect and kindness
- **Be inclusive**: Welcome newcomers and help them learn
- **Be collaborative**: Work together towards common goals
- **Be professional**: Keep discussions focused and constructive

## 🤝 How Can I Contribute?

### 🐛 Reporting Bugs

Found a bug? Help us fix it!

**Before submitting a bug report:**
- Check if the issue already exists in our [Issues](../../issues) page
- Make sure you're using the latest version of the script
- Test with a clean Windows installation if possible

**When submitting a bug report, include:**
- **Clear title**: Describe the issue briefly
- **Detailed description**: What happened vs. what you expected
- **Steps to reproduce**: Exact steps to trigger the bug
- **Environment details**:
  - Windows version (Windows 10/11, build number)
  - PowerShell version (`$PSVersionTable.PSVersion`)
  - Script parameters used
- **Log files**: Attach `scum-server-setup.log` if available
- **Screenshots**: If the issue is visual

### 💡 Suggesting Enhancements

Have an idea to improve the script? We'd love to hear it!

**Before suggesting an enhancement:**
- Check if someone already suggested it in [Issues](../../issues)
- Consider if it fits the project's scope and goals

**When suggesting an enhancement:**
- **Clear title**: Summarize your suggestion
- **Detailed description**: Explain the feature and its benefits
- **Use cases**: Describe scenarios where this would be helpful
- **Implementation ideas**: If you have technical suggestions

### 🔧 Development Setup

#### Prerequisites

- **Windows 10 or 11**: For testing the script
- **PowerShell 5.1+**: Pre-installed on Windows 10/11
- **Git**: For version control
- **Code Editor**: VS Code recommended with PowerShell extension

#### Setting Up Development Environment

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/wickstudio/scum-server-setup.git
   cd scum-server-setup
   ```
3. **Create a new branch** for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

#### Running the Script Locally

```powershell
# Run PowerShell as Administrator
.\Setup-SCUMServer.ps1 -Port 7011 -QueryPort 27016
```

⚠️ **Warning**: The script will actually install software and modify your system. Consider using a virtual machine for development.

## 🔄 Pull Request Process

### Before Submitting

1. **Test thoroughly**: Ensure your changes work on both Windows 10 and 11
2. **Update documentation**: Modify README.md if needed
3. **Follow coding standards**: See [Style Guidelines](#style-guidelines)
4. **Check for conflicts**: Rebase on the latest main branch

### Submitting Your Pull Request

1. **Create descriptive title**: Summarize what your PR does
2. **Provide detailed description**:
   - What changes you made
   - Why you made them
   - How to test them
3. **Reference related issues**: Use "Fixes #123" or "Closes #123"
4. **Update CHANGELOG**: Add your changes to the unreleased section

### Pull Request Template

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Documentation update

## Testing
- [ ] Tested on Windows 10
- [ ] Tested on Windows 11
- [ ] Tested with custom parameters
- [ ] All existing functionality still works

## Related Issues
Fixes #(issue number)
```

## 📝 Style Guidelines

### PowerShell Coding Standards

#### General Principles
- **Write readable code**: Use clear variable and function names
- **Comment complex logic**: Explain why, not just what
- **Handle errors gracefully**: Use try-catch blocks appropriately
- **Be consistent**: Follow existing patterns in the codebase

#### Naming Conventions
- **Functions**: Use `Verb-Noun` format (e.g., `Install-VCRedist`)
- **Variables**: Use descriptive camelCase (e.g., `$steamCmdPath`)
- **Constants**: Use UPPER_CASE (e.g., `$LOG_FILE`)

#### Code Formatting
- **Indentation**: Use 4 spaces (no tabs)
- **Line length**: Keep lines under 120 characters when possible
- **Braces**: Opening brace on same line
- **Comments**: Use `#` for single-line, `<# #>` for multi-line

#### Example Function
```powershell
function Install-Dependency {
    <#
    .SYNOPSIS
        Installs a dependency with error handling.
    
    .PARAMETER Name
        Name of the dependency to install.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )
    
    try {
        Write-StatusMessage "Installing $Name..." "INFO"
        
        # Installation logic here
        
        Write-StatusMessage "$Name installed successfully." "SUCCESS"
        return $true
    }
    catch {
        Handle-Error "Failed to install $Name`: $($_.Exception.Message)"
        return $false
    }
}
```

### Documentation Standards

- **Use clear headings**: Organize content logically
- **Include examples**: Show how to use features
- **Keep it updated**: Modify docs when changing functionality
- **Use proper markdown**: Follow GitHub Flavored Markdown

## 🧪 Testing

### Manual Testing Checklist

Before submitting changes, test the following scenarios:

#### Basic Functionality
- [ ] Script runs with default parameters
- [ ] Script runs with custom parameters
- [ ] Administrator privilege check works
- [ ] User confirmation prompt works
- [ ] All installation steps complete successfully

#### Error Handling
- [ ] Script handles network failures gracefully
- [ ] Script handles file system errors
- [ ] Script handles installation failures
- [ ] Log file contains useful error information

#### Edge Cases
- [ ] Script works when dependencies already installed
- [ ] Script works when paths already exist
- [ ] Script handles special characters in paths
- [ ] Script works with Windows Defender enabled

### Testing Environment

For thorough testing, consider using:
- **Virtual machines**: Clean Windows 10/11 installations
- **Different configurations**: Various Windows builds and updates
- **Network conditions**: Test with slow/unstable connections

## 🚀 Release Process

### Version Numbering

We use [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG updated
- [ ] Version number bumped
- [ ] Release notes prepared

## 📞 Getting Help

If you need help with contributing:

1. **Check existing documentation**: README.md and this CONTRIBUTING.md
2. **Search issues**: Someone might have asked the same question
3. **Create an issue**: Use the "Question" template
4. **Join discussions**: Participate in issue discussions

## 🙏 Recognition

Contributors will be recognized in:
- **README.md acknowledgments**: All contributors listed
- **Release notes**: Significant contributions highlighted
- **GitHub contributors page**: Automatic recognition

---

**Thank you for contributing to the SCUM Server Setup Script!** 🎮

Every contribution, no matter how small, helps make this tool better for the entire SCUM community. 