# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::XML::Configuration::DaemonModuleCheck;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

This plugin checks for deprecated module usage in Daemon::SchedulerCronTaskManager::Task settings.

It looks for settings that use Kernel::System::* modules (directly under System) and suggests using
Kernel::System::Console::Command::* modules instead.

=cut

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );

    # Only check XML files in Kernel/Config/Files/XML/
    return if $Filename !~ m{Kernel/Config/Files/XML/.*\.xml$};

    # Only run for packages, not framework
    my $IsFramework = $Self->GetSetting('Context::Framework');
    return if $IsFramework && $IsFramework eq 'Framework';

    my $Code = $Self->GetFileContent($Filename);

    my @Settings = ();
    my $LineCounter = 0;
    my $InDaemonSetting = 0;
    my $CurrentSettingName = '';
    my $CurrentSettingStartLine = 0;

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;

        # Check for Daemon::SchedulerCronTaskManager::Task settings
        if ( $Line =~ m{<Setting\s+Name="(Daemon::SchedulerCronTaskManager::Task[^"]*)"} ) {
            $InDaemonSetting = 1;
            $CurrentSettingName = $1;
            $CurrentSettingStartLine = $LineCounter;
            next LINE;
        }

        # Check for end of setting
        if ( $Line =~ m{</Setting>} && $InDaemonSetting ) {
            $InDaemonSetting = 0;
            $CurrentSettingName = '';
            $CurrentSettingStartLine = 0;
            next LINE;
        }

        # Check for deprecated Kernel::System::* module usage within daemon settings
        # Match Kernel::System:: followed by a module name (no colons = direct under System)
        # But exclude Kernel::System::Console::Command::* modules with negative lookahead
        if ( $InDaemonSetting && $Line =~ m{<Item\s+Key="Module">(Kernel::System::(?!Console::Command::)[^<:]+)</Item>} ) {
            my $ModuleName = $1;
            push @Settings, {
                SettingName => $CurrentSettingName,
                LineNumber  => $LineCounter,
                StartLine   => $CurrentSettingStartLine,
                Line        => $Line,
                ModuleName  => $ModuleName,
            };
        }
    }

    return if !@Settings;

    my $ErrorMessage = "Found deprecated module usage in Daemon::SchedulerCronTaskManager::Task settings.\n";
    $ErrorMessage .= "Please use 'Kernel::System::Console::Command::*' modules instead of direct 'Kernel::System::*' modules:\n";

    for my $Setting ( @Settings ) {
        $ErrorMessage .= sprintf(
            "\nSetting: %s (starts at line %d)\n",
            $Setting->{SettingName},
            $Setting->{StartLine}
        );
        $ErrorMessage .= sprintf(
            "Line %d: %s\n",
            $Setting->{LineNumber},
            $Setting->{Line}
        );
        $ErrorMessage .= sprintf(
            "Found module: %s\n",
            $Setting->{ModuleName}
        );
        $ErrorMessage .= "Should use a Console Command like: <Item Key=\"Module\">Kernel::System::Console::Command::Maint::Cache::Delete</Item>\n";
    }

    $Self->AddMessage(
        Message  => $ErrorMessage,
        Priority => 'warning',
    );

    return;
}

1;
