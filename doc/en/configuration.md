# Configuration Options

## Override Existing Rules

```ini
; Override the main PerlTidy configuration
[+TidyAll::Plugin::Znuny::Perl::PerlTidy]
select = **/*.{pl,pm,psgi,t}
ignore = Kernel/Config.pm
ignore = my_special_directory/**/*
argv = -l=100 -i=2  # Different formatting options
```

## Ignore Patterns

```ini
; Add additional ignore patterns
[+TidyAll::Plugin::Znuny::Common::Origin]
ignore = vendor/**/*
ignore = third_party/**/*
ignore = legacy_code/**/*
```

## Mode-Specific Rules

```ini
; Only run expensive checks in CI mode
[+TidyAll::Plugin::Znuny::Perl::PerlCritic]
only_modes = ci

; Skip certain checks in fast mode
[+TidyAll::Plugin::Znuny::JavaScript::ESLint]
except_modes = fast
```
