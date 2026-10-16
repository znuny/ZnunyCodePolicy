# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## no critic (RequireExplicitPackage)

use strict;
use warnings;

use vars qw($Self);
use utf8;

use File::Basename qw(dirname);
use FindBin        qw($RealBin);
use lib (
    dirname($RealBin) . '/Kernel',
    dirname($RealBin) . '/../../../Kernel',
);
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);
use Path::Tiny qw(path);

use TidyAll::Znuny::Extension;

my $PluginCode = <<'EOF';
package TidyAll::Plugin::Example::README::Check;

use strict;
use warnings;

sub Validate {
    return 1;
}

1;
EOF

my $BrokenPluginCode = <<'EOF';
package TidyAll::Plugin::Example::README::Broken;

use strict;
use warnings;

sub Validate {
    return 1;
}

this is not valid perl
EOF

my $ModuleCode = <<'EOF';
package TidyAll::Example;

use strict;
use warnings;

1;
EOF

sub WriteFile {
    my ( $Path, $Content ) = @_;

    my $File = path($Path);
    $File->parent()->mkpath();
    $File->spew($Content);
    return 1;
}

sub _StatusMissing {
    my ( $Status, $Title ) = @_;

    GROUP:
    for my $Group ( @{ $Status->{Groups} // [] } ) {
        return $Group->{Missing} // [] if $Group->{Title} eq $Title;
    }
    return [];
}

sub LinkFile {
    my ( $Source, $Target ) = @_;

    make_path( dirname($Target) );
    if ( -l $Target || -e $Target ) {
        unlink $Target || die "Cannot remove $Target: $!";
    }
    symlink( $Source, $Target ) || die "Cannot link $Target: $!";
    return 1;
}

sub BuildExtension {
    my (%Param) = @_;

    my $RepoRoot = $Param{RepoRoot};
    my $Name     = $Param{Name};
    my $Root     = File::Spec->catdir( $RepoRoot, 'Extensions', $Name );
    my $TidyAll  = File::Spec->catdir( $Root,     'Kernel',     'TidyAll' );

    my $Config = "[+TidyAll::Plugin::Example::README::Check]\nselect = README.md\n\n"
        . "; [+TidyAll::Plugin::Example::README::Disabled]\n; select = README.md\n";
    if ( $Param{BrokenPlugin} ) {
        $Config = "[+TidyAll::Plugin::Example::README::Broken]\nselect = README.md\n";
    }
    if ( $Param{MissingPluginFile} ) {
        $Config .= "\n[+TidyAll::Plugin::Example::README::Missing]\nselect = README.md\n";
    }
    WriteFile( File::Spec->catfile( $TidyAll, '100-example.tidyallrc' ),                       $Config );
    WriteFile( File::Spec->catfile( $TidyAll, 'Example.pm' ),                                  $ModuleCode );
    WriteFile( File::Spec->catfile( $TidyAll, 'Plugin', 'Example', 'README', 'Check.pm' ),     $PluginCode );
    WriteFile( File::Spec->catfile( $TidyAll, 'Plugin', 'Example', 'README', 'Disabled.pm' ),  $PluginCode );
    WriteFile( File::Spec->catfile( $TidyAll, 'Plugin', 'Example', 'README', 'template.yml' ), "name: example\n" );
    WriteFile( File::Spec->catfile( $Root, 'doc', 'en', 'feature.md' ),                        "doc\n" );

    if ( $Param{BrokenPlugin} ) {
        WriteFile( File::Spec->catfile( $TidyAll, 'Plugin', 'Example', 'README', 'Broken.pm' ), $BrokenPluginCode );
    }

    return $Root;
}

sub LinkExtension {
    my (%Param) = @_;

    my $RepoRoot = $Param{RepoRoot};
    my $Name     = $Param{Name};
    my $Root     = File::Spec->catdir( $RepoRoot, 'Extensions', $Name );

    if ( $Param{LinkConfig} ) {
        LinkFile(
            File::Spec->catfile( $Root,     'Kernel', 'TidyAll', '100-example.tidyallrc' ),
            File::Spec->catfile( $RepoRoot, 'Kernel', 'TidyAll', '100-example.tidyallrc' ),
        );
    }
    if ( $Param{LinkModule} ) {
        LinkFile(
            File::Spec->catfile( $Root,     'Kernel', 'TidyAll', 'Example.pm' ),
            File::Spec->catfile( $RepoRoot, 'Kernel', 'TidyAll', 'Example.pm' ),
        );
    }
    if ( $Param{LinkPlugins} ) {
        LinkFile(
            File::Spec->catdir( $Root,     'Kernel', 'TidyAll', 'Plugin', 'Example' ),
            File::Spec->catdir( $RepoRoot, 'Kernel', 'TidyAll', 'Plugin', 'Example' ),
        );
    }
    if ( $Param{LinkDoc} ) {
        LinkFile(
            File::Spec->catdir( $Root,     'doc' ),
            File::Spec->catdir( $RepoRoot, 'doc', $Name ),
        );
    }
    return 1;
}

my $EmptyRoot = tempdir( CLEANUP => 1 );
WriteFile( File::Spec->catfile( $EmptyRoot, 'Kernel', 'TidyAll', 'custom.tidyallrc' ), "select = README.md\n" );

my $EmptyReport = TidyAll::Znuny::Extension::Check(
    RepoRoot        => $EmptyRoot,
    LoadedTidyAllrc => [],
);
$Self->True(
    $EmptyReport->{Complete},
    'No symlinks into Extensions means no active extension.',
);
$Self->Is(
    scalar @{ $EmptyReport->{Extensions} },
    0,
    'Local tidyallrc is not an active extension.',
);

my $CompleteRoot = tempdir( CLEANUP => 1 );
BuildExtension(
    RepoRoot => $CompleteRoot,
    Name     => 'Example',
);
LinkExtension(
    RepoRoot    => $CompleteRoot,
    Name        => 'Example',
    LinkConfig  => 1,
    LinkModule  => 1,
    LinkPlugins => 1,
    LinkDoc     => 1,
);
my $ConfigLink     = File::Spec->catfile( $CompleteRoot, 'Kernel', 'TidyAll', '100-example.tidyallrc' );
my $CompleteReport = TidyAll::Znuny::Extension::Check(
    RepoRoot        => $CompleteRoot,
    LoadedTidyAllrc => [$ConfigLink],
);
$Self->True(
    $CompleteReport->{Complete},
    'Linked extension with loaded tidyallrc is complete.',
);
$Self->Is(
    $CompleteReport->{Extensions}[0]{Name},
    'Example',
    'Active extension name comes from the symlink target.',
);
$Self->Is(
    $CompleteReport->{Extensions}[0]{ConfigLoaded},
    1,
    'Extension tidyallrc was loaded.',
);
$Self->Is(
    $CompleteReport->{Extensions}[0]{ModuleLoaded},
    1,
    'Extension TidyAll module was linked.',
);
$Self->Is(
    $CompleteReport->{Extensions}[0]{PluginFileTotal},
    3,
    'Plugin directory files are part of the load check.',
);
$Self->Is(
    $CompleteReport->{Extensions}[0]{PluginTotal},
    1,
    'Commented plugin classes are not required to load.',
);

my $CompleteText = TidyAll::Znuny::Extension::FormatReport(
    Report  => $CompleteReport,
    Verbose => 1,
);
$Self->True(
    $CompleteText =~ m{Extensions:\s+Example \(config 1/1},
    'Report names a complete extension.',
);
$Self->True(
    $CompleteText =~ m{TidyAll::Plugin::Example::README::Check},
    'Verbose report lists the loaded plugin class.',
);

my $PartialRoot = tempdir( CLEANUP => 1 );
BuildExtension(
    RepoRoot => $PartialRoot,
    Name     => 'Example',
);
LinkExtension(
    RepoRoot    => $PartialRoot,
    Name        => 'Example',
    LinkPlugins => 1,
);
my $PartialReport = TidyAll::Znuny::Extension::Check(
    RepoRoot        => $PartialRoot,
    LoadedTidyAllrc => [],
);
$Self->False(
    $PartialReport->{Complete},
    'Active extension without its tidyallrc is incomplete.',
);
my $PartialText = TidyAll::Znuny::Extension::FormatReport( Report => $PartialReport );
$Self->True(
    $PartialText =~ m{missing config:},
    'Report names the tidyallrc that was not loaded.',
);
$Self->True(
    $PartialText =~ m{config not loaded: 100-example\.tidyallrc},
    'Enabled plugins stay unloaded when their tidyallrc was not included.',
);

my $BrokenRoot = tempdir( CLEANUP => 1 );
BuildExtension(
    RepoRoot     => $BrokenRoot,
    Name         => 'Example',
    BrokenPlugin => 1,
);
LinkExtension(
    RepoRoot    => $BrokenRoot,
    Name        => 'Example',
    LinkConfig  => 1,
    LinkModule  => 1,
    LinkPlugins => 1,
);
my $BrokenLink   = File::Spec->catfile( $BrokenRoot, 'Kernel', 'TidyAll', '100-example.tidyallrc' );
my $BrokenReport = TidyAll::Znuny::Extension::Check(
    RepoRoot        => $BrokenRoot,
    LoadedTidyAllrc => [$BrokenLink],
);
$Self->False(
    $BrokenReport->{Complete},
    'Enabled plugin that cannot be loaded makes the extension incomplete.',
);
my $BrokenText = TidyAll::Znuny::Extension::FormatReport( Report => $BrokenReport );
$Self->True(
    $BrokenText =~ m{missing plugin: TidyAll::Plugin::Example::README::Broken},
    'Report names the plugin class that failed to load.',
);

my $GapRoot = tempdir( CLEANUP => 1 );
BuildExtension(
    RepoRoot          => $GapRoot,
    Name              => 'Example',
    MissingPluginFile => 1,
);
LinkExtension(
    RepoRoot    => $GapRoot,
    Name        => 'Example',
    LinkConfig  => 1,
    LinkPlugins => 1,
    LinkDoc     => 1,
);
my $GapLink   = File::Spec->catfile( $GapRoot, 'Kernel', 'TidyAll', '100-example.tidyallrc' );
my $GapReport = TidyAll::Znuny::Extension::Check(
    RepoRoot        => $GapRoot,
    LoadedTidyAllrc => [$GapLink],
);
my $GapText = TidyAll::Znuny::Extension::FormatReport( Report => $GapReport );
$Self->True(
    index(
        $GapText,
        'plugin file is missing in the extension: Extensions/Example/Kernel/TidyAll/Plugin/Example/README/Missing.pm'
        )
        >= 0,
    'Report names the plugin file that has to be written.',
);

my $GapStatus = TidyAll::Znuny::Extension::Status( RepoRoot => $GapRoot );
$Self->True(
    $GapStatus->{Incomplete},
    'Status reports an incomplete extension.',
);

my $ModuleLinkMissing = 0;
MODULE:
for my $Item ( @{ _StatusMissing( $GapStatus, 'TidyAll PM Files (.pm)' ) } ) {
    if ( $Item->{Label} eq 'Kernel/TidyAll/Example.pm' && $Item->{Reason} eq 'link is missing' ) {
        $ModuleLinkMissing = 1;
    }
}
$Self->True(
    $ModuleLinkMissing,
    'Status shows a module link that is missing.',
);

my $PluginFileMissing = 0;
PLUGIN:
for my $Item ( @{ _StatusMissing( $GapStatus, 'Plugin Directories' ) } ) {
    if (
        $Item->{Label} eq 'Extensions/Example/Kernel/TidyAll/Plugin/Example/README/Missing.pm'
        && $Item->{Reason} eq 'plugin file is missing in the extension'
        )
    {
        $PluginFileMissing = 1;
    }
}
$Self->True(
    $PluginFileMissing,
    'Status shows the plugin file that has to be written.',
);

my $MissingDirRoot = tempdir( CLEANUP => 1 );
LinkFile(
    File::Spec->catdir( $MissingDirRoot, 'Extensions', 'Gone', 'doc' ),
    File::Spec->catdir( $MissingDirRoot, 'doc', 'Gone' ),
);
my $MissingDirReport = TidyAll::Znuny::Extension::Check(
    RepoRoot        => $MissingDirRoot,
    LoadedTidyAllrc => [],
);
$Self->False(
    $MissingDirReport->{Complete},
    'Dangling extension link is incomplete.',
);
$Self->Is(
    $MissingDirReport->{Extensions}[0]{Name},
    'Gone',
    'Dangling link still identifies the extension name.',
);

my $RoundtripRoot = tempdir( CLEANUP => 1 );
BuildExtension(
    RepoRoot => $RoundtripRoot,
    Name     => 'Example',
);
my $Added = TidyAll::Znuny::Extension::Add(
    RepoRoot => $RoundtripRoot,
    Name     => 'Example',
);
$Self->True(
    scalar @{ $Added->{Log} },
    'Add records the created links.',
);
my $RoundtripSummary = TidyAll::Znuny::Extension::LinkSummary(
    RepoRoot => $RoundtripRoot,
    Name     => 'Example',
);
$Self->Is(
    $RoundtripSummary->{Config},
    1,
    'Add links the extension tidyallrc.',
);
$Self->Is(
    $RoundtripSummary->{Module},
    1,
    'Add links the extension module.',
);
$Self->True(
    -f File::Spec->catfile( $RoundtripRoot, 'Kernel', 'TidyAll', 'Plugin', 'Example', 'README', 'Check.pm' ),
    'Add makes plugin files reachable.',
);
my $RoundtripStatus = TidyAll::Znuny::Extension::Status( RepoRoot => $RoundtripRoot );
$Self->True(
    $RoundtripStatus->{Active},
    'Status sees the links created by Add.',
);
$Self->False(
    $RoundtripStatus->{Incomplete},
    'Status reports no missing link after Add.',
);

my $LiveRoot = tempdir( CLEANUP => 1 );
BuildExtension(
    RepoRoot => $LiveRoot,
    Name     => 'Example',
);
WriteFile(
    File::Spec->catfile( $LiveRoot, 'Extensions', 'Example', 'scripts', 'test', 'Sample.t' ),
    "1;\n",
);
TidyAll::Znuny::Extension::Add(
    RepoRoot => $LiveRoot,
    Name     => 'Example',
);
my $TestLink = File::Spec->catdir( $LiveRoot, 'scripts', 'test', 'Example' );
$Self->True(
    -l $TestLink,
    'Tests are one directory symlink.',
);
$Self->True(
    -f File::Spec->catfile( $TestLink, 'Sample.t' ),
    'Existing test is visible through the directory symlink.',
);
WriteFile(
    File::Spec->catfile( $LiveRoot, 'Extensions', 'Example', 'scripts', 'test', 'Second.t' ),
    "1;\n",
);
$Self->True(
    -f File::Spec->catfile( $TestLink, 'Second.t' ),
    'A new test file is visible without another add.',
);

my $LiveConfig = File::Spec->catfile( $LiveRoot, 'Kernel', 'TidyAll', '100-example.tidyallrc' );
unlink $LiveConfig || die "Cannot remove $LiveConfig: $!";
my $Synced = TidyAll::Znuny::Extension::Sync( RepoRoot => $LiveRoot );
$Self->True(
    -l $LiveConfig,
    'Sync restores a missing tidyallrc link.',
);
$Self->True(
    $Synced->{Created},
    'Sync reports the created link.',
);
$Self->True(
    -l File::Spec->catfile( $LiveRoot, 'Kernel', 'TidyAll', 'Example.pm' ),
    'Sync leaves an existing module link in place.',
);
TidyAll::Znuny::Extension::Remove(
    RepoRoot => $RoundtripRoot,
    Name     => 'Example',
);
my $RemovedReport = TidyAll::Znuny::Extension::Check(
    RepoRoot        => $RoundtripRoot,
    LoadedTidyAllrc => [],
);
$Self->True(
    $RemovedReport->{Complete},
    'Remove clears the active extension.',
);
$Self->Is(
    scalar @{ $RemovedReport->{Extensions} },
    0,
    'No extension stays active after Remove.',
);

my $CombineRoot = tempdir( CLEANUP => 1 );
my $CombineDir  = File::Spec->catdir( $CombineRoot, 'Kernel', 'TidyAll' );
WriteFile(
    File::Spec->catfile( $CombineDir, 'tidyallrc' ),
    "[+TidyAll::Plugin::Znuny::Common::Origin]\nselect = **/*.{pl,pm}\n",
);
WriteFile(
    File::Spec->catfile( $CombineDir, 'custom.tidyallrc' ),
    "[+TidyAll::Plugin::Custom::Example]\nselect = Custom/**/*.pm\n",
);

opendir( my $CombineDH, $CombineDir ) || die "Cannot open directory $CombineDir: $!";
my @CombineNames = grep { /\.tidyallrc$/ && -f File::Spec->catfile( $CombineDir, $_ ) } readdir $CombineDH;
closedir $CombineDH;
@CombineNames = sort @CombineNames;

my @CombineFiles;
COMBINE_FILE:
for my $FileName (@CombineNames) {
    next COMBINE_FILE if $FileName eq 'tidyallrc';
    my $FilePath = File::Spec->catfile( $CombineDir, $FileName );
    next COMBINE_FILE if !-f $FilePath || !-r $FilePath;
    push @CombineFiles, $FilePath;
}

$Self->Is(
    scalar @CombineFiles,
    1,
    'Should find exactly one extensions tidyallrc file.',
);
$Self->True(
    ( $CombineFiles[0] // '' ) =~ m{custom\.tidyallrc\z} ? 1 : 0,
    'Found file should be custom.tidyallrc.',
);

my $CombinedContent = path( $CombineFiles[0] )->slurp();
$CombinedContent = path( File::Spec->catfile( $CombineDir, 'tidyallrc' ) )->slurp()
    . "\n; ==== Extensions configuration from: custom.tidyallrc ====\n"
    . $CombinedContent;

$Self->True(
    index( $CombinedContent, 'TidyAll::Plugin::Znuny::Common::Origin' ) >= 0 ? 1 : 0,
    'Should contain main configuration.',
);
$Self->True(
    index( $CombinedContent, 'TidyAll::Plugin::Custom::Example' ) >= 0 ? 1 : 0,
    'Should contain extension configuration.',
);
$Self->True(
    index( $CombinedContent, 'Extensions configuration from: custom.tidyallrc' ) >= 0 ? 1 : 0,
    'Should contain separator comment.',
);

1;
