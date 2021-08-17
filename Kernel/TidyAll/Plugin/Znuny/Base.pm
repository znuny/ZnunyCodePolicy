# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
# ---
# ZnunyCodePolicy
# ---
## nofilter(TidyAll::Plugin::OTRS::Common::Origin)
## nofilter(TidyAll::Plugin::OTRS::Perl::Time)
# ---
package TidyAll::Plugin::Znuny::Base;

use strict;
use warnings;

use Encode();
use TidyAll::Znuny;

# ---
# ZnunyCodePolicy
# ---
use Term::ANSIColor();
use Path::Tiny;

# ---

use parent qw(Code::TidyAll::Plugin);

sub IsPluginDisabled {
    my ( $Self, %Param ) = @_;

    my $PluginPackage = ref $Self;

    if ( !defined $Param{Code} && !defined $Param{Filename} ) {

# ---
        # ZnunyCodePolicy
# ---
        #         print STDERR "Need Code or Filename!\n";
        print STDERR "Need code or filename in plugin package $PluginPackage!\n";

# ---
        die;
    }

    my $Code = defined $Param{Code} ? $Param{Code} : $Self->_GetFileContents( $Param{Filename} );

    if ( $Code =~ m{nofilter\([^()]*\Q$PluginPackage\E[^()]*\)}ismx ) {
        return 1;
    }

    return;
}

sub IsFrameworkVersionLessThan {
    my ( $Self, $FrameworkVersionMajor, $FrameworkVersionMinor ) = @_;

    if ($TidyAll::Znuny::FrameworkVersionMajor) {
        return 1 if $TidyAll::Znuny::FrameworkVersionMajor < $FrameworkVersionMajor;
        return 0 if $TidyAll::Znuny::FrameworkVersionMajor > $FrameworkVersionMajor;
        return 1 if $TidyAll::Znuny::FrameworkVersionMinor < $FrameworkVersionMinor;
        return 0;
    }

    # Default: if framework is unknown, return false (strict checks).
    return 0;
}

# ---
# ZnunyCodePolicy
# ---
sub IsFrameworkVersionGreaterThan {
    my ( $Self, $FrameworkVersionMajor, $FrameworkVersionMinor ) = @_;

    if ($TidyAll::OTRS::FrameworkVersionMajor) {
        return 1 if $TidyAll::OTRS::FrameworkVersionMajor > $FrameworkVersionMajor;
        return 0 if $TidyAll::OTRS::FrameworkVersionMajor < $FrameworkVersionMajor;
        return 1 if $TidyAll::OTRS::FrameworkVersionMinor > $FrameworkVersionMinor;
        return 0;
    }

    # Default: if framework is unknown, return false (strict checks).
    return 0;
}

# ---

sub IsThirdpartyModule {
    my ($Self) = @_;

    return $TidyAll::Znuny::ThirdpartyModule ? 1 : 0;
}

sub DieWithError {
    my ( $Self, $Error ) = @_;

    chomp $Error;

# ---
# ZnunyCodePolicy
# ---
    #     die _Color( 'yellow', ref($Self) ) . "\n" . _Color( 'red', $Error ) . "\n";
    die $Self->_Color( 'yellow', ref($Self) ) . "\n" . $Self->_Color( 'red', $Error ) . "\n";

# ---
}

=head2 _Color()

This will color the given text (see Term::ANSIColor::color()) if ANSI output is available and active, otherwise the text
stays unchanged.

    my $PossiblyColoredText = $Object->_Color('green', $Text);

=cut

sub _Color {

# ---
# ZnunyCodePolicy
# ---
    #     my ( $Color, $Text ) = @_;
    my ( $Self, $Color, $Text ) = @_;

# ---

    return $Text if $ENV{OTRSCODEPOLICY_NOCOLOR};

    return Term::ANSIColor::color($Color) . $Text . Term::ANSIColor::color('reset');
}

sub _GetFileContents {
    my ( $Self, $Filename ) = @_;

    my $FileHandle;
    if ( !open $FileHandle, '<', $Filename ) {    ## no critic
        print STDERR "Can't open $Filename\n";
        die;
    }

    my $Content = do { local $/ = undef; <$FileHandle> };
    close $FileHandle;

    return $Content;
}

# ---
# ZnunyCodePolicy
# ---

sub GetOTRSRootDir {
    my ($Self) = @_;
    return $TidyAll::Znuny::OTRSRootDir;
}

sub GetScope {
    my ($Self) = @_;
    return $TidyAll::Znuny::Scope || '';
}

sub GetPackageName {
    my ($Self) = @_;
    return $TidyAll::Znuny::PackageName // '';
}

sub GetCondensedPackageName {
    my ($Self) = @_;

    my $PackageName          = $Self->GetPackageName();
    my $CondensedPackageName = $PackageName // '';
    return $CondensedPackageName if !$CondensedPackageName;

    $CondensedPackageName =~ s{-}{}g;
    return $CondensedPackageName;
}

