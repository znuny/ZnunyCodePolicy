# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package var::packagesetup::ZnunyCodePolicy;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Config',
);

=head1 NAME

var::packagesetup::ZnunyCodePolicy - Code to execute during package installation

=head1 DESCRIPTION

All functions

=head1 PUBLIC INTERFACE

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 CodeInstall()

Run the code install part:

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ( $Self, %Param ) = @_;

    my $Result = $Self->_InstallDependencies();

    return $Result;
}

=head2 CodeReinstall()

Run the code reinstall part:

    my $Result = $CodeObject->CodeReinstall();

=cut

sub CodeReinstall {
    my ( $Self, %Param ) = @_;

    my $Result = $Self->_InstallDependencies();

    return $Result;
}

=head2 CodeUpgrade()

Run the code upgrade part:

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    my ( $Self, %Param ) = @_;

    my $Result = $Self->_InstallDependencies();

    return $Result;
}

=head2 CodeUninstall()

Run the code uninstall part:

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ( $Self, %Param ) = @_;

    my $Result = $Self->_DeleteDependencies();

    return $Result;
}

=head2 _InstallDependencies()

Installs dependencies, if needed:

    my $Success = $CodeObject->_InstallDependencies();

=cut

sub _InstallDependencies {
    my $Self = shift;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $Version = $ConfigObject->Get('Version');

    my ($VersionMajor) = $Version =~ m{^(\d+)\.}xms;

    my $Home   = $ConfigObject->Get('Home');
    my $Result = system("perl $Home/bin/znuny.CodePolicy.pl --install-eslint");

    return !$Result;
}

=head2 _DeleteDependencies()

Deletes the dependency folder, if it exists:

    my $Success = $CodeObject->_DeleteDependencies();

=cut

sub _DeleteDependencies {
    my $Self = shift;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $Home                = $ConfigObject->Get('Home');
    my $DependencyDirectory = $Home . '/Kernel/TidyAll/Plugin/Znuny/JavaScript/ESLint/node_modules';
    return 1 if !-d $DependencyDirectory;

    my $Result = system("rm -rf $DependencyDirectory");

    return !$Result;
}

1;
