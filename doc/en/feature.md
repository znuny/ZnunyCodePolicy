# Functionality

## Required CPAN modules

* Algorithm::Diff
* Code::TidyAll
* Perl::Critic
* Perl::Tidy
* Pod::POM
* XML::Parser
* Text::PO::Gettext

## Installation

```bash
    sudo cpanm -i Algorithm::Diff Code::TidyAll Perl::Critic Perl::Tidy Pod::POM XML::Parser Text::PO::Gettext
```

### ESLint

If you want to run ESLint, you need to have installed `npm` and run `development/bin/znuny.CodePolicy.pl --install-eslint` for installing eslint via npm.

```
bin/znuny.CodePolicy.pl --install-eslint
```

## Usage

Tidy all files in your current directory:
```bash
perl $WORKSPACE/ZnunyCodePolicy/bin/znuny.CodePolicy.pl --all-files
```

Tidy a single file in your directory:

```bash
perl $WORKSPACE/ZnunyCodePolicy/bin/znuny.CodePolicy.pl --file-path Test.pm
```

### Git Alias

You also can add git aliases to create shortcuts to tidy your file, for example:

```bash
[alias]
cc = !perl $WORKSPACE/ZnunyCodePolicy/bin/znuny.CodePolicy.pl --all-files
ccf = !perl $WORKSPACE/ZnunyCodePolicy/bin/znuny.CodePolicy.pl --file-path $@
```

```bash
$WORKSPACE/ZnunyCodePolicy$ git cc
$WORKSPACE/ZnunyCodePolicy$ git ccf Kernel/System/Main.pm
```

### Hooks

If you want to set up a local commit filter to your git directory you can run the following command:

```bash
perl $WORKSPACE/ZnunyCodePolicy/scripts/install-git-hooks.pl
```

To remove the local commit filter in your git directory you can run the following command:

```bash
perl $WORKSPACE/ZnunyCodePolicy/scripts/uninstall-git-hooks.pl
```

## Validation Commands

```bash
# Test with different modes
perl bin/znuny.CodePolicy.pl --mode fast --file-path test.pl
perl bin/znuny.CodePolicy.pl --mode ci --file-path test.pl

# Configuration validation
perl bin/znuny.CodePolicy.pl --verbose --dry-run --all-files
```


## Extensions

ZnunyCodePolicy supports a comprehensive extension system that allows you to extend and customize code policies through additional configurations, custom plugins, and Git submodule integration.

For detailed setup instructions, custom plugin development, configuration examples, and troubleshooting guides, see:

**[Extensions Documentation](extensions.md)**

## Configuration Options

See [Configuration Guide](configuration.md) for detailed configuration examples and options.