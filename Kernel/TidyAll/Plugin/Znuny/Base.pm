# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
package TidyAll::Plugin::Znuny::Base;

use strict;
use warnings;

use utf8;

use parent qw(Code::TidyAll::Plugin);

use Term::ANSIColor();
use Path::Tiny;

=head2 process_source_or_file()

    Ensures that the code and path of the currently checked file is accessible from all
    places. Is an overwritten function of Code::TidyAll::Plugin and will automatically be called.

=cut

sub process_source_or_file { ## no critic
    my ( $Self, $OrigSource, $RelPath, $CheckOnly ) = @_;

    $Self->{CurrentlyCheckedCode}         = $OrigSource;
    $Self->{CurrentlyCheckedSOPMFilePath} = $RelPath;

    return $Self->SUPER::process_source_or_file( $OrigSource, $RelPath, $CheckOnly );
}

=head2 GetCurrentlyCheckedCode()

    Returns the path to the currently checked file as given in the SOPM file list.

    my $FilePath = $TidyAllObject->GetCurrentlyCheckedCode();

    Returns e.g.: 'Kernel/System/CSV.pm'

=cut

sub GetCurrentlyCheckedCode {
    my ( $Self, $FilePath ) = @_;

    return $Self->{CurrentlyCheckedCode};
}

=head2 GetCurrentlyCheckedSOPMFilePath()

    Returns the path to the currently checked file as given in the SOPM file list.

    my $FilePath = $TidyAllObject->GetCurrentlyCheckedSOPMFilePath();

    Returns e.g.: 'Kernel/System/CSV.pm'

=cut

sub GetCurrentlyCheckedSOPMFilePath {
    my ( $Self, $FilePath ) = @_;

    return $Self->{CurrentlyCheckedSOPMFilePath};
}

=head2 GetTidyAllZnunyObject()

    Returns the TidyAll::Znuny object to access its functions.

    my $TidyAllZnunyObject = $TidyAllObject->GetTidyAllZnunyObject();

    Returns the TidyAll::Znuny object.

=cut

sub GetTidyAllZnunyObject {
    my ( $Self, %Param ) = @_;

    return $TidyAll::Znuny::Object;
}

=head2 GetSettings()

    Retrieves all settings stored in $TidyAll::Znuny::Settings.

    my $Settings = $TidyAllObject->GetSettings();

    Returns the stored values (can be empty hash).

=cut

sub GetSettings {
    my ( $Self, $Key ) = @_;

    my $TidyAllZnunyObject = $Self->GetTidyAllZnunyObject();
    return if !$TidyAllZnunyObject;

    return $TidyAllZnunyObject->GetSettings();
}

=head2 GetSetting()

    Retrieves the value of a single setting with the given key.

    my $Value = $TidyAllObject->GetSetting('Framework::Version');

    Returns the stored value or undef if the key does not exist.

=cut

sub GetSetting {
    my ( $Self, $Key ) = @_;

    my $TidyAllZnunyObject = $Self->GetTidyAllZnunyObject();
    return if !$TidyAllZnunyObject;

    return $TidyAllZnunyObject->GetSetting($Key);
}

=head2 IsPluginDisabled()

    Checks if the currently executed plugin is disabled for the file/code to be checked
    by checking for a 'nofilter' line.

    my $PluginIsDisabled = $TidyAllObject->IsPluginDisabled(
        Code => '...',

        # OR

        FilePath => 'Kernel/System/CSV.pm',
    );

=cut