sub IsFileInCustomDirectory {
    my ( $Self, $Filename ) = @_;

    my $IsFileInCustomDirectory = ( index( $Filename, 'Custom/' ) == -1 ? 0 : 1 );
    return $IsFileInCustomDirectory;
}

sub IsCustomizedOTRSCode {
    my ( $Self, $Code ) = @_;

    if (
        $Code =~ m{Copyright \(C\) 2001-20\d{2} OTRS AG}sm
        && $Code =~ m{\$origin:}sm
        )
    {
        return 1;
    }

    return;
}

sub IsOriginalOTRSCode {
    my ( $Self, $Code ) = @_;

    return 1 if $Code =~ m{Copyright \(C\) 2001-20\d{2} OTRS AG}sm;

    return;
}

sub IsOriginalZnunyCode {
    my ( $Self, $Code ) = @_;

    return if $Self->IsOriginalOTRSCode($Code);
    return if $Self->IsThirdpartyModule();

    return 1 if $Code =~ m{Copyright \(C\) 2021(-20\d{2})? Znuny GmbH}sm;

    return;
}

sub GetZnunyCopyrightString {
    my $CopyrightYear = '2021';    # start year of Znuny fork

    my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = localtime( time() );
    $Year += 1900;
    if ( $Year > 2021 ) {
        $CopyrightYear .= "-$Year";
    }

    my $Copyright = "Copyright (C) $CopyrightYear Znuny GmbH, https://znuny.org/";

    return $Copyright;
}

sub GetChangedFiles {
    my %ChangedFiles = map { $_ => 1 } @{ $TidyAll::Znuny::ChangedFiles // [] };
    return \%ChangedFiles;
}

sub IsFileChanged {
    my ( $Self, $FilePath ) = @_;

    return if !defined $FilePath;

    my $ChangedFiles = $Self->GetChangedFiles();
    return $ChangedFiles->{$FilePath} ? 1 : 0;
}

=head2 ()

returns path of file or code.

    my $FilePath = $Object->FilePath($File);

    $File = \bless( [
       '/var/folders/47/mj945dss3gsd9sf1f4b8pbhh0000gn/T/Code-TidyAll-lbxB/scripts/test/Coffee.t',
       '/var/folders/47/mj945dss3gsd9sf1f4b8pbhh0000gn/T/Code-TidyAll-lbxB/scripts/test/Coffee.t',
       '',
       '/var/folders/47/mj945dss3gsd9sf1f4b8pbhh0000gn/T/Code-TidyAll-lbxB/scripts/test/',
       'Coffee.t'
     ], 'Path::Tiny' );

    # OR

    my $FilePath = $Object->FilePath($Code);

Returns:

    my $FilePath = '/scripts/test/Coffee.t';

=cut

sub FilePath {
    my ( $Self, $Content ) = @_;

    # File
    if ( ref $Content eq 'Path::Tiny' ) {
        $Content =~ s{.*\/Code-TidyAll-[^\/]+\/}{}x;
        return $Content;
    }

    # Code

    # package Kernel::System::Coffee;
    ( my $FilePath ) = $Content =~ m{^package \s ([^;]+);}xms;
    if ($FilePath) {
        $FilePath =~ s{::}{/}g;
        $FilePath .= '.pm';
    }

    # sopm
    if ( $Content =~ m{^\<\?xml\s[^\<]+<otrs_package}xms ) {
        my $GetPackageName = $Self->GetPackageName();
        $FilePath = $GetPackageName . '.sopm';
    }

    # xml
    if ( $Content =~ m{^\<\?xml\s[^\<]+<otrs_config}xms ) {
        my $GetCondensedPackageName = $Self->GetCondensedPackageName();
        $FilePath = $GetCondensedPackageName . '.xml';
    }

    return $FilePath;
}

=head2 Print()

    $Object->Print(
        Priority => 'error',
        Message  => 'Your package <Description></Description> ends with at least two dots. Should be only one.',
    );

=cut

sub Print {
    my ( $Self, %Param ) = @_;

    $Param{Priority} //= 'warning';
    $Param{Message}  //= '';
    $Param{Package}  //= '';

    my $Package = '';
    my $Message = '';

    my $PreOutput = "[$Param{Priority}] for the next file:\n";
    if ( $Param{FilePath} ) {
        $PreOutput = "[$Param{Priority}] $Param{FilePath}\n";
    }

    my %PriorityColorMap = (
        'success'   => 'green',
        'transform' => 'green',
        'warning'   => 'yellow',
        'notice'    => 'yellow',
        'error'     => 'red',
    );

    $Message = $Self->_Color( $PriorityColorMap{ $Param{Priority} }, $Param{Message} );
    $Package = $Self->_Color( $PriorityColorMap{ $Param{Priority} }, $Param{Package} );

    my $OutputMessage = <<"OUT";
$Package

$Message
OUT

    if ( $Param{Priority} eq 'error' ) {
        die $OutputMessage;
    }
    else {
        print $PreOutput;
        print $OutputMessage . "\n";
    }

    return;
}

# ---

1;
