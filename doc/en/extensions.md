# ZnunyCodePolicy Extensions

## Table of Contents

- [Overview](#overview)
- [Extension Components](#extension-components)
  - [1. TidyAllRC Configuration Files](#1-tidyallrc-configuration-files)
  - [2. TidyAll PM Modules](#2-tidyall-pm-modules)
  - [3. Custom Plugins](#3-custom-plugins)
  - [4. Test Files](#4-test-files)
  - [5. Documentation](#5-documentation)
  - [6. Automated Management](#6-automated-management)
- [How It Works](#how-it-works)
- [Setup Methods](#setup-methods)
  - [Method 1: Manual Extension (Local)](#method-1-manual-extension-local)
  - [Method 2: Git Submodule Integration](#method-2-git-submodule-integration)
- [Extension Management Commands](#extension-management-commands)
  - [Basic Commands](#basic-commands)
  - [Available Options](#available-options)
  - [Example Commands](#example-commands)
  - [Bulk Operations](#bulk-operations)
  - [Repairing Extensions](#repairing-extensions)
- [Extended ZnunyCodePolicy Repository Structure](#extended-znunycodepolicy-repository-structure)
- [Extension Repository Structure](#extension-repository-structure)
- [Debugging Extensions](#debugging-extensions)
  - [Extension Status](#extension-status)
  - [Verbose Output](#verbose-output)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)

---

## Overview

ZnunyCodePolicy supports a comprehensive extension system that allows you to:

- **Add custom configurations** through extensions `.tidyallrc` files
- **Add TidyAll PM modules** for enhanced functionality
- **Develop custom plugins** with your own validation logic
- **Override existing rules** for specific needs
- **Manage extensions** with automated installation and removal

---

## Extension Components

### 1. TidyAllRC Configuration Files

`Extensions/*/Kernel/TidyAll/*.tidyallrc`
Modular configuration files that extend the main `tidyallrc` configuration.

### 2. TidyAll PM Modules

`Extensions/*/Kernel/TidyAll/*.pm`
TidyAll modules that provide additional functionality and integrations.

### 3. Custom Plugins

`Extensions/*/Kernel/TidyAll/Plugin/*/`
Your own validation and transformation plugins integrated into the TidyAll workflow.

### 4. Test Files

`Extensions/*/scripts/test/`
Comprehensive test suites for extension validation.

### 5. Documentation

`Extensions/*/doc/`
Extension documentation and usage guides.

### 6. Automated Management
Scripts that handle linking, installation, and maintenance of extensions.

---

## How It Works

The `znuny.CodePolicy.pl` script automatically scans the `Kernel/TidyAll/` directory for:
- Extensions `.tidyallrc` files (configuration)
- Extensions `.pm` files (TidyAll modules)
- Custom plugins in `Plugin/` subdirectories

`.tidyallrc` files are loaded in alphabetical order after the main `tidyallrc` file.

This means that we only need to add new files and they will then be used directly.

`bin/znuny.CodePolicy.Extension.pl` helps us make these available (via linking).

---

## Setup Methods

You can extend ZnunyCodePolicy in two ways:

### Method 1: Manual Extension (Local)

**Best for:** Simple local customizations, single project modifications, quick testing.

1. **Copy example configuration:**
   ```bash
   # Use provided example as starting point
   cp Kernel/TidyAll/custom.tidyallrc.example Kernel/TidyAll/custom.tidyallrc

   # Edit configuration for your needs
   vim Kernel/TidyAll/custom.tidyallrc
   ```

2. **Add custom plugins (if needed):**
   ```bash
   # Copy example plugin as template
   cp Kernel/TidyAll/Plugin/Custom/Example.pm Kernel/TidyAll/Plugin/Custom/MyPlugin.pm

   # Customize plugin logic
   vim Kernel/TidyAll/Plugin/Custom/MyPlugin.pm
   ```

3. **Test the configuration:**
   ```bash
   perl bin/znuny.CodePolicy.pl --verbose --file-path README.md
   ```

### Method 2: Git Clone Integration

**Best for:** Shared configurations across multiple projects, team standards, version controlled extensions.

1. **Clone external extension repository:**
   ```bash
   cd /path/to/ZnunyCodePolicy
   git clone https://github.com/your-org/znuny-codepolicy-extensions.git Extensions/Example
   cd ..
   ```

2. **Setup automatic linking:**
   ```bash
   # Execute setup script from ZnunyCodePolicy root
   perl bin/znuny.CodePolicy.Extension.pl add Example
   ```

3. **Check extension status:**
   ```bash
   perl bin/znuny.CodePolicy.Extension.pl status
   ```

4. **Update extension when needed:**
   ```bash
   cd Extensions/Example
   git pull origin
   cd ../..
   perl bin/znuny.CodePolicy.Extension.pl remove Example
   perl bin/znuny.CodePolicy.Extension.pl add Example     # Refresh links if needed
   ```

**Git Clone benefits:**
- ✅ **No .gitmodules**: Keeps main repository clean
- ✅ **Simple Updates**: Standard `git pull` workflow (no submodule complexity)
- ✅ **Easy Setup**: Single `git clone` command
- ✅ **Version Control**: Full Git history and branch management
- ✅ **Modular**: Clean separation of public/internal rules
- ✅ **Automated Linking**: Script-based installation and maintenance
- ✅ **Private Extensions**: Add internal/private extensions without tracking

---

## Extension Management Commands

The `znuny.CodePolicy.Extension.pl` script provides comprehensive extension management:

### Basic Commands

```bash
# Show current extension status
perl bin/znuny.CodePolicy.Extension.pl status

# Add a specific extension
perl bin/znuny.CodePolicy.Extension.pl add <extension-name>

# Remove a specific extension
perl bin/znuny.CodePolicy.Extension.pl remove <extension-name>

# Add all available extensions
perl bin/znuny.CodePolicy.Extension.pl add --all

# Remove all extensions (use with caution)
perl bin/znuny.CodePolicy.Extension.pl remove --all
```

#### Available Options

- `-v, --verbose` - Show detailed output during operations
- `-h, --help` - Display usage information


### Example Commands

The extension management script supports any extension directory name:

```bash
# Setup different extensions
perl bin/znuny.CodePolicy.Extension.pl add Example           # Example extension
perl bin/znuny.CodePolicy.Extension.pl add Internal          # Internal company standards
perl bin/znuny.CodePolicy.Extension.pl add MyExtensions      # Personal extensions
perl bin/znuny.CodePolicy.Extension.pl add CompanyStandards  # Company-wide standards

# Remove specific extensions
perl bin/znuny.CodePolicy.Extension.pl remove Example
perl bin/znuny.CodePolicy.Extension.pl remove Internal

```

### Bulk Operations

```bash
# Add all available extensions at once
perl bin/znuny.CodePolicy.Extension.pl add --all --verbose

# Remove all extensions (use with caution)
perl bin/znuny.CodePolicy.Extension.pl remove --all --verbose
```

### Repairing Extensions

If extensions are broken in the new extension environment, you can easily repair them by removing and re-adding them.

```bash
# Remove all extensions and re-add them
perl bin/znuny.CodePolicy.Extension.pl remove --all
perl bin/znuny.CodePolicy.Extension.pl add --all

# Or repair specific extension
perl bin/znuny.CodePolicy.Extension.pl remove Example
perl bin/znuny.CodePolicy.Extension.pl add Example
```

---

## Extension Repository Structure

For Git submodule extensions, organize your repository like this:

```
ZnunyCodepolicyExample/
├── README.md                           # Extension documentation
├── Kernel/TidyAll/
│   ├── 100-example.tidyallrc           # Extension configuration
│   ├── Example.pm                      # Extension TidyAll module
│   └── Plugin/                         # Extension Plugins
│       └── Example/                    # new Extension Subdir 'Example'
│           └── README.pm               # Extension Plugin
│
├── scripts/test/TidyAll/
│   ├── Example.t                       # Extension TidyAll module tests
│   └── Plugin/                         # Extension Plugin tests
│       └── Example/                    # new Extension Subdir 'Example'
│           └── README.t                # UnitTest fo Extension Plugin
│
└── doc/
    └── en/
        └── feature.md                  # Extension Plugin documentation
```

---

## Extended ZnunyCodePolicy Repository Structure

After adding extensions, your ZnunyCodePolicy structure looks like this:

To ensure clarity, subdirectories are created as follows.

- ZnunyCodePolicy/Kernel/TidyAll/Plugin/Example
- ZnunyCodePolicy/scripts/test/Example
- ZnunyCodePolicy/doc/Example

The following files are an exception and cannot be created in these subdirectories.

- Kernel/TidyAll/100-example.tidyallrc       # Extension config
- Kernel/TidyAll/Example.pm                  # Extension TidyAll modules
- scripts/test/TidyAll/Example.t

```
★ = new

ZnunyCodePolicy/
  ├── Kernel/TidyAll/
  │   ├── tidyallrc                       # Main configuration (always loaded first)
  │   ├── custom.tidyallrc                # Custom configurations (optional)
★ │   ├── 100-example.tidyallrc           # Extension config (linked from extension)
  │   ├── Znuny.pm                        # Main TidyAll modules
★ │   ├── Example.pm                      # Extension TidyAll modules (linked from extension)
  │   └── Plugin/                         # Plugin directory
  │       ├── Znuny/                      # Default Znuny plugins
★ │       └── Example/                    # Extension plugins (linked from extension)
  │           └── README.pm               # Extension Plugin: README validation
  │
  ├──scripts/test/                        # Main tests
★ │   ├── Example/                        # Extension tests (linked from extension)
  │   │   └── TidyAll/
  │   │       ├── Example.t
  │   │       └── Plugin/Example
  │   │           └── README.t
  │   └── TidyAll/
          ├── Plugin/                     # Main Plugin tests
          └── Extensions.t
  │
  └──doc/
      ├── en
      │   └── feature.md                  # Main Plugin documentation
★     └── Example/                        # Extension documentation (linked)
          └── en/
              └── feature.md
```

**Note:** All extension files are symbolic links that point to the actual files in `Extensions/*/`


---

## Debugging Extensions

### Extension Status

Check which extensions are currently active:

```bash
perl bin/znuny.CodePolicy.Extension.pl status
```

Output example:
```
=== Extension Links Status ===

1. TidyAll Configuration Files (.tidyallrc)
  ✓ 100-example.tidyallrc -> ../Extensions/Example/Kernel/TidyAll/100-example.tidyallrc

2. TidyAll PM Files (.pm)
  ✓ SomeModule.pm -> ../Extensions/Example/Kernel/TidyAll/SomeModule.pm

3. Plugin Directories
  ✓ Plugin/Extension -> ../../Extensions/Example/Kernel/TidyAll/Plugin/Extension

4. Test Directories
  ✓ scripts/test/Example/README.t -> ../../../../Extensions/Example/scripts/test/TidyAll/Plugin/Extension/Example/README.t

5. Documentation Directories
  ✓ doc/Example -> ../Extensions/Example/doc

=== Status: Extensions are active ===
```

### Verbose Output

```bash
perl bin/znuny.CodePolicy.pl --verbose --file-path YourFile.pm
```

Output example:
```
Found extensions tidyallrc files:
  - custom.tidyallrc
  - 100-example.tidyallrc
Created combined configuration with 2 additional file(s)
```

---

## Troubleshooting

### Common Issues

1. **Extension not loaded**:
   - Check if extension is properly linked: `perl bin/znuny.CodePolicy.Extension.pl status`
   - Ensure `.tidyallrc` extension has correct filename and directory structure

2. **Plugin not found**:
   - Verify plugin path and class name
   - Check if plugin directory is properly linked in status output

3. **Syntax errors**:
   - Validate INI syntax in configuration files
   - Test with `perl bin/znuny.CodePolicy.pl --verbose --file-path README.md`

4. **Conflicting rules**:
   - Check load order and rule precedence
   - Use verbose mode to see which configuration files are loaded

5. **Broken links**:
   - Re-run extension add command: `perl bin/znuny.CodePolicy.Extension.pl add <extension-name>`
   - Check if extension directory exists in `Extensions/`

6. **Permission issues**:
   - Ensure write permissions in target directories
   - Check if symbolic links can be created

---

The ZnunyCodePolicy extension system provides a powerful, flexible way to customize and extend code policies while maintaining clean separation between core functionality and custom requirements. The new status monitoring and management commands make it easy to maintain and troubleshoot your extension setup.

Enjoy! 🚀
