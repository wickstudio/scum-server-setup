# 🎮 SCUM Dedicated Server Setup Script

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://docs.microsoft.com/en-us/powershell/)
[![Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-blue.svg)](https://www.microsoft.com/windows/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Created by](https://img.shields.io/badge/Created%20by-Wick%20Studio-purple.svg)](https://github.com/wickstudio)
[![Discord](https://img.shields.io/badge/Discord-Join%20Us-7289da.svg)](https://discord.gg/wicks)

**✨ Professional one-click automation for SCUM dedicated server installation**

**Created by [Wick Studio](https://github.com/wickstudio)** | **Join our [Discord](https://discord.gg/wicks)**

This automated installation system completely sets up a SCUM dedicated server on Windows machines with **zero manual configuration required**! Simply double-click and let the magic happen.

## ✨ Features

- **🖱️ One-Click Installation** - Just double-click `clickme.bat` and you're done!
- **🔒 Smart Administrator Handling** - Automatically requests and manages admin privileges
- **🔥 Automated Firewall Configuration** - Opens required TCP and UDP ports seamlessly
- **📦 Dependency Management** - Installs Visual C++ Redistributable and DirectX automatically
- **⚡ SteamCMD Integration** - Downloads and configures SteamCMD for server installation
- **🎯 SCUM Server Installation** - Downloads and installs the latest SCUM dedicated server (10GB+)
- **🚀 Startup Script Generation** - Creates ready-to-use `start.bat` file with optimal settings
- **📊 Real-Time Progress** - Live download progress and detailed status updates
- **🛠️ Enterprise Error Handling** - Comprehensive error handling with detailed logging and recovery
- **⚙️ Customizable Configuration** - Support for custom ports and installation paths
- **🔄 Resume Capability** - Can resume interrupted downloads and installations
- **📋 Detailed Logging** - Creates comprehensive log files for troubleshooting

## 🔧 Requirements

- **Operating System**: Windows 10 or Windows 11 (x64)
- **PowerShell**: Version 5.1 or higher (pre-installed on Windows 10/11)
- **Internet Connection**: Stable broadband connection (downloads 10GB+ of data)
- **Administrator Privileges**: Automatically handled by `clickme.bat` 
- **Disk Space**: Minimum 15GB free space (SCUM server ~10GB + dependencies)
- **Time**: Allow 20-40 minutes for complete installation (depending on internet speed)
- **Antivirus**: May need temporary disabling during installation (optional)

### ⏱️ Installation Time Estimates

| Internet Speed | Estimated Time |
|----------------|----------------|
| 100+ Mbps | 15-25 minutes |
| 50-100 Mbps | 25-35 minutes |
| 25-50 Mbps | 35-45 minutes |
| < 25 Mbps | 45+ minutes |

> **💡 Note**: The script can resume interrupted downloads, so don't worry if your connection drops!

## 🚀 Quick Start

### Method 1: One-Click Installation (Recommended) 🖱️

**The easiest way - just double-click and go!**

1. **Download both files to the same folder**:
   ```powershell
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wickstudio/scum-server-setup/main/clickme.bat" -OutFile "clickme.bat"
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wickstudio/scum-server-setup/main/Setup-SCUMServer.ps1" -OutFile "Setup-SCUMServer.ps1"
   ```

2. **Simply double-click `clickme.bat`**:
   - The batch file automatically handles administrator privileges
   - Accept the UAC prompt when it appears
   - Sit back and watch the magic happen! ✨

> **💡 Pro Tip**: `clickme.bat` is a smart launcher that automatically elevates privileges, runs the PowerShell script as administrator, and provides detailed error handling. No manual "Run as administrator" needed!

### Method 2: Manual Administrator Launch

1. **Download both files**:
   ```powershell
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wickstudio/scum-server-setup/main/clickme.bat" -OutFile "clickme.bat"
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wickstudio/scum-server-setup/main/Setup-SCUMServer.ps1" -OutFile "Setup-SCUMServer.ps1"
   ```

2. **Run as Administrator manually**:
   - Right-click on `clickme.bat`
   - Select "Run as administrator"
   - Follow the on-screen prompts

### Method 3: Clone Repository

1. **Clone the repository**:
   ```bash
   git clone https://github.com/wickstudio/scum-server-setup.git
   cd scum-server-setup
   ```

2. **Run the launcher**:
   - Double-click `clickme.bat` or right-click → "Run as administrator"

### Method 4: PowerShell Direct (Advanced Users)

1. **Download the PowerShell script**:
   ```powershell
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/wickstudio/scum-server-setup/main/Setup-SCUMServer.ps1" -OutFile "Setup-SCUMServer.ps1"
   ```

2. **Run as Administrator**:
   - Right-click PowerShell → "Run as administrator"
   - Navigate to the download folder
   - Execute: `.\Setup-SCUMServer.ps1`

### Method 5: One-Line Remote Execution

```powershell
# Run PowerShell as Administrator, then execute:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/wickstudio/scum-server-setup/main/Setup-SCUMServer.ps1'))
```

## ⚙️ Configuration Options

The script supports several parameters for customization:

### Basic Usage
```powershell
.\Setup-SCUMServer.ps1
```

### Custom Configuration
```powershell
.\Setup-SCUMServer.ps1 -Port 7011 -QueryPort 27016 -InstallPath "D:\MyScumServer" -SteamCMDPath "D:\SteamCMD"
```

### Available Parameters

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `-Port` | `7010` | TCP port for SCUM server connections |
| `-QueryPort` | `27015` | UDP port for server queries |
| `-InstallPath` | `C:\scumserver` | Directory where SCUM server will be installed |
| `-SteamCMDPath` | `C:\steamcmd` | Directory where SteamCMD will be installed |

## 📁 Installation Overview

The script performs the following actions:

1. **Pre-flight Checks**
   - Verifies Administrator privileges
   - Shows installation summary
   - Requests user confirmation

2. **Firewall Configuration**
   - Opens TCP port (default: 7010) for server connections
   - Opens UDP port (default: 27015) for server queries
   - Creates Windows Firewall rules with descriptive names

3. **Dependencies Installation**
   - Downloads and installs Visual C++ Redistributable x64
   - Downloads and installs DirectX End-User Runtime

4. **SteamCMD Setup**
   - Downloads SteamCMD from official Steam servers
   - Extracts to specified directory
   - Prepares for server installation

5. **SCUM Server Installation**
   - Uses SteamCMD to download SCUM Dedicated Server (App ID: 3792580)
   - Validates installation files
   - Sets up directory structure

6. **Server Configuration**
   - Creates `start.bat` file with proper launch parameters
   - Configures server with specified ports
   - Provides post-installation instructions

## 🎮 Starting Your Server

After successful installation:

1. **Navigate to your server directory** (default: `C:\scumserver`)
2. **Run the startup script**: Double-click `start.bat`
3. **Server console will open** - wait for "Server ready" message
4. **Connect to your server** using the configured port

### Server Configuration

Configure your server by editing files in:
```
C:\scumserver\SCUM\Saved\Config\WindowsServer\
```

Key configuration files:
- `Engine.ini` - Engine settings
- `Game.ini` - Game-specific settings
- `ServerSettings.ini` - Server parameters

## 📦 What's Included

### File Structure
```
scum-server-setup/
├── clickme.bat              # 🚀 Smart launcher with auto-admin privileges
├── Setup-SCUMServer.ps1     # 💻 Main PowerShell installation script
└── README.md               # 📖 This documentation
```

### File Descriptions

| File | Purpose | Description |
|------|---------|-------------|
| `clickme.bat` | **Smart Launcher** | Handles administrator privileges, execution policy, and error handling. Just double-click to start! |
| `Setup-SCUMServer.ps1` | **Main Script** | Contains all the installation logic, dependency management, and server setup |
| `README.md` | **Documentation** | Complete usage guide and troubleshooting information |

> **🔥 Why use `clickme.bat`?** It automatically handles all the technical stuff like administrator privileges, PowerShell execution policies, and provides detailed error messages if anything goes wrong!

## 🔧 Troubleshooting

### Common Issues & Solutions

#### ❌ `clickme.bat` closes immediately after double-click
**Solution**: This usually means you need to accept the UAC prompt:
- Look for a UAC dialog asking for administrator permissions
- Click "Yes" to allow the script to run with elevated privileges
- If no UAC appears, try right-clicking `clickme.bat` → "Run as administrator"

#### ❌ "Cannot be loaded because running scripts is disabled"
**Solution**: `clickme.bat` handles this automatically, but if you're running PowerShell directly:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### ❌ "Access is denied" Error
**Solution**: 
- Use `clickme.bat` (it handles admin privileges automatically)
- OR manually right-click PowerShell → "Run as administrator"
- Ensure your user account has administrator rights

#### ❌ Firewall Ports Not Opening
**Solution**:
- The script should handle this automatically
- If it fails, manually open ports in Windows Firewall:
  - TCP port 7010 (or your custom port)
  - UDP port 27015 (or your custom query port)
- Check if Windows Firewall service is running

#### ❌ SteamCMD Download Fails
**Solutions**:
- Check your internet connection
- Temporarily disable antivirus/firewall during installation
- Run the script again (it will resume from where it left off)
- Try using a VPN if your ISP blocks certain downloads

#### ❌ Server Won't Start After Installation
**Solutions**:
- Check the log file: `scum-server-setup.log`
- Verify Visual C++ Redistributable is properly installed
- Ensure DirectX is correctly installed
- Check Windows Event Viewer for detailed error messages
- Restart your computer and try again

#### ❌ Installation Hangs or Freezes
**Solutions**:
- Wait longer (SCUM server is 10GB+ download)
- Check Task Manager for active download processes
- Restart the script - it can resume interrupted downloads
- Free up disk space (need at least 15GB free)

### 📋 Log Files & Debugging

The script creates detailed log files for troubleshooting:

| Log File | Location | Contains |
|----------|----------|-----------|
| `scum-server-setup.log` | Same folder as scripts | Installation progress, errors, timestamps |
| Windows Event Viewer | `eventvwr.msc` | System-level errors and warnings |

**Checking Logs**:
```powershell
# View the installation log
Get-Content "scum-server-setup.log" | Select-Object -Last 50

# Check Windows Event Viewer for errors
eventvwr.msc
```

### 🆘 Getting Help

If you're still having issues:

1. **Check the log file** (`scum-server-setup.log`) for specific error messages
2. **Run with verbose output** by opening PowerShell as admin and running the script directly
3. **Search existing issues** on our [GitHub Issues](https://github.com/wickstudio/scum-server-setup/issues) page
4. **Create a new issue** with:
   - Your Windows version
   - The complete error message
   - The log file contents
   - What step the installation failed on

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Reporting Issues
- Use the [Issues](https://github.com/wickstudio/scum-server-setup/issues) tab
- Provide detailed error messages and log files
- Include your Windows version and PowerShell version

### Submitting Changes
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow PowerShell best practices
- Add comments for complex logic
- Test on both Windows 10 and Windows 11
- Update documentation for new features

## 📋 Changelog

### v2.0.0 (Current Release) - Enhanced One-Click Installation
- 🚀 **NEW**: `clickme.bat` smart launcher with automatic admin privilege handling
- 🔧 **IMPROVED**: Enhanced error handling and recovery mechanisms  
- 📊 **IMPROVED**: Better progress tracking with real-time status updates
- 🛠️ **IMPROVED**: Resume capability for interrupted downloads
- 📋 **IMPROVED**: Comprehensive logging and debugging information
- ⚡ **IMPROVED**: Optimized PowerShell execution with better policy handling
- 🔒 **IMPROVED**: Enhanced security with proper privilege escalation

### v1.0.0 (Initial Release)
- ✅ Automated SCUM server installation
- ✅ Firewall configuration  
- ✅ Dependency management
- ✅ Progress tracking and error handling
- ✅ Customizable parameters
- ✅ Basic logging functionality

## 🔗 Useful Links

- [SCUM Official Website](https://scumgame.com/)
- [SCUM Steam Page](https://store.steampowered.com/app/513710/SCUM/)
- [SCUM Server Documentation](https://scum-support.gamepires.com/hc/en-us)
- [SteamCMD Documentation](https://developer.valvesoftware.com/wiki/SteamCMD)

## ⚠️ Disclaimer

This script is provided "as-is" without any warranties. Use at your own risk. Always backup your system before running automated installation scripts.

The script downloads software from official sources:
- Microsoft Visual C++ Redistributable
- Microsoft DirectX End-User Runtime  
- Valve SteamCMD
- SCUM Dedicated Server

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Gamepires](https://gamepires.com/) for creating SCUM
- [Valve Corporation](https://www.valvesoftware.com/) for SteamCMD
- The SCUM community for testing and feedback

---

<div align="center">

**🎮 Created with ❤️ by [Wick Studio](https://github.com/wickstudio)**

[![GitHub](https://img.shields.io/badge/GitHub-wickstudio-black?style=for-the-badge&logo=github)](https://github.com/wickstudio)
[![Discord](https://img.shields.io/badge/Discord-Join_Us-7289da?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/wicks)

*Professional automation tools for the gaming community*

**⭐ If this script helped you, give it a star! ⭐**

</div> 