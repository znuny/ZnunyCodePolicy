# ZnunyCodePolicy

## Required CPAN modules

* Algorithm::Diff
* Code::TidyAll
* Perl::Critic
* Perl::Tidy
* Pod::POM
* XML::Parser

## Installation

```bash
    sudo cpanm -i Algorithm::Diff Code::TidyAll Perl::Critic Perl::Tidy Pod::POM XML::Parser
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
