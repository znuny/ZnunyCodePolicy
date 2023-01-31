# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::PerlCritic;

use strict;
use warnings;

use File::Basename;
use lib dirname(__FILE__) . '/../';    # Find our Perl::Critic policies

use parent qw(TidyAll::Plugin::Znuny::Perl);
use Perl::Critic;

use Perl::Critic::Policy::Znuny::ProhibitGoto;
use Perl::Critic::Policy::Znuny::ProhibitLowPrecendeceOps;
use Perl::Critic::Policy::Znuny::ProhibitSmartMatchOperator;
use Perl::Critic::Policy::Znuny::ProhibitRandInTests;
use Perl::Critic::Policy::Znuny::ProhibitOpen;
use Perl::Critic::Policy::Znuny::ProhibitUnless;
use Perl::Critic::Policy::Znuny::RequireCamelCase;
use Perl::Critic::Policy::Znuny::RequireLabels;
use Perl::Critic::Policy::Znuny::RequireParensWithMethods;
use Perl::Critic::Policy::Znuny::RequireTrueReturnValueForModules;

# Cache Perl::Critic object instance to save time.
our $CachedPerlCritic;

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );

    if ( !$CachedPerlCritic ) {
        $CachedPerlCritic = Perl::Critic->new(
            -severity => 4,
            -exclude  => [
                'Modules::RequireExplicitPackage',    # this breaks in our scripts/test folder
            ],
        );

        $CachedPerlCritic->add_policy( -policy => 'Znuny::ProhibitGoto' );
        $CachedPerlCritic->add_policy( -policy => 'Znuny::ProhibitLowPrecendeceOps' );
        $CachedPerlCritic->add_policy( -policy => 'Znuny::ProhibitOpen' );
        $CachedPerlCritic->add_policy( -policy => 'Znuny::ProhibitRandInTests' );
        $CachedPerlCritic->add_policy( -policy => 'Znuny::ProhibitSmartMatchOperator' );
        $CachedPerlCritic->add_policy( -policy => 'Znuny::ProhibitUnless' );
        $CachedPerlCritic->add_policy( -policy => 'Znuny::RequireCamelCase' );
        $CachedPerlCritic->add_policy( -policy => 'Znuny::RequireLabels' );
        $CachedPerlCritic->add_policy( -policy => 'Znuny::RequireParensWithMethods' );
        $CachedPerlCritic->add_policy( -policy => 'Znuny::RequireTrueReturnValueForModules' );
    }

    # Force stringification of $Filename as it is a Path::Tiny object in Code::TidyAll 0.50+.
    my @Violations = $CachedPerlCritic->critique("$Filename");

    if (@Violations) {
        $Self->AddErrorMessage("@Violations");
    }

    return;
}

1;