sub IsPluginDisabled {
    my ( $Self, %Param ) = @_;

    my $PackageName = ref $Self;

    if ( !defined $Param{Code} && !defined $Param{FilePath} ) {
        $Self->AddErrorMessage(
            "Either parameter Code or FilePath is needed in call to IsPluginDisabled() in plugin $PackageName.\n"
        );
    }

    my $Code = defined $Param{Code} ? $Param{Code} : $Self->GetFileContent( $Param{FilePath} );

    return 1 if $Code =~ m{nofilter\([^()]*?\Q$PackageName\E}ism;

    return;
}

=head2 AddErrorMessage()

    Adds an error message with the given priority for the currently checked file.

    $TidyAllObject->AddErrorMessage(
        Message  => 'Your package <Description></Description> ends with at least two dots. Should be only one.',
    );

=cut

sub AddErrorMessage {
    my ( $Self, $ErrorMessage ) = @_;

    return $Self->AddMessage(
        Message  => $ErrorMessage,
        Priority => 'error',
    );
}

=head2 AddMessage()

    Adds a message with the given priority for the currently checked file.

    $TidyAllObject->AddMessage(
        Message  => 'Your package <Description></Description> ends with at least two dots. Should be only one.',
        Priority => 'error', # or: success, transform, warning, notice
    );

=cut

sub AddMessage {
    my ( $Self, %Param ) = @_;

    my $TidyAllZnunyObject = $Self->GetTidyAllZnunyObject();

    my %PriorityColorMap = (
        'success'   => 'green',
        'transform' => 'green',
        'warning'   => 'yellow',
        'notice'    => 'yellow',
        'error'     => 'red',
    );

    # Indent every line of message.
    my $Message = $Param{Message} // '';
    chomp $Message;

    my @MessageLines = split "\n", $Message;
    $Message = join "\n", map { "        $_" } @MessageLines;

    my $Priority = $Param{Priority} // 'warning';
    my $Color    = $PriorityColorMap{$Priority} // 'yellow';
    $Message     = $Self->ColorString( $Message // '', $Color );

    # Add plugin name to message.
    $Message = $Self->ColorString( ref $Self, 'cyan' ) . "\n$Message\n";

    my %MessageParam;
    if ( $Priority eq 'error' ) {
        $MessageParam{ErrorMessage} = $Message;
    }
    else {
        $MessageParam{Message} = $Message;
    }

    $TidyAllZnunyObject->AddFileCheckResult(
        FilePath => $Self->GetCurrentlyCheckedSOPMFilePath(),
        %MessageParam,
    );

    return;
}

=head2 ColorString()

    Colors the given string (see Term::ANSIColor::color()) if ANSI output is available and active
    and environment variable ZNUNY_CODE_POLICY_NO_COLOR_OUTPUT is not set.

    Otherwise the text stays unchanged.

    my $ColoredText = $TidyAllObject->ColorString( $String, 'green' );

=cut

sub ColorString {
    my ( $Self, $String, $Color ) = @_;

    return $String if $ENV{ZNUNY_CODE_POLICY_NO_COLOR_OUTPUT};

    return Term::ANSIColor::color($Color) . $String . Term::ANSIColor::color('reset');
}

=head2 GetFileContent()

    Returns content of the given file.

    my $Content = $TidyAllObject->GetFileContent(
        'Kernel/System/CSV.pm',
    );

=cut

sub GetFileContent {
    my ( $Self, $FilePath ) = @_;

    my $FileHandle;
    if ( !open $FileHandle, '<', $FilePath ) {    ## no critic
        $Self->AddErrorMessage("Can't open $FilePath");
    }

    my $Content = do { local $/ = undef; <$FileHandle> };
    close $FileHandle;

    return $Content;
}

=head2 IsOriginalOTRSCode()

    Checks if the given code has an OTRS AG copyright.

    my $IsOriginalOTRSCode = $TidyAllObject->IsOriginalOTRSCode($Code);

    Returns true value if given code is original OTRS code.

=cut

sub IsOriginalOTRSCode {
    my ( $Self, $Code ) = @_;

    return 1 if $Code =~ m{Copyright \(C\) 2001-20\d{2} OTRS AG}sm;

    return;
}

=head2 IsOriginalZnunyCode()

    Checks if the given code originally comes from Znuny.

    my $IsOriginalZnunyCode = $TidyAllObject->IsOriginalZnunyCode($Code);

    Returns true value if given code is original Znuny code.

=cut

sub IsOriginalZnunyCode {
    my ( $Self, $Code ) = @_;

    return if $Self->IsOriginalOTRSCode($Code);
    return if $Self->GetSetting('IsThirdPartyProduct');

    return 1 if $Code =~ m{Copyright .*? Znuny GmbH}sm;

    return;
}

=head2 GetZnunyCopyrightString()

    Returns the current copyright string for Znuny (framework)
    or package files.

    my $CopyrightString = $TidyAllObject->GetZnunyCopyrightString();

=cut

sub GetZnunyCopyrightString {
    my ( $Self ) = @_;

    my $IsFrameworkContext = $Self->GetSetting('Context::Framework');
    my $CopyrightYear      = $IsFrameworkContext ? 2021 : 2012;
    my $URL                = $IsFrameworkContext ? 'https://znuny.org/' : 'https://znuny.com/';

    my ( $Sec, $Min, $Hour, $Day, $Month, $Year ) = localtime( time() );
    $Year += 1900;

    if ( $Year > $CopyrightYear ) {
        $CopyrightYear .= "-$Year";
    }

    my $CopyrightString = "Copyright (C) $CopyrightYear Znuny GmbH, $URL";

    return $CopyrightString;
}

1;
