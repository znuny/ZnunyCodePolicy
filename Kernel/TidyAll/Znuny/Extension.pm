# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Znuny::Extension;

use strict;
use warnings;
use utf8;

use Cwd            qw(abs_path realpath);
use File::Basename qw(basename dirname);
use File::Find;
use File::Path qw(make_path);
use File::Spec;

=head1 NAME

TidyAll::Znuny::Extension - Check that active extensions loaded all policy files.

=head1 DESCRIPTION

An extension is active when a symlink under the CodePolicy tree points into
C<Extensions/Name/>.

Policy files of that extension are:

=over

=item * C<Kernel/TidyAll/*.tidyallrc> included in the combined configuration

=item * C<Kernel/TidyAll/*.pm> linked into the CodePolicy tree

=item * every file under C<Kernel/TidyAll/Plugin/> reachable through that tree

=item * every enabled C<[+TidyAll::Plugin::...]> class from those tidyallrc files

=back

Tests and documentation are not loaded by C<bin/znuny.CodePolicy.pl>.

=cut

# ---- Public: discover ----

=head2 Available()

    Lists the extension directories under Extensions/.

    my @Names = TidyAll::Znuny::Extension::Available(
        RepoRoot => '/opt/znuny/ZnunyCodePolicy',
    );

    Returns a sorted list. The list is empty when Extensions/ does not exist.

=cut

sub Available {
    my (%Param) = @_;

    my $ExtensionsDir = File::Spec->catdir( $Param{RepoRoot}, 'Extensions' );
    return if !-d $ExtensionsDir;

    my @Names;
    ENTRY:
    for my $Entry ( _ReadDir($ExtensionsDir) ) {
        my $Path = File::Spec->catdir( $ExtensionsDir, $Entry );
        next ENTRY if !-d $Path;
        push @Names, $Entry;
    }
    return @Names;
}

=head2 Linked()

    Returns the extension names that have a directory symlink.

    The names come from Kernel/TidyAll/Plugin, scripts/test and doc.

    my @Names = TidyAll::Znuny::Extension::Linked(
        RepoRoot => '/opt/znuny/ZnunyCodePolicy',
    );

    Returns a sorted list of names.

=cut

sub Linked {
    my (%Param) = @_;

    my $RepoRoot = $Param{RepoRoot};
    my %Names;

    my $PluginDir = File::Spec->catdir( $RepoRoot, 'Kernel', 'TidyAll', 'Plugin' );
    ENTRY:
    for my $Entry ( _SymlinkNames($PluginDir) ) {
        $Names{$Entry} = 1;
    }

    my $TestDir = File::Spec->catdir( $RepoRoot, 'scripts', 'test' );
    TEST:
    for my $Entry ( _SymlinkNames($TestDir) ) {
        $Names{$Entry} = 1;
    }

    my $DocDir = File::Spec->catdir( $RepoRoot, 'doc' );
    DOC:
    for my $Entry ( _SymlinkNames($DocDir) ) {
        $Names{$Entry} = 1;
    }

    my @Names = sort keys %Names;
    return @Names;
}

# ---- Public: link / unlink ----

=head2 Add()

    Removes the current links of one extension and creates them again.

    my $Result = TidyAll::Znuny::Extension::Add(
        RepoRoot => '/opt/znuny/ZnunyCodePolicy',
        Name     => 'Internal',
        Verbose  => 1,                                      # optional
    );

    Returns a hash reference:

        {
            Log => [
                {
                    Color => 'green',
                    Text  => "  linked\n",
                },
            ],
        };

=cut

sub Add {
    my (%Param) = @_;

    my $Log = [];
    Clear(
        RepoRoot => $Param{RepoRoot},
        Name     => $Param{Name},
        Scope    => 'name',
        Log      => $Log,
        Verbose  => $Param{Verbose},
    );
    Link(
        RepoRoot => $Param{RepoRoot},
        Name     => $Param{Name},
        Log      => $Log,
        Verbose  => $Param{Verbose},
    );

    return { Log => $Log };
}

=head2 Remove()

    Removes the links of one extension, or every extension link.

    my $Result = TidyAll::Znuny::Extension::Remove(
        RepoRoot => '/opt/znuny/ZnunyCodePolicy',
        Name     => 'Internal',                             # required when All is false
        All      => 0,                                      # optional, 1 removes every extension link
        Verbose  => 1,                                      # optional
    );

    Returns a hash reference with Log. See Add().

=cut

sub Remove {
    my (%Param) = @_;

    my $Log = [];
    if ( $Param{All} ) {
        _RemoveAll( $Log, $Param{RepoRoot} );
    }
    else {
        _RemoveName( $Log, $Param{RepoRoot}, $Param{Name}, $Param{Verbose} );
    }

    return { Log => $Log };
}

=head2 Clear()

    Deletes extension symlinks and does not create new ones.

    Scope C<all> deletes every tidyallrc link, pm link, plugin directory link,
    test directory link and documentation directory link.
    Any other scope deletes every tidyallrc and pm link, plus C<Plugin/Name> and C<doc/Name>.

    my $Result = TidyAll::Znuny::Extension::Clear(
        RepoRoot => '/opt/znuny/ZnunyCodePolicy',
        Name     => 'Internal',                             # used when Scope is not all
        Scope    => 'name',                                 # optional, 'all' or anything else
        Log      => [],                                     # optional, log entries are appended here
    );

    Returns a hash reference with Log. See Add().

=cut

sub Clear {
    my (%Param) = @_;

    my $Log = $Param{Log} // [];
    my $RepoRoot = $Param{RepoRoot};
    my $TidyAllDir = File::Spec->catdir( $RepoRoot, 'Kernel', 'TidyAll' );

    if ( ( $Param{Scope} // '' ) eq 'all' ) {
        _Log( $Log, 'step', "1. Cleaning Up All Old Extension Links...\n" );
        _UnlinkMatches( $TidyAllDir, qr{\.tidyallrc\z} );
        _UnlinkMatches( $TidyAllDir, qr{\.pm\z} );
        _UnlinkDirectoryLinks( File::Spec->catdir( $TidyAllDir, 'Plugin' ) );
        _UnlinkDirectoryLinks( File::Spec->catdir( $RepoRoot, 'scripts', 'test' ) );
        _UnlinkDirectoryLinks( File::Spec->catdir( $RepoRoot, 'doc' ) );
        _Log( $Log, 'green', "  ✓ All old extension links cleaned up\n" );
        return { Log => $Log };
    }

    my $Name = $Param{Name};
    _Log( $Log, 'step', "1. Cleaning Up Old Extension Links for: $Name...\n" );
    _UnlinkMatches( $TidyAllDir, qr{\.tidyallrc\z} );
    _UnlinkMatches( $TidyAllDir, qr{\.pm\z} );

    my $PluginLink = File::Spec->catdir( $TidyAllDir, 'Plugin', $Name );
    if ( -l $PluginLink ) {
        unlink $PluginLink;
    }
    my $DocLink = File::Spec->catdir( $RepoRoot, 'doc', $Name );
    if ( -l $DocLink ) {
        unlink $DocLink;
    }

    _Log( $Log, 'green', "  ✓ Cleanup completed\n" );
    _Log( $Log, '',      "\n" );
    return { Log => $Log };
}

=head2 Link()

    Creates relative symlinks for one extension.

    RepoRoot is resolved with abs_path() before the relative targets are built.
    Linked paths are Kernel/TidyAll/*.tidyallrc, Kernel/TidyAll/*.pm,
    Kernel/TidyAll/Plugin/*, the scripts/test/Name directory and doc/.

    my $Result = TidyAll::Znuny::Extension::Link(
        RepoRoot => '/opt/znuny/ZnunyCodePolicy',
        Name     => 'Internal',
        Log      => [],                                     # optional
        Verbose  => 1,                                      # optional, logs created test directories
    );

    Returns a hash reference with Log. See Add().

=cut

sub Link {
    my (%Param) = @_;

    my $Log      = $Param{Log} // [];
    my $RepoRoot = abs_path( $Param{RepoRoot} ) || $Param{RepoRoot};
    my $Name     = $Param{Name};
    my $ExtensionDir = File::Spec->catdir( $RepoRoot, 'Extensions', $Name );

    _LinkConfigFiles( $Log, $RepoRoot, $ExtensionDir, $Name );
    _Log( $Log, '', "\n" );
    _LinkModuleFiles( $Log, $RepoRoot, $ExtensionDir, $Name );
    _Log( $Log, '', "\n" );
    _LinkPluginDirectories( $Log, $RepoRoot, $ExtensionDir, $Name );
    _Log( $Log, '', "\n" );
    _LinkTests( $Log, $RepoRoot, $ExtensionDir, $Name );
    _Log( $Log, '', "\n" );
    _LinkDocumentation( $Log, $RepoRoot, $ExtensionDir, $Name );
    _Log( $Log, '', "\n" );

    return { Log => $Log };
}

=head2 Sync()

    Creates the missing links of every active extension.

    An existing link stays in place.
    scripts/test/Name becomes one directory symlink, so a new test file is visible without another link.
    Kernel/TidyAll/*.tidyallrc and Kernel/TidyAll/*.pm still need their own symlink. This function creates that symlink.

    my $Result = TidyAll::Znuny::Extension::Sync(
        RepoRoot => '/opt/znuny/ZnunyCodePolicy',
    );

    Returns a hash reference:

        {
            Created => 1,
            Paths   => [
                '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll/NewModule.pm',
            ],
            Log => [],
        };

=cut

sub Sync {
    my (%Param) = @_;

    my $Log      = [];
    my $RepoRoot = abs_path( $Param{RepoRoot} ) || $Param{RepoRoot};
    my @Paths;

    EXTENSION:
    for my $Name ( _ActiveExtensionNames($RepoRoot) ) {
        my $ExtensionDir = File::Spec->catdir( $RepoRoot, 'Extensions', $Name );
        next EXTENSION if !-d $ExtensionDir;

        push @Paths, _LinkConfigFiles( $Log, $RepoRoot, $ExtensionDir, $Name, 1 );
        push @Paths, _LinkModuleFiles( $Log, $RepoRoot, $ExtensionDir, $Name, 1 );
        push @Paths, _LinkPluginDirectories( $Log, $RepoRoot, $ExtensionDir, $Name, 1 );
        push @Paths, _LinkTests( $Log, $RepoRoot, $ExtensionDir, $Name, 1 );
        push @Paths, _LinkDocumentation( $Log, $RepoRoot, $ExtensionDir, $Name, 1 );
    }

    return {
        Created => scalar @Paths,
        Paths   => \@Paths,
        Log     => $Log,
    };
}

# ---- Public: inspect ----

=head2 Status()

    Lists the extension symlinks grouped by configuration, modules, plugins, tests and documentation.

    my $Status = TidyAll::Znuny::Extension::Status(
        RepoRoot => '/opt/znuny/ZnunyCodePolicy',
    );

    Returns a hash reference:

        {
            Active => 1,
            Groups => [
                {
                    Title            => 'TidyAll Configuration Files (.tidyallrc)',
                    Empty            => 'No .tidyallrc links found',
                    DirectoryMissing => undef,
                    Links            => [
                        {
                            Label  => '100-internal.tidyallrc',
                            Target => 'Extensions/Internal/Kernel/TidyAll/100-internal.tidyallrc',
                            Broken => 0,
                        },
                    ],
                    Missing => [
                        {
                            Label  => 'Extensions/Internal/Kernel/TidyAll/Plugin/Znuny/Example.pm',
                            Reason => 'plugin file is missing in the extension',
                        },
                    ],
                },
            ],
            Incomplete => 1,
        };

    Active is true when any listed symlink exists. Target is the link text with a leading C<../> sequence removed.
    Broken is true when the symlink target does not exist.
    Missing lists a link that the extension provides but that is not linked,
    or a plugin file that the tidyallrc enables and that still has to be written.
    Incomplete is true when a link is broken or missing.

=cut

sub Status {
    my (%Param) = @_;

    my $RepoRoot = $Param{RepoRoot};
    my $TidyAllDir = File::Spec->catdir( $RepoRoot, 'Kernel', 'TidyAll' );
    my $Missing    = _MissingLinks($RepoRoot);
    my @Groups;
    my $Active     = 0;
    my $Incomplete = 0;

    my @ConfigLinks = _StatusLinks(
        Dir     => $TidyAllDir,
        Pattern => qr{\.tidyallrc\z},
    );
    if (@ConfigLinks) {
        $Active = 1;
    }
    push @Groups, {
        Title   => 'TidyAll Configuration Files (.tidyallrc)',
        Empty   => 'No .tidyallrc links found',
        Links   => \@ConfigLinks,
        Missing => $Missing->{Config},
    };

    my @ModuleLinks = _StatusLinks(
        Dir     => $TidyAllDir,
        Pattern => qr{\.pm\z},
    );
    if (@ModuleLinks) {
        $Active = 1;
    }
    push @Groups, {
        Title   => 'TidyAll PM Files (.pm)',
        Empty   => 'No .pm links found',
        Links   => \@ModuleLinks,
        Missing => $Missing->{Module},
    };

    my $PluginDir = File::Spec->catdir( $TidyAllDir, 'Plugin' );
    my @PluginLinks;
    my $PluginMissing;
    if ( !-d $PluginDir ) {
        $PluginMissing = 'Plugin directory not found';
    }
    else {
        PLUGIN:
        for my $Entry ( _SymlinkNames($PluginDir) ) {
            my $Path = File::Spec->catdir( $PluginDir, $Entry );
            push @PluginLinks, {
                Label  => "Plugin/$Entry",
                Target => _DisplayPath( readlink $Path ),
                Broken => _BrokenLink($Path),
            };
        }
        if (@PluginLinks) {
            $Active = 1;
        }
    }
    push @Groups, {
        Title            => 'Plugin Directories',
        Empty            => 'No plugin directory links found',
        DirectoryMissing => $PluginMissing,
        Links            => \@PluginLinks,
        Missing          => $Missing->{Plugin},
    };

    my $TestDir = File::Spec->catdir( $RepoRoot, 'scripts', 'test' );
    my @TestLinks;
    my $TestMissing;
    if ( !-d $TestDir ) {
        $TestMissing = 'Test directory not found';
    }
    else {
        TESTDIR:
        for my $Entry ( _SymlinkNames($TestDir) ) {
            my $Path = File::Spec->catdir( $TestDir, $Entry );
            push @TestLinks, {
                Label  => "scripts/test/$Entry",
                Target => _DisplayPath( readlink $Path ),
                Broken => _BrokenLink($Path),
            };
        }
        File::Find::find(
            {
                wanted => sub {
                    my $Path = $File::Find::name;
                    return if !-f $Path;
                    return if !-l $Path;
                    return if $Path !~ m{\.t\z};

                    my $Relative = File::Spec->abs2rel( $Path, File::Spec->catdir( $RepoRoot, 'scripts' ) );
                    push @TestLinks, {
                        Label  => "scripts/$Relative",
                        Target => _DisplayPath( readlink $Path ),
                        Broken => _BrokenLink($Path),
                    };
                    return;
                },
                no_chdir => 1,
            },
            $TestDir
        );
        @TestLinks = sort { $a->{Label} cmp $b->{Label} } @TestLinks;
        if (@TestLinks) {
            $Active = 1;
        }
    }
    push @Groups, {
        Title            => 'Test Directories',
        Empty            => 'No test directory links found',
        DirectoryMissing => $TestMissing,
        Links            => \@TestLinks,
        Missing          => $Missing->{Test},
    };

    my $DocDir = File::Spec->catdir( $RepoRoot, 'doc' );
    my @DocLinks;
    my $DocMissing;
    if ( !-d $DocDir ) {
        $DocMissing = 'Documentation directory not found';
    }
    else {
        DOC:
        for my $Entry ( _SymlinkNames($DocDir) ) {
            my $Path = File::Spec->catdir( $DocDir, $Entry );
            push @DocLinks, {
                Label  => "doc/$Entry",
                Target => _DisplayPath( readlink $Path ),
                Broken => _BrokenLink($Path),
            };
        }
        if (@DocLinks) {
            $Active = 1;
        }
    }
    push @Groups, {
        Title            => 'Documentation Directories',
        Empty            => 'No documentation directory links found',
        DirectoryMissing => $DocMissing,
        Links            => \@DocLinks,
        Missing          => $Missing->{Documentation},
    };

    GROUP:
    for my $Group (@Groups) {
        if ( @{ $Group->{Missing} // [] } ) {
            $Incomplete = 1;
        }
        LINK:
        for my $Link ( @{ $Group->{Links} // [] } ) {
            if ( $Link->{Broken} ) {
                $Incomplete = 1;
                last LINK;
            }
        }
    }

    return {
        Active     => $Active,
        Incomplete => $Incomplete,
        Groups     => \@Groups,
    };
}

=head2 LinkSummary()

    Counts the files that belong to one linked extension.

    Config and Module count symlinks in Kernel/TidyAll.
    Test counts .t files under scripts/test/Name.
    Plugin counts .pm files in the extension Plugin directory.
    Documentation counts files under the extension doc directory.

    my $Summary = TidyAll::Znuny::Extension::LinkSummary(
        RepoRoot     => '/opt/znuny/ZnunyCodePolicy',
        Name         => 'Internal',
        ExtensionDir => '/opt/znuny/ZnunyCodePolicy/Extensions/Internal',    # optional
    );

    Returns a hash reference:

        {
            Config        => 1,
            Module        => 0,
            Test          => 2,
            Plugin        => 14,
            Documentation => 1,
        };

=cut

sub LinkSummary {
    my (%Param) = @_;

    my $RepoRoot     = $Param{RepoRoot};
    my $Name         = $Param{Name};
    my $ExtensionDir = $Param{ExtensionDir} // File::Spec->catdir( $RepoRoot, 'Extensions', $Name );
    my $TidyAllDir   = File::Spec->catdir( $RepoRoot, 'Kernel', 'TidyAll' );

    my $Config = scalar _SymlinkNames( $TidyAllDir, qr{\.tidyallrc\z} );
    my $Module = scalar _SymlinkNames( $TidyAllDir, qr{\.pm\z} );

    my $Test  = 0;
    my $Tests = File::Spec->catdir( $RepoRoot, 'scripts', 'test', $Name );
    if ( -d $Tests ) {
        File::Find::find(
            {
                wanted   => sub { $Test++ if -f $File::Find::name && $File::Find::name =~ m{\.t\z} },
                no_chdir => 1,
            },
            $Tests
        );
    }

    my $Plugin    = 0;
    my $PluginDir = File::Spec->catdir( $ExtensionDir, 'Kernel', 'TidyAll', 'Plugin' );
    if ( -d $PluginDir ) {
        File::Find::find(
            {
                wanted   => sub { $Plugin++ if -f $File::Find::name && $File::Find::name =~ m{\.pm\z} },
                no_chdir => 1,
            },
            $PluginDir
        );
    }

    my $Documentation = 0;
    my $DocDir        = File::Spec->catdir( $ExtensionDir, 'doc' );
    if ( -d $DocDir ) {
        File::Find::find(
            {
                wanted   => sub { $Documentation++ if -f $File::Find::name },
                no_chdir => 1,
            },
            $DocDir
        );
    }

    return {
        Config        => $Config,
        Module        => $Module,
        Test          => $Test,
        Plugin        => $Plugin,
        Documentation => $Documentation,
    };
}

=head2 RemainingSummary()

    Counts the symlinks that are still present.

    my $Summary = TidyAll::Znuny::Extension::RemainingSummary(
        RepoRoot => '/opt/znuny/ZnunyCodePolicy',
    );

    Returns a hash reference with the same keys as LinkSummary().
    Plugin, Test and Documentation count directory symlinks, not files inside them.

=cut

sub RemainingSummary {
    my (%Param) = @_;

    my $RepoRoot   = $Param{RepoRoot};
    my $TidyAllDir = File::Spec->catdir( $RepoRoot, 'Kernel', 'TidyAll' );

    return {
        Config        => scalar _SymlinkNames( $TidyAllDir, qr{\.tidyallrc\z} ),
        Module        => scalar _SymlinkNames( $TidyAllDir, qr{\.pm\z} ),
        Plugin        => scalar _SymlinkNames( File::Spec->catdir( $TidyAllDir, 'Plugin' ) ),
        Test          => scalar _SymlinkNames( File::Spec->catdir( $RepoRoot, 'scripts', 'test' ) ),
        Documentation => scalar _SymlinkNames( File::Spec->catdir( $RepoRoot, 'doc' ) ),
    };
}

# ---- Public: load check ----

=head2 Check()

    Checks that every active extension loaded all of its policy files.

    An extension is active when a symlink target contains C<Extensions/Name/>.
    LoadedTidyAllrc is the list of tidyallrc paths included in the combined configuration.

    my $Report = TidyAll::Znuny::Extension::Check(
        RepoRoot        => '/opt/znuny/ZnunyCodePolicy',
        LoadedTidyAllrc => [                                # optional
            '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll/100-internal.tidyallrc',
        ],
    );

    Dies when RepoRoot is missing.

    Returns a hash reference:

        {
            Complete   => 1,
            Extensions => [
                {
                    Name             => 'Internal',
                    Complete         => 1,
                    ConfigLoaded     => 1,
                    ConfigTotal      => 1,
                    ModuleLoaded     => 0,
                    ModuleTotal      => 0,
                    PluginFileLoaded => 14,
                    PluginFileTotal  => 14,
                    PluginLoaded     => 8,
                    PluginTotal      => 8,
                    Loaded           => [
                        {
                            Type => 'config',
                            Path => 'Kernel/TidyAll/100-internal.tidyallrc',
                        },
                    ],
                    Missing => [
                        {
                            Type   => 'plugin',
                            Path   => 'TidyAll::Plugin::Znuny::Internal::Example',
                            Reason => 'plugin file is not linked into Kernel/TidyAll/Plugin',
                        },
                    ],
                },
            ],
        };

    Complete is true only when every extension is complete. Counts cover config, module, plugin file and plugin.

=cut

sub Check {
    my (%Param) = @_;

    my $RepoRoot = $Param{RepoRoot};
    if ( !defined $RepoRoot || !length $RepoRoot ) {
        die "RepoRoot is required.\n";
    }

    my $LoadedTidyAllrc = $Param{LoadedTidyAllrc} // [];
    my %LoadedConfig    = _LoadedConfigMap($LoadedTidyAllrc);
    my @ExtensionNames  = _ActiveExtensionNames($RepoRoot);

    my @Extensions;
    my $Complete = 1;

    EXTENSION:
    for my $ExtensionName (@ExtensionNames) {
        my $Extension = _CheckExtension(
            RepoRoot      => $RepoRoot,
            ExtensionName => $ExtensionName,
            LoadedConfig  => \%LoadedConfig,
        );
        if ( !$Extension->{Complete} ) {
            $Complete = 0;
        }
        push @Extensions, $Extension;
    }

    return {
        Complete   => $Complete,
        Extensions => \@Extensions,
    };
}

=head2 FormatReport()

    Formats a Check() report as header lines.

    The label is padded to column 29.
    With no active extension the value is "none active".
    A complete extension appends loaded/total counts.
    An incomplete extension appends "incomplete" and one line per missing item.
    Verbose also lists every loaded item.

    my $Text = TidyAll::Znuny::Extension::FormatReport(
        Report  => $Report,                                 # optional, empty report means none active
        Verbose => 1,                                       # optional
    );

    Returns a string ending with a newline.

=cut

sub FormatReport {
    my (%Param) = @_;

    my $Report  = $Param{Report} // {};
    my $Verbose = $Param{Verbose} ? 1 : 0;
    my $Indent  = ' ' x 29;

    my $Extensions = $Report->{Extensions} // [];
    if ( !@{$Extensions} ) {
        return sprintf( "%-29s%s\n", 'Extensions:', 'none active' );
    }

    my $Text  = '';
    my $First = 1;

    EXTENSION:
    for my $Extension ( @{$Extensions} ) {
        my $Value = $Extension->{Name};
        if ( $Extension->{Complete} ) {
            my $Counts = _SummaryCounts($Extension);
            if ($Counts) {
                $Value .= " ($Counts)";
            }
        }
        else {
            $Value .= ' incomplete';
        }

        if ($First) {
            $Text .= sprintf( "%-29s%s\n", 'Extensions:', $Value );
            $First = 0;
        }
        else {
            $Text .= $Indent . $Value . "\n";
        }

        if ( !$Extension->{Complete} ) {
            MISSING:
            for my $Item ( @{ $Extension->{Missing} // [] } ) {
                $Text .= $Indent . "missing $Item->{Type}: $Item->{Path}\n";
                if ( $Item->{Reason} ) {
                    $Text .= $Indent . "  $Item->{Reason}\n";
                }
            }
        }

        if ($Verbose) {
            LOADED:
            for my $Item ( @{ $Extension->{Loaded} // [] } ) {
                $Text .= $Indent . "$Item->{Type}: $Item->{Path}\n";
            }
        }
    }

    return $Text;
}

# ---- Internal: link ----

=head2 _LinkConfigFiles()

    Links C<*.tidyallrc> from the extension into Kernel/TidyAll.

    TidyAll::Znuny::Extension::_LinkConfigFiles(
        $Log,
        '/opt/znuny/ZnunyCodePolicy',
        '/opt/znuny/ZnunyCodePolicy/Extensions/Internal',
        'Internal',
    );

    Returns nothing. A missing source directory is logged as a warning.

=cut

sub _LinkConfigFiles {
    my ( $Log, $RepoRoot, $ExtensionDir, $Name, $Quiet ) = @_;

    _Log( $Log, 'step', "2. Linking TidyAll Configuration Files for: $Name...\n" ) if !$Quiet;
    my $SourceDir = File::Spec->catdir( $ExtensionDir, 'Kernel', 'TidyAll' );
    my $TargetDir = File::Spec->catdir( $RepoRoot,     'Kernel', 'TidyAll' );
    if ( !-d $SourceDir ) {
        _Log( $Log, 'warning', '  ⚠ No Kernel/TidyAll directory found in extension' ) if !$Quiet;
        return;
    }

    my @Created;
    FILE:
    for my $Entry ( _ReadDir($SourceDir) ) {
        next FILE if $Entry !~ m{\.tidyallrc\z};
        my $Source = File::Spec->catfile( $SourceDir, $Entry );
        next FILE if !-f $Source;
        my $Created = _CreateLink( $Log, $Source, File::Spec->catfile( $TargetDir, $Entry ) );
        push @Created, $Created if $Created;
    }
    return @Created;
}

=head2 _LinkModuleFiles()

    Links C<*.pm> from the extension Kernel/TidyAll directory into the repository.

    TidyAll::Znuny::Extension::_LinkModuleFiles(
        $Log,
        '/opt/znuny/ZnunyCodePolicy',
        '/opt/znuny/ZnunyCodePolicy/Extensions/Internal',
        'Internal',
    );

    Returns nothing. A missing source directory is logged as a warning.

=cut

sub _LinkModuleFiles {
    my ( $Log, $RepoRoot, $ExtensionDir, $Name, $Quiet ) = @_;

    _Log( $Log, 'step', "3. Linking TidyAll PM Files for: $Name...\n" ) if !$Quiet;
    my $SourceDir = File::Spec->catdir( $ExtensionDir, 'Kernel', 'TidyAll' );
    my $TargetDir = File::Spec->catdir( $RepoRoot,     'Kernel', 'TidyAll' );
    if ( !-d $SourceDir ) {
        _Log( $Log, 'warning', '  ⚠ No Kernel/TidyAll directory found in extension' ) if !$Quiet;
        return;
    }

    my @Created;
    FILE:
    for my $Entry ( _ReadDir($SourceDir) ) {
        next FILE if $Entry !~ m{\.pm\z};
        my $Source = File::Spec->catfile( $SourceDir, $Entry );
        next FILE if !-f $Source;
        my $Created = _CreateLink( $Log, $Source, File::Spec->catfile( $TargetDir, $Entry ) );
        push @Created, $Created if $Created;
    }
    return @Created;
}

=head2 _LinkPluginDirectories()

    Links each directory under the extension Plugin directory into Kernel/TidyAll/Plugin.

    TidyAll::Znuny::Extension::_LinkPluginDirectories(
        $Log,
        '/opt/znuny/ZnunyCodePolicy',
        '/opt/znuny/ZnunyCodePolicy/Extensions/Internal',
        'Internal',
    );

    Returns nothing. A missing Plugin directory is logged as a warning.

=cut

sub _LinkPluginDirectories {
    my ( $Log, $RepoRoot, $ExtensionDir, $Name, $Quiet ) = @_;

    _Log( $Log, 'step', "4. Linking Plugin Directories for: $Name...\n" ) if !$Quiet;
    my $SourceTidyAll = File::Spec->catdir( $ExtensionDir, 'Kernel', 'TidyAll' );
    if ( !-d $SourceTidyAll ) {
        _Log( $Log, 'warning', '  ⚠ No Kernel/TidyAll directory found in extension' ) if !$Quiet;
        return;
    }

    my $SourcePlugin = File::Spec->catdir( $SourceTidyAll, 'Plugin' );
    if ( !-d $SourcePlugin ) {
        _Log( $Log, 'warning', '  ⚠ No Plugin directory found in extension' ) if !$Quiet;
        return;
    }

    my @Created;
    my $TargetPlugin = File::Spec->catdir( $RepoRoot, 'Kernel', 'TidyAll', 'Plugin' );
    DIR:
    for my $Entry ( _ReadDir($SourcePlugin) ) {
        my $Source = File::Spec->catdir( $SourcePlugin, $Entry );
        next DIR if !-d $Source;
        my $Created = _CreateLink( $Log, $Source, File::Spec->catdir( $TargetPlugin, $Entry ) );
        push @Created, $Created if $Created;
    }
    return @Created;
}

=head2 _LinkTests()

    Links the extension scripts/test directory to scripts/test/Name.

    A new test file inside that directory is visible through the existing link.
    A legacy directory of per-file symlinks is replaced when it contains only symlinks.

    TidyAll::Znuny::Extension::_LinkTests(
        $Log,
        '/opt/znuny/ZnunyCodePolicy',
        '/opt/znuny/ZnunyCodePolicy/Extensions/Internal',
        'Internal',
        1,                                                  # quiet, optional
    );

    Returns the created target path in list context.
    A missing scripts/test directory is logged as a warning.

=cut

sub _ReplaceLegacyTestDirectory {
    my ( $Log, $TargetDir, $Quiet ) = @_;

    return if !-d $TargetDir;
    return if -l $TargetDir;

    File::Find::finddepth(
        {
            wanted => sub {
                my $Path = $File::Find::name;
                if ( -l $Path ) {
                    unlink $Path;
                    return;
                }
                return if $Path eq $TargetDir;
                return if !-d $Path;
                rmdir $Path;
                return;
            },
            no_chdir => 1,
        },
        $TargetDir
    );

    if ( !rmdir $TargetDir ) {
        _Log( $Log, 'warning', "  WARNING: $TargetDir contains files that are not symbolic links. Skipping...\n" ) if !$Quiet;
    }
    return;
}

sub _LinkTests {
    my ( $Log, $RepoRoot, $ExtensionDir, $Name, $Quiet ) = @_;

    _Log( $Log, 'step', "5. Linking Test Directory for: $Name...\n" ) if !$Quiet;
    my $SourceDir = File::Spec->catdir( $ExtensionDir, 'scripts', 'test' );
    my $TargetDir = File::Spec->catdir( $RepoRoot, 'scripts', 'test', $Name );
    if ( !-d $SourceDir ) {
        _Log( $Log, 'warning', '  ⚠ No scripts/test directory found in extension' ) if !$Quiet;
        return;
    }

    _ReplaceLegacyTestDirectory( $Log, $TargetDir, $Quiet );
    my $Created = _CreateLink( $Log, $SourceDir, $TargetDir );
    return $Created if $Created;
    return;
}

=head2 _LinkDocumentation()

    Links the extension doc directory to doc/Name.

    TidyAll::Znuny::Extension::_LinkDocumentation(
        $Log,
        '/opt/znuny/ZnunyCodePolicy',
        '/opt/znuny/ZnunyCodePolicy/Extensions/Internal',
        'Internal',
    );

    Returns nothing. A missing doc directory is logged as a warning.

=cut

sub _LinkDocumentation {
    my ( $Log, $RepoRoot, $ExtensionDir, $Name, $Quiet ) = @_;

    _Log( $Log, 'step', "6. Linking Documentation Directory for: $Name...\n" ) if !$Quiet;
    my $SourceDir = File::Spec->catdir( $ExtensionDir, 'doc' );
    if ( !-d $SourceDir ) {
        _Log( $Log, 'warning', '  ⚠ No documentation directory found in extension' ) if !$Quiet;
        return;
    }

    my $Created = _CreateLink( $Log, $SourceDir, File::Spec->catdir( $RepoRoot, 'doc', $Name ) );
    return $Created if $Created;
    return;
}

=head2 _CreateLink()

    Creates a relative symlink.

    An existing symlink at the target is replaced.
    A real file or directory at the target is left in place.

    my $Success = TidyAll::Znuny::Extension::_CreateLink(
        $Log,
        '/opt/znuny/ZnunyCodePolicy/Extensions/Internal/Kernel/TidyAll/100-internal.tidyallrc',
        '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll/100-internal.tidyallrc',
    );

    Returns the target path when a new link was created.
    Returns nothing when the link already points at the source, or when the target is occupied.

=cut

sub _CreateLink {
    my ( $Log, $Source, $Target ) = @_;

    if ( _SamePath( $Source, $Target ) ) {
        return;
    }

    make_path( dirname($Target) );

    if ( -l $Target ) {
        unlink $Target || warn "Cannot remove existing link $Target: $!";
    }
    elsif ( -e $Target ) {
        _Log( $Log, 'warning', "  WARNING: $Target exists and is not a symbolic link. Skipping...\n" );
        return;
    }

    my $Relative = File::Spec->abs2rel( $Source, dirname($Target) );
    if ( !symlink $Relative, $Target ) {
        _Log( $Log, 'error', "Cannot create symbolic link $Target -> $Relative: $!\n" );
        return;
    }

    _Log( $Log, 'green', '  ✓ Linked: ' );
    _Log( $Log, 'info',  basename($Source) . " -> $Target\n" );
    return $Target;
}

=head2 _CreateDir()

    Creates a directory when it does not already exist.

    my $Success = TidyAll::Znuny::Extension::_CreateDir(
        $Log,
        '/opt/znuny/ZnunyCodePolicy/scripts/test/Internal',
        1,                                                  # verbose, optional
    );

    Dies when the directory cannot be created.
    Returns 1.

=cut

sub _CreateDir {
    my ( $Log, $Dir, $Verbose ) = @_;

    return 1 if -d $Dir;

    make_path($Dir) || die "Cannot create directory $Dir: $!";
    if ($Verbose) {
        _Log( $Log, 'green', "  ✓ Created directory: $Dir\n" );
    }
    return 1;
}

# ---- Internal: unlink ----

=head2 _RemoveName()

    Removes the links of one extension and appends the steps to the log.

    TidyAll configuration and pm links are removed when the target contains the extension name.
    Plugin subdirectories, test files and the documentation directory of that name are removed as well.

    TidyAll::Znuny::Extension::_RemoveName(
        $Log,
        '/opt/znuny/ZnunyCodePolicy',
        'Internal',
        1,                                                  # verbose, optional
    );

    Returns nothing.

=cut

sub _RemoveName {
    my ( $Log, $RepoRoot, $Name, $Verbose ) = @_;

    my $TidyAllDir = File::Spec->catdir( $RepoRoot, 'Kernel', 'TidyAll' );

    _Log( $Log, '',      "\n" );
    _Log( $Log, 'header', "=== Removing specific extension links ===" );
    _Log( $Log, '',      "\n" );

    _Log( $Log, 'step', "1. Removing TidyAll Configuration Files for: $Name...\n" );
    _RemoveExtensionFiles( $Log, $TidyAllDir, $Name, qr{\.tidyallrc\z}, 'TidyAll configuration' );
    _Log( $Log, '', "\n" );

    _Log( $Log, 'step', "2. Removing TidyAll PM Files for: $Name...\n" );
    _RemoveExtensionFiles( $Log, $TidyAllDir, $Name, qr{\.pm\z}, 'TidyAll PM file' );
    _Log( $Log, '', "\n" );

    _Log( $Log, 'step', "3. Removing Plugin Subdirectories for: $Name...\n" );
    my $SourcePluginDir = File::Spec->catdir( $RepoRoot, 'Extensions', $Name, 'Kernel', 'TidyAll', 'Plugin' );
    my $TargetPluginDir = File::Spec->catdir( $TidyAllDir, 'Plugin' );
    if ( -d $SourcePluginDir ) {
        PLUGIN:
        for my $Entry ( _ReadDir($SourcePluginDir) ) {
            my $Source = File::Spec->catdir( $SourcePluginDir, $Entry );
            next PLUGIN if !-d $Source;
            _RemoveLink( $Log, File::Spec->catdir( $TargetPluginDir, $Entry ), 'Plugin subdirectory', $Verbose );
        }
    }
    _Log( $Log, '', "\n" );

    _Log( $Log, 'step', "4. Removing Test Directory for: $Name...\n" );
    my $TestDir = File::Spec->catdir( $RepoRoot, 'scripts', 'test', $Name );
    if ( -l $TestDir ) {
        _RemoveLink( $Log, $TestDir, 'Test directory', $Verbose );
    }
    elsif ( -d $TestDir ) {
        File::Find::finddepth(
            {
                wanted => sub {
                    my $Path = $File::Find::name;
                    if ( -l $Path ) {
                        _RemoveLink( $Log, $Path, 'Test file', $Verbose );
                    }
                    elsif ( -d $Path && $Path ne $TestDir ) {
                        _RemoveEmptyDir( $Log, $Path );
                    }
                },
                no_chdir => 1,
            },
            $TestDir
        );
        _RemoveEmptyDir( $Log, $TestDir );
    }
    _Log( $Log, '', "\n" );

    _Log( $Log, 'step', "5. Removing Documentation Directory for: $Name...\n" );
    _RemoveLink( $Log, File::Spec->catdir( $RepoRoot, 'doc', $Name ), 'Documentation directory', $Verbose );
    return;
}

=head2 _RemoveAll()

    Removes every extension symlink and appends the steps to the log.

    TidyAll::Znuny::Extension::_RemoveAll(
        $Log,
        '/opt/znuny/ZnunyCodePolicy',
    );

    Returns nothing.

=cut

sub _RemoveAll {
    my ( $Log, $RepoRoot ) = @_;

    my $TidyAllDir = File::Spec->catdir( $RepoRoot, 'Kernel', 'TidyAll' );

    _Log( $Log, 'header', "=== Removing ALL extension links ===" );
    _Log( $Log, '',      "\n" );

    _Log( $Log, 'step', "1. Removing All .tidyallrc Symbolic Links...\n" );
    _RemoveAllLinks( $Log, $TidyAllDir, qr{\.tidyallrc\z}, 'TidyAll configuration' );
    _Log( $Log, '', "\n" );

    _Log( $Log, 'step', "2. Removing All TidyAll PM Links...\n" );
    _RemoveAllLinks( $Log, $TidyAllDir, qr{\.pm\z}, 'TidyAll PM file' );
    _Log( $Log, '', "\n" );

    _Log( $Log, 'step', "3. Removing All Plugin Directory Links...\n" );
    _RemoveAllDirectoryLinks( $Log, File::Spec->catdir( $TidyAllDir, 'Plugin' ), 'Plugin directory' );
    _Log( $Log, '', "\n" );

    _Log( $Log, 'step', "4. Removing All Test Directory Links...\n" );
    _RemoveAllDirectoryLinks( $Log, File::Spec->catdir( $RepoRoot, 'scripts', 'test' ), 'Test directory' );
    _Log( $Log, '', "\n" );

    _Log( $Log, 'step', "5. Removing All Documentation Directory Links...\n" );
    _RemoveAllDirectoryLinks( $Log, File::Spec->catdir( $RepoRoot, 'doc' ), 'Documentation directory' );
    return;
}

=head2 _RemoveExtensionFiles()

    Unlinks matching symlinks in one directory whose target contains the extension name.

    TidyAll::Znuny::Extension::_RemoveExtensionFiles(
        $Log,
        '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll',
        'Internal',
        qr{\.tidyallrc\z},
        'TidyAll configuration',
    );

    Returns nothing.

=cut

sub _RemoveExtensionFiles {
    my ( $Log, $Dir, $Name, $Pattern, $Description ) = @_;

    ENTRY:
    for my $Entry ( _ReadDir($Dir) ) {
        next ENTRY if $Entry !~ $Pattern;
        my $Path = File::Spec->catfile( $Dir, $Entry );
        next ENTRY if !-l $Path;
        next ENTRY if !_LinkPointsToExtension( $Path, $Name );
        _RemoveLink( $Log, $Path, $Description );
    }
    return;
}

=head2 _RemoveAllLinks()

    Unlinks every symlink in one directory whose name matches the pattern.

    TidyAll::Znuny::Extension::_RemoveAllLinks(
        $Log,
        '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll',
        qr{\.pm\z},
        'TidyAll PM file',
    );

    Returns nothing.

=cut

sub _RemoveAllLinks {
    my ( $Log, $Dir, $Pattern, $Description ) = @_;

    ENTRY:
    for my $Entry ( _ReadDir($Dir) ) {
        next ENTRY if $Entry !~ $Pattern;
        my $Path = File::Spec->catfile( $Dir, $Entry );
        next ENTRY if !-l $Path;
        _RemoveLink( $Log, $Path, $Description );
    }
    return;
}

=head2 _UnlinkMatches()

    Deletes symlinks in one directory whose names match the pattern.

    This function does not write a log entry.

    TidyAll::Znuny::Extension::_UnlinkMatches(
        '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll',
        qr{\.tidyallrc\z},
    );

    Returns nothing.

=cut

sub _UnlinkMatches {
    my ( $Dir, $Pattern ) = @_;

    ENTRY:
    for my $Entry ( _ReadDir($Dir) ) {
        next ENTRY if $Entry !~ $Pattern;
        my $Path = File::Spec->catfile( $Dir, $Entry );
        next ENTRY if !-l $Path;
        unlink $Path;
    }
    return;
}

=head2 _RemoveAllDirectoryLinks()

    Unlinks every directory symlink directly inside one directory.

    TidyAll::Znuny::Extension::_RemoveAllDirectoryLinks(
        $Log,
        '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll/Plugin',
        'Plugin directory',
    );

    Returns nothing.

=cut

sub _RemoveAllDirectoryLinks {
    my ( $Log, $Dir, $Description ) = @_;

    ENTRY:
    for my $Entry ( _ReadDir($Dir) ) {
        my $Path = File::Spec->catdir( $Dir, $Entry );
        next ENTRY if !-l $Path;
        _RemoveLink( $Log, $Path, $Description );
    }
    return;
}

=head2 _UnlinkDirectoryLinks()

    Deletes every directory symlink directly inside one directory.

    This function does not write a log entry.

    TidyAll::Znuny::Extension::_UnlinkDirectoryLinks(
        '/opt/znuny/ZnunyCodePolicy/doc',
    );

    Returns nothing.

=cut

sub _UnlinkDirectoryLinks {
    my ($Dir) = @_;

    ENTRY:
    for my $Entry ( _ReadDir($Dir) ) {
        my $Path = File::Spec->catdir( $Dir, $Entry );
        next ENTRY if !-l $Path;
        unlink $Path;
    }
    return;
}

=head2 _RemoveLink()

    Unlinks one symlink.

    A real file or directory is left in place.
    A missing path counts as success. Verbose logs that missing path.

    my $Success = TidyAll::Znuny::Extension::_RemoveLink(
        $Log,
        '/opt/znuny/ZnunyCodePolicy/doc/Internal',
        'Documentation directory',
        1,                                                  # verbose, optional
    );

    Returns 1 on success, 0 when the path cannot be removed or is not a symlink.

=cut

sub _RemoveLink {
    my ( $Log, $Target, $Description, $Verbose ) = @_;

    if ( -l $Target ) {
        if ( unlink $Target ) {
            _Log( $Log, 'green', '  ✓ Removed: ' );
            _Log( $Log, 'info',  "$Target ($Description)\n" );
            return 1;
        }
        _Log( $Log, 'error', "  Cannot remove $Target: $!\n" );
        return 0;
    }
    if ( -e $Target ) {
        _Log( $Log, 'warning', "  ⚠ WARNING: $Target exists but is not a symbolic link. Skipping for safety.\n" );
        return 0;
    }
    if ($Verbose) {
        _Log( $Log, 'cyan', "  ℹ Not found: $Target\n" );
    }
    return 1;
}

=head2 _RemoveEmptyDir()

    Removes an empty directory or a directory symlink.

    my $Success = TidyAll::Znuny::Extension::_RemoveEmptyDir(
        $Log,
        '/opt/znuny/ZnunyCodePolicy/scripts/test/Internal',
    );

    Returns 1 when the path was removed, 0 otherwise.

=cut

sub _RemoveEmptyDir {
    my ( $Log, $Dir ) = @_;

    if ( -l $Dir ) {
        if ( unlink $Dir ) {
            _Log( $Log, 'green', "  ✓ Removed directory link: $Dir\n" );
            return 1;
        }
        return 0;
    }
    if ( -d $Dir && !glob("$Dir/*") && !glob("$Dir/.*") ) {
        if ( rmdir $Dir ) {
            _Log( $Log, 'green', "  ✓ Removed empty directory: $Dir\n" );
            return 1;
        }
    }
    return 0;
}

=head2 _LinkPointsToExtension()

    Checks whether a symlink target contains the extension name.

    my $PointsToExtension = TidyAll::Znuny::Extension::_LinkPointsToExtension(
        '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll/100-internal.tidyallrc',
        'Internal',
    );

    Returns 1 or 0. A link that cannot be read returns 0.

=cut

sub _LinkPointsToExtension {
    my ( $LinkPath, $Name ) = @_;

    my $Target = readlink $LinkPath;
    return 0 if !defined $Target;
    return $Target =~ m{\Q$Name\E} ? 1 : 0;
}

# ---- Internal: status ----

=head2 _StatusLinks()

    Builds label and target pairs for symlinks in one directory.

    my @Links = TidyAll::Znuny::Extension::_StatusLinks(
        Dir     => '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll',
        Pattern => qr{\.tidyallrc\z},                       # optional
    );

    Each entry contains Label and Target. See _DisplayPath().

=cut

sub _StatusLinks {
    my (%Param) = @_;

    my @Links;
    ENTRY:
    for my $Entry ( _SymlinkNames( $Param{Dir}, $Param{Pattern} ) ) {
        my $Path = File::Spec->catfile( $Param{Dir}, $Entry );
        push @Links, {
            Label  => $Entry,
            Target => _DisplayPath( readlink $Path ),
            Broken => _BrokenLink($Path),
        };
    }
    return @Links;
}

=head2 _BrokenLink()

    Checks whether a symlink target is missing.

    my $Broken = TidyAll::Znuny::Extension::_BrokenLink(
        '/opt/znuny/ZnunyCodePolicy/doc/Internal',
    );

    Returns 1 when the path is not a symlink or the target does not exist, 0 otherwise.

=cut

sub _BrokenLink {
    my ($LinkPath) = @_;

    return 1 if !-l $LinkPath;

    my $Target = readlink $LinkPath;
    return 1 if !defined $Target;

    my $Absolute = File::Spec->rel2abs( $Target, dirname($LinkPath) );
    return !-e $Absolute ? 1 : 0;
}

=head2 _MissingLinks()

    Lists links and plugin files that an active extension still needs.

    A link is missing when the extension contains the file or directory and the repository symlink does not point at it.
    A plugin file is missing when a tidyallrc enables the class and the .pm file is not in the extension.
    That file has to be written at the reported path.

    my $Missing = TidyAll::Znuny::Extension::_MissingLinks('/opt/znuny/ZnunyCodePolicy');

    Returns a hash reference with Config, Module, Plugin, Test and Documentation.
    Each value is an array of Label and Reason.

=cut

sub _MissingLinks {
    my ($RepoRoot) = @_;

    my %Missing = (
        Config        => [],
        Module        => [],
        Plugin        => [],
        Test          => [],
        Documentation => [],
    );
    my %Seen;

    EXTENSION:
    for my $Name ( _ActiveExtensionNames($RepoRoot) ) {
        my $ExtensionRoot = File::Spec->catdir( $RepoRoot, 'Extensions', $Name );
        next EXTENSION if !-d $ExtensionRoot;

        my $TidyAllDir = File::Spec->catdir( $ExtensionRoot, 'Kernel', 'TidyAll' );

        SOURCE:
        for my $Source ( _MatchingFiles( $TidyAllDir, qr{\.tidyallrc\z} ) ) {
            my $Installed = _InstalledPath( $RepoRoot, $ExtensionRoot, $Source );
            _RememberMissing(
                Items  => $Missing{Config},
                Seen   => \%Seen,
                Label  => _RelPath( $RepoRoot, $Installed ),
                Reason => 'link is missing',
                Skip   => _SamePath( $Source, $Installed ),
            );
        }

        SOURCE:
        for my $Source ( _MatchingFiles( $TidyAllDir, qr{\.pm\z} ) ) {
            my $Installed = _InstalledPath( $RepoRoot, $ExtensionRoot, $Source );
            _RememberMissing(
                Items  => $Missing{Module},
                Seen   => \%Seen,
                Label  => _RelPath( $RepoRoot, $Installed ),
                Reason => 'link is missing',
                Skip   => _SamePath( $Source, $Installed ),
            );
        }

        my $SourcePlugin = File::Spec->catdir( $TidyAllDir, 'Plugin' );
        ENTRY:
        for my $Entry ( _ReadDir($SourcePlugin) ) {
            my $Source = File::Spec->catdir( $SourcePlugin, $Entry );
            next ENTRY if !-d $Source;

            my $Installed = File::Spec->catdir( $RepoRoot, 'Kernel', 'TidyAll', 'Plugin', $Entry );
            _RememberMissing(
                Items  => $Missing{Plugin},
                Seen   => \%Seen,
                Label  => "Plugin/$Entry",
                Reason => 'link is missing',
                Skip   => _SamePath( $Source, $Installed ),
            );
        }

        CONFIG:
        for my $Config ( _MatchingFiles( $TidyAllDir, qr{\.tidyallrc\z} ) ) {
            CLASS:
            for my $Class ( _EnabledPlugins($Config) ) {
                my $RelFile = $Class;
                $RelFile =~ s{::}{/}g;
                $RelFile .= '.pm';

                my $Source = File::Spec->catfile( $ExtensionRoot, 'Kernel', $RelFile );
                next CLASS if -f $Source;

                _RememberMissing(
                    Items  => $Missing{Plugin},
                    Seen   => \%Seen,
                    Label  => _RelPath( $RepoRoot, $Source ),
                    Reason => 'plugin file is missing in the extension',
                );
            }
        }

        my $SourceTests = File::Spec->catdir( $ExtensionRoot, 'scripts', 'test' );
        if ( -d $SourceTests ) {
            my $Installed = File::Spec->catdir( $RepoRoot, 'scripts', 'test', $Name );
            _RememberMissing(
                Items  => $Missing{Test},
                Seen   => \%Seen,
                Label  => "scripts/test/$Name",
                Reason => 'link is missing',
                Skip   => _SamePath( $SourceTests, $Installed ),
            );
        }

        my $SourceDoc = File::Spec->catdir( $ExtensionRoot, 'doc' );
        if ( -d $SourceDoc ) {
            my $Installed = File::Spec->catdir( $RepoRoot, 'doc', $Name );
            _RememberMissing(
                Items  => $Missing{Documentation},
                Seen   => \%Seen,
                Label  => "doc/$Name",
                Reason => 'link is missing',
                Skip   => _SamePath( $SourceDoc, $Installed ),
            );
        }
    }

    for my $Key ( keys %Missing ) {
        $Missing{$Key} = [ sort { $a->{Label} cmp $b->{Label} } @{ $Missing{$Key} } ];
    }

    return \%Missing;
}

=head2 _RememberMissing()

    Appends one missing status entry unless Skip is true or the label was already stored.

    TidyAll::Znuny::Extension::_RememberMissing(
        Items  => \@Items,
        Seen   => \%Seen,
        Label  => 'Plugin/Example',
        Reason => 'link is missing',
        Skip   => 0,                                        # optional
    );

    Returns nothing.

=cut

sub _RememberMissing {
    my (%Param) = @_;

    return if $Param{Skip};
    return if $Param{Seen}->{ $Param{Label} }++;

    push @{ $Param{Items} }, {
        Label  => $Param{Label},
        Reason => $Param{Reason},
    };
    return;
}

# ---- Internal: check ----

=head2 _ActiveExtensionNames()

    Collects extension names from symlink targets that contain C<Extensions/Name/>.

    The search covers Kernel/TidyAll, Kernel/TidyAll/Plugin, scripts/test and doc.

    my @Names = TidyAll::Znuny::Extension::_ActiveExtensionNames('/opt/znuny/ZnunyCodePolicy');

    Returns a sorted list of unique names.

=cut

sub _ActiveExtensionNames {
    my ($RepoRoot) = @_;

    my %Names;

    my $TidyAllDir = File::Spec->catdir( $RepoRoot, 'Kernel', 'TidyAll' );
    ENTRY:
    for my $Entry ( _ReadDir($TidyAllDir) ) {
        my $Path = File::Spec->catfile( $TidyAllDir, $Entry );
        next ENTRY if !-l $Path;
        my $Name = _NameFromLink($Path);
        next ENTRY if !$Name;
        $Names{$Name} = 1;
    }

    my $PluginDir = File::Spec->catdir( $TidyAllDir, 'Plugin' );
    PLUGIN_ENTRY:
    for my $Entry ( _ReadDir($PluginDir) ) {
        my $Path = File::Spec->catdir( $PluginDir, $Entry );
        next PLUGIN_ENTRY if !-l $Path;
        my $Name = _NameFromLink($Path);
        next PLUGIN_ENTRY if !$Name;
        $Names{$Name} = 1;
    }

    my $TestDir = File::Spec->catdir( $RepoRoot, 'scripts', 'test' );
    if ( -d $TestDir ) {
        File::Find::find(
            {
                wanted => sub {
                    return if !-l $File::Find::name;
                    my $Name = _NameFromLink($File::Find::name);
                    return if !$Name;
                    $Names{$Name} = 1;
                },
                no_chdir => 1,
            },
            $TestDir
        );
    }

    my $DocDir = File::Spec->catdir( $RepoRoot, 'doc' );
    DOC_ENTRY:
    for my $Entry ( _ReadDir($DocDir) ) {
        my $Path = File::Spec->catdir( $DocDir, $Entry );
        next DOC_ENTRY if !-l $Path;
        my $Name = _NameFromLink($Path);
        next DOC_ENTRY if !$Name;
        $Names{$Name} = 1;
    }

    return sort keys %Names;
}

=head2 _NameFromLink()

    Reads the extension name from a symlink target.

    The target must contain C<Extensions/Name/>.

    my $Name = TidyAll::Znuny::Extension::_NameFromLink(
        '/opt/znuny/ZnunyCodePolicy/doc/Internal',
    );

    Returns the name, or undef when the link has no extension name.

=cut

sub _NameFromLink {
    my ($LinkPath) = @_;

    my $Target = readlink $LinkPath;
    return if !defined $Target;

    my $Absolute = File::Spec->rel2abs( $Target, dirname($LinkPath) );
    if ( $Absolute =~ m{/Extensions/([^/]+)(?:/|\z)} ) {
        return $1;
    }
    if ( $Target =~ m{(?:^|/)Extensions/([^/]+)(?:/|\z)} ) {
        return $1;
    }
    return;
}

=head2 _CheckExtension()

    Checks one extension against the loaded tidyallrc map.

    The result lists config files, top-level modules, plugin files and enabled plugin classes.
    A missing extension directory is incomplete.

    my $Extension = TidyAll::Znuny::Extension::_CheckExtension(
        RepoRoot      => '/opt/znuny/ZnunyCodePolicy',
        ExtensionName => 'Internal',
        LoadedConfig  => {
            '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll/100-internal.tidyallrc' => 1,
        },
    );

    Returns a hash reference. See Check().

=cut

sub _CheckExtension {
    my (%Param) = @_;

    my $RepoRoot      = $Param{RepoRoot};
    my $ExtensionName = $Param{ExtensionName};
    my $LoadedConfig  = $Param{LoadedConfig};
    my $ExtensionRoot = File::Spec->catdir( $RepoRoot, 'Extensions', $ExtensionName );

    my %Result = (
        Name     => $ExtensionName,
        Missing  => [],
        Loaded   => [],
        Complete => 1,
    );

    if ( !-d $ExtensionRoot ) {
        _AddItem(
            Result => \%Result,
            Type   => 'directory',
            Path   => "Extensions/$ExtensionName",
            Loaded => 0,
            Reason => 'extension directory not found',
        );
        $Result{Complete} = 0;
        _SetCounts( \%Result );
        return \%Result;
    }

    my $TidyAllDir = File::Spec->catdir( $ExtensionRoot, 'Kernel', 'TidyAll' );
    my @Configs    = _MatchingFiles( $TidyAllDir, qr{\.tidyallrc\z} );
    my @Modules    = _MatchingFiles( $TidyAllDir, qr{\.pm\z} );

    CONFIG:
    for my $Source (@Configs) {
        my $Loaded = _ConfigIsLoaded( $Source, $LoadedConfig );
        _AddItem(
            Result => \%Result,
            Type   => 'config',
            Path   => _RelPath( $RepoRoot, _InstalledPath( $RepoRoot, $ExtensionRoot, $Source ) ),
            Loaded => $Loaded,
            Reason => $Loaded ? '' : 'tidyallrc was not included in the combined configuration',
        );
    }

    MODULE:
    for my $Source (@Modules) {
        my $Installed = _InstalledPath( $RepoRoot, $ExtensionRoot, $Source );
        my $Loaded    = _SamePath( $Source, $Installed );
        _AddItem(
            Result => \%Result,
            Type   => 'module',
            Path   => _RelPath( $RepoRoot, $Installed ),
            Loaded => $Loaded,
            Reason => $Loaded ? '' : 'module is not linked into Kernel/TidyAll',
        );
    }

    my $PluginDir   = File::Spec->catdir( $TidyAllDir, 'Plugin' );
    my @PluginFiles = _ListFiles($PluginDir);

    PLUGIN_FILE:
    for my $Source (@PluginFiles) {
        my $Installed = _InstalledPath( $RepoRoot, $ExtensionRoot, $Source );
        my $Loaded    = _SamePath( $Source, $Installed );
        _AddItem(
            Result => \%Result,
            Type   => 'plugin file',
            Path   => _RelPath( $RepoRoot, $Installed ),
            Loaded => $Loaded,
            Reason => $Loaded ? '' : 'plugin file is not reachable from Kernel/TidyAll/Plugin',
        );
    }

    my %ConfigLoadedByBase = _ConfigLoadedByBasename( \@Configs, $LoadedConfig );

    CONFIG_PLUGINS:
    for my $Source (@Configs) {
        my $ConfigName   = basename($Source);
        my $ConfigLoaded = $ConfigLoadedByBase{$ConfigName} ? 1 : 0;
        my @Plugins      = _EnabledPlugins($Source);

        PLUGIN:
        for my $Class (@Plugins) {
            my ( $Loaded, $Reason ) = _PluginLoaded(
                RepoRoot      => $RepoRoot,
                ExtensionRoot => $ExtensionRoot,
                Class         => $Class,
                ConfigName    => $ConfigName,
                ConfigLoaded  => $ConfigLoaded,
            );
            _AddItem(
                Result => \%Result,
                Type   => 'plugin',
                Path   => $Class,
                Loaded => $Loaded,
                Reason => $Reason,
            );
        }
    }

    $Result{Complete} = @{ $Result{Missing} } ? 0 : 1;
    $Result{Loaded}   = _SortItems( $Result{Loaded} );
    $Result{Missing}  = _SortItems( $Result{Missing} );
    _SetCounts( \%Result );

    return \%Result;
}

=head2 _LoadedConfigMap()

    Maps the real path of each loaded tidyallrc file to 1.

    my %LoadedConfig = TidyAll::Znuny::Extension::_LoadedConfigMap(
        [
            '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll/100-internal.tidyallrc',
        ],
    );

    Missing paths are skipped.

=cut

sub _LoadedConfigMap {
    my ($LoadedTidyAllrc) = @_;

    my %Loaded;
    PATH:
    for my $Path ( @{$LoadedTidyAllrc} ) {
        next PATH if !defined $Path || !-e $Path;
        my $Real = realpath($Path);
        next PATH if !$Real;
        $Loaded{$Real} = 1;
    }
    return %Loaded;
}

=head2 _ConfigIsLoaded()

    Checks whether the real path of a tidyallrc file is in the loaded map.

    my $Loaded = TidyAll::Znuny::Extension::_ConfigIsLoaded(
        '/opt/znuny/ZnunyCodePolicy/Extensions/Internal/Kernel/TidyAll/100-internal.tidyallrc',
        \%LoadedConfig,
    );

    Returns 1 or 0.

=cut

sub _ConfigIsLoaded {
    my ( $Source, $LoadedConfig ) = @_;

    my $Real = realpath($Source);
    return 0 if !$Real;
    return $LoadedConfig->{$Real} ? 1 : 0;
}

=head2 _ConfigLoadedByBasename()

    Maps the basename of each loaded tidyallrc file to 1.

    my %Loaded = TidyAll::Znuny::Extension::_ConfigLoadedByBasename(
        \@Configs,
        \%LoadedConfig,
    );

=cut

sub _ConfigLoadedByBasename {
    my ( $Configs, $LoadedConfig ) = @_;

    my %Loaded;
    CONFIG:
    for my $Source ( @{$Configs} ) {
        next CONFIG if !_ConfigIsLoaded( $Source, $LoadedConfig );
        $Loaded{ basename($Source) } = 1;
    }
    return %Loaded;
}

=head2 _EnabledPlugins()

    Reads the uncommented plugin classes from a tidyallrc file.

    A plugin line starts with C<[+Class]>.
    Lines that start with C<;> or C<#> are ignored.

    my @Classes = TidyAll::Znuny::Extension::_EnabledPlugins(
        '/opt/znuny/ZnunyCodePolicy/Extensions/Internal/Kernel/TidyAll/100-internal.tidyallrc',
    );

    Returns the classes in file order. Duplicate classes are skipped.

=cut

sub _EnabledPlugins {
    my ($File) = @_;

    my @Classes;
    my %Seen;

    my $FH;
    if ( !open $FH, '<', $File ) {
        return @Classes;
    }

    LINE:
    while ( my $Line = <$FH> ) {
        next LINE if $Line =~ m{\A\s*[;#]};
        next LINE if $Line !~ m{\A\s*\[\+\s*([A-Za-z0-9_:]+)};

        my $Class = $1;
        next LINE if $Seen{$Class};
        $Seen{$Class} = 1;
        push @Classes, $Class;
    }
    close $FH;

    return @Classes;
}

=head2 _PluginLoaded()

    Checks that one enabled plugin class is linked and loaded from the extension file.

    my ( $Loaded, $Reason ) = TidyAll::Znuny::Extension::_PluginLoaded(
        RepoRoot      => '/opt/znuny/ZnunyCodePolicy',
        ExtensionRoot => '/opt/znuny/ZnunyCodePolicy/Extensions/Internal',
        Class         => 'TidyAll::Plugin::Znuny::Internal::Example',
        ConfigName    => '100-internal.tidyallrc',
        ConfigLoaded  => 1,
    );

    Returns 1 and an empty reason when the class is loaded from the extension file.
    Returns 0 and a reason when the config, the link or the loaded path does not match.

=cut

sub _PluginLoaded {
    my (%Param) = @_;

    my $Class        = $Param{Class};
    my $ConfigName   = $Param{ConfigName};
    my $ConfigLoaded = $Param{ConfigLoaded};

    if ( !$ConfigLoaded ) {
        return 0, "config not loaded: $ConfigName";
    }

    my $RelFile = $Class;
    $RelFile =~ s{::}{/}g;
    $RelFile .= '.pm';

    my $Source = File::Spec->catfile( $Param{ExtensionRoot}, 'Kernel', $RelFile );
    if ( !-f $Source ) {
        my $Expected = _RelPath( $Param{RepoRoot}, $Source );
        return 0, "plugin file is missing in the extension: $Expected";
    }

    my $Installed = File::Spec->catfile( $Param{RepoRoot}, 'Kernel', $RelFile );
    if ( !_SamePath( $Source, $Installed ) ) {
        return 0, 'plugin file is not linked into Kernel/TidyAll/Plugin';
    }

    my ( $Required, $IncPath, $Error ) = _RequirePlugin(
        RepoRoot => $Param{RepoRoot},
        RelFile  => $RelFile,
        Source   => $Source,
    );
    if ( !$Required ) {
        return 0, $Error || 'could not load plugin module';
    }

    if ( !_SamePath( $Source, $IncPath ) ) {
        return 0, "loaded from $IncPath";
    }

    return 1, '';
}

=head2 _RequirePlugin()

    Loads a plugin through Kernel/ on C<@INC> when that file is not already loaded.

    A module already loaded from the same file is success.
    A module already loaded from another path is a failure.

    my ( $Required, $IncPath, $Error ) = TidyAll::Znuny::Extension::_RequirePlugin(
        RepoRoot => '/opt/znuny/ZnunyCodePolicy',
        RelFile  => 'TidyAll/Plugin/Znuny/Internal/Example.pm',
        Source   => '/opt/znuny/ZnunyCodePolicy/Extensions/Internal/Kernel/TidyAll/Plugin/Znuny/Internal/Example.pm',
    );

    Returns success, the include path, and an error string.
    The error is the first line of the exception.

=cut

sub _RequirePlugin {
    my (%Param) = @_;

    my $RelFile = $Param{RelFile};
    my $Source  = $Param{Source};
    my $IncPath = $INC{$RelFile};

    if ($IncPath) {
        if ( !File::Spec->file_name_is_absolute($IncPath) ) {
            $IncPath = File::Spec->rel2abs($IncPath);
        }
        if ( _SamePath( $Source, $IncPath ) ) {
            return 1, $IncPath, '';
        }
        return 0, $IncPath, "loaded from $IncPath";
    }

    local @INC = ( File::Spec->catdir( $Param{RepoRoot}, 'Kernel' ), @INC );

    my $Loaded = eval {
        require $RelFile;
        1;
    };
    my $Error = $@;

    if ( !$Loaded ) {
        return 0, undef, _OneLine($Error);
    }

    $IncPath = $INC{$RelFile};
    if ( !$IncPath ) {
        return 0, undef, 'plugin module did not register an include path';
    }

    if ( !File::Spec->file_name_is_absolute($IncPath) ) {
        $IncPath = File::Spec->rel2abs($IncPath);
    }

    return 1, $IncPath, '';
}

# ---- Internal: report ----

=head2 _AddItem()

    Appends one loaded or missing item to a check result.

    my $Loaded = TidyAll::Znuny::Extension::_AddItem(
        Result => \%Result,
        Type   => 'config',
        Path   => 'Kernel/TidyAll/100-internal.tidyallrc',
        Loaded => 1,
        Reason => '',                                       # stored only for a missing item
    );

    Returns 1 when the item is loaded, 0 when it is missing.

=cut

sub _AddItem {
    my (%Param) = @_;

    my $Result = $Param{Result};
    if ( $Param{Loaded} ) {
        push @{ $Result->{Loaded} }, {
            Type => $Param{Type},
            Path => $Param{Path},
        };
        return 1;
    }

    my %Missing = (
        Type => $Param{Type},
        Path => $Param{Path},
    );
    if ( $Param{Reason} ) {
        $Missing{Reason} = $Param{Reason};
    }
    push @{ $Result->{Missing} }, \%Missing;
    return 0;
}

=head2 _SetCounts()

    Stores loaded and total counts on a check result.

    The prefixes are Config, Module, PluginFile and Plugin.
    Each prefix gets a Loaded key and a Total key.

    TidyAll::Znuny::Extension::_SetCounts( \%Result );

    Returns 1.

=cut

sub _SetCounts {
    my ($Result) = @_;

    my @Types = (
        [ 'Config',     'config' ],
        [ 'Module',     'module' ],
        [ 'PluginFile', 'plugin file' ],
        [ 'Plugin',     'plugin' ],
    );

    TYPE:
    for my $Type (@Types) {
        my ( $Prefix, $Label ) = @{$Type};
        $Result->{ $Prefix . 'Loaded' } = _Count( $Result->{Loaded}, $Label );
        $Result->{ $Prefix . 'Total' }  = $Result->{ $Prefix . 'Loaded' } + _Count( $Result->{Missing}, $Label );
    }
    return 1;
}

=head2 _Count()

    Counts the items of one type.

    my $Count = TidyAll::Znuny::Extension::_Count(
        $Items,                                             # array reference, optional
        'plugin file',
    );

    Returns the number of matching items.

=cut

sub _Count {
    my ( $Items, $Type ) = @_;

    my $Count = 0;
    ITEM:
    for my $Item ( @{ $Items // [] } ) {
        next ITEM if $Item->{Type} ne $Type;
        $Count++;
    }
    return $Count;
}

=head2 _SortItems()

    Sorts check items by type, then by path.

    my $Sorted = TidyAll::Znuny::Extension::_SortItems($Items);

    Returns an array reference.

=cut

sub _SortItems {
    my ($Items) = @_;

    my @Sorted = sort {
        $a->{Type} cmp $b->{Type} || $a->{Path} cmp $b->{Path}
    } @{$Items};

    return \@Sorted;
}

=head2 _SummaryCounts()

    Builds the count text for one complete extension.

    Only types with a total above zero are included.

    my $Counts = TidyAll::Znuny::Extension::_SummaryCounts($Extension);

    Returns a string such as "config 1/1, plugins 8/8", or an empty string.

=cut

sub _SummaryCounts {
    my ($Extension) = @_;

    my @Parts;
    my @Pairs = (
        [ 'config',       'ConfigLoaded',     'ConfigTotal' ],
        [ 'modules',      'ModuleLoaded',     'ModuleTotal' ],
        [ 'plugin files', 'PluginFileLoaded', 'PluginFileTotal' ],
        [ 'plugins',      'PluginLoaded',     'PluginTotal' ],
    );

    PAIR:
    for my $Pair (@Pairs) {
        my ( $Label, $LoadedKey, $TotalKey ) = @{$Pair};
        my $Total = $Extension->{$TotalKey} // 0;
        next PAIR if !$Total;
        push @Parts, sprintf( '%s %d/%d', $Label, $Extension->{$LoadedKey} // 0, $Total );
    }

    return join ', ', @Parts;
}

=head2 _OneLine()

    Returns the first line of a string with surrounding whitespace removed.

    my $Line = TidyAll::Znuny::Extension::_OneLine($Error);

    Returns an empty string when the text is undefined.

=cut

sub _OneLine {
    my ($Text) = @_;

    return '' if !defined $Text;
    $Text =~ s{\A\s+}{};
    $Text =~ s{\s+\z}{};
    my ($FirstLine) = split m{\n}, $Text;
    return $FirstLine // '';
}

# ---- Internal: filesystem ----

=head2 _ReadDir()

    Returns the sorted names in one directory.

    C<.> and C<..> are omitted.

    my @Entries = TidyAll::Znuny::Extension::_ReadDir(
        '/opt/znuny/ZnunyCodePolicy/Extensions',
    );

    Returns an empty list when the directory cannot be read.

=cut

sub _ReadDir {
    my ($Dir) = @_;

    return if !defined $Dir || !-d $Dir;

    my $DH;
    if ( !opendir $DH, $Dir ) {
        return;
    }

    my @Entries;
    ENTRY:
    while ( my $Entry = readdir $DH ) {
        next ENTRY if $Entry eq '.' || $Entry eq '..';
        push @Entries, $Entry;
    }
    closedir $DH;

    return sort @Entries;
}

=head2 _SymlinkNames()

    Returns the sorted names of symlinks in one directory.

    my @Names = TidyAll::Znuny::Extension::_SymlinkNames(
        '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll',
        qr{\.pm\z},                                         # optional
    );

    Returns an empty list when the directory cannot be read.

=cut

sub _SymlinkNames {
    my ( $Dir, $Pattern ) = @_;

    my @Names;
    ENTRY:
    for my $Entry ( _ReadDir($Dir) ) {
        next ENTRY if defined $Pattern && $Entry !~ $Pattern;
        my $Path = File::Spec->catfile( $Dir, $Entry );
        next ENTRY if !-l $Path;
        push @Names, $Entry;
    }
    return @Names;
}

=head2 _MatchingFiles()

    Lists the files directly inside one directory whose names match the pattern.

    my @Files = TidyAll::Znuny::Extension::_MatchingFiles(
        '/opt/znuny/ZnunyCodePolicy/Extensions/Internal/Kernel/TidyAll',
        qr{\.tidyallrc\z},
    );

    Returns sorted paths.

=cut

sub _MatchingFiles {
    my ( $Dir, $Pattern ) = @_;

    my @Files;
    ENTRY:
    for my $Entry ( _ReadDir($Dir) ) {
        next ENTRY if $Entry !~ $Pattern;
        my $Path = File::Spec->catfile( $Dir, $Entry );
        next ENTRY if !-f $Path;
        push @Files, $Path;
    }
    return sort @Files;
}

=head2 _ListFiles()

    Lists every file under one directory, including subdirectories.

    my @Files = TidyAll::Znuny::Extension::_ListFiles(
        '/opt/znuny/ZnunyCodePolicy/Extensions/Internal/Kernel/TidyAll/Plugin',
    );

    Returns sorted paths. The list is empty when the directory does not exist.

=cut

sub _ListFiles {
    my ($Dir) = @_;

    return if !-d $Dir;

    my @Files;
    File::Find::find(
        {
            wanted => sub {
                return if !-f $File::Find::name;
                push @Files, $File::Find::name;
            },
            no_chdir => 1,
        },
        $Dir
    );
    return sort @Files;
}

=head2 _InstalledPath()

    Maps a file inside C<Extensions/Name/> to the same relative path under the repository root.

    my $Installed = TidyAll::Znuny::Extension::_InstalledPath(
        '/opt/znuny/ZnunyCodePolicy',
        '/opt/znuny/ZnunyCodePolicy/Extensions/Internal',
        '/opt/znuny/ZnunyCodePolicy/Extensions/Internal/Kernel/TidyAll/100-internal.tidyallrc',
    );

    Returns the path under the repository root.

=cut

sub _InstalledPath {
    my ( $RepoRoot, $ExtensionRoot, $Source ) = @_;

    my $Relative = File::Spec->abs2rel( $Source, $ExtensionRoot );
    return File::Spec->catfile( $RepoRoot, $Relative );
}

=head2 _RelPath()

    Returns a path relative to the repository root.

    my $Relative = TidyAll::Znuny::Extension::_RelPath(
        '/opt/znuny/ZnunyCodePolicy',
        '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll/100-internal.tidyallrc',
    );

=cut

sub _RelPath {
    my ( $RepoRoot, $Path ) = @_;

    return File::Spec->abs2rel( $Path, $RepoRoot );
}

=head2 _SamePath()

    Compares two paths by their real path.

    my $SamePath = TidyAll::Znuny::Extension::_SamePath(
        '/opt/znuny/ZnunyCodePolicy/Extensions/Internal/Kernel/TidyAll/Plugin/Znuny',
        '/opt/znuny/ZnunyCodePolicy/Kernel/TidyAll/Plugin/Znuny',
    );

    Returns 1 when both paths exist and point to the same file.
    Returns 0 when either path is missing or the real paths differ.

=cut

sub _SamePath {
    my ( $Left, $Right ) = @_;

    return 0 if !defined $Left || !defined $Right;
    return 0 if !-e $Left      || !-e $Right;

    my $LeftReal  = realpath($Left);
    my $RightReal = realpath($Right);
    return 0 if !defined $LeftReal || !defined $RightReal;
    return $LeftReal eq $RightReal ? 1 : 0;
}

=head2 _DisplayPath()

    Removes a leading C<../> sequence from a symlink target.

    my $Path = TidyAll::Znuny::Extension::_DisplayPath('../Extensions/Internal/doc');

    Returns an empty string when the path is undefined.

=cut

sub _DisplayPath {
    my ($Path) = @_;

    return '' if !defined $Path;
    $Path =~ s{\A(?:\.\./)+}{};
    return $Path;
}

# ---- Internal: log ----

=head2 _Log()

    Appends one colored text chunk to a log array.

    TidyAll::Znuny::Extension::_Log(
        $Log,
        'green',                                            # empty string leaves the text uncolored
        "  linked\n",
    );

    Returns nothing.

=cut

sub _Log {
    my ( $Log, $Color, $Text ) = @_;

    push @{$Log}, {
        Color => $Color,
        Text  => $Text,
    };
    return;
}
1;
