# ZnunyCodePolicy

## Required CPAN modules

* Perl::Critic
* Perl::Critic::Moose
* Perl::Tidy
* XML::Parser
* Algorithm::Diff
* Code::TidyAll

## Installation

```bash
    sudo cpanm -i Perl::Critic Perl::Tidy XML::Parser Algorithm::Diff Code::TidyAll Perl::Critic::Moose
```

## Usage

Tidy all files in your current directory:
```bash
perl $WORKSPACE/ZnunyCodePolicy/bin/otrs.CodePolicy.pl --all
```

Tidy a single file in your directory:
```bash
perl $WORKSPACE/ZnunyCodePolicy/bin/otrs.CodePolicy.pl --file Test.pm
```

### Git Alias
You also can add git aliases to create shortcuts to tidy your file, for example:
```bash
[alias]
cc = !perl $WORKSPACE/ZnunyCodePolicy/bin/otrs.CodePolicy.pl --all
ccf = !perl $WORKSPACE/ZnunyCodePolicy/bin/otrs.CodePolicy.pl --file $@
```

```bash
$WORKSPACE/ZnunyCodePolicy$ git cc
$WORKSPACE/ZnunyCodePolicy$ git ccf Kernel/TidyAll/OTRS.pm
```

### Hooks
If you want to setup a local commit filter to your git directory you can run the following command:
```bash
perl $WORKSPACE/ZnunyCodePolicy/scripts/install-git-hooks.pl
```

To remove the local commit filter in your git directory you can run the following command:
```bash
perl $WORKSPACE/ZnunyCodePolicy/scripts/uninstall-git-hooks.pl
```
