# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::Pod::Validator;
use strict;
use warnings;

use Capture::Tiny qw(capture_merged);
use Pod::Checker;
use Pod::POM;

use parent qw(TidyAll::Plugin::Znuny::Perl);

#
# Validates Pod with Pod::Checker for syntactical correctness.
#

sub validate_file {
    my ( $Self, $File ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $File );

    my $Checker = Pod::Checker->new();

    # Force stringification of $File as it is a Path::Tiny object in Code::TidyAll 0.50+.
    my $Output = capture_merged { $Checker->parse_from_file( "$File", \*STDERR ) };

    # Only die if Output is filled with errors. Otherwise it could be
    #   that there just was no POD in the file.
    if (
        (
            $Checker->num_errors()
            || $Checker->num_warnings()
        )
        && defined $Output
        && length $Output
    ) {
        $Self->AddMessage(
            Message  => $Output,
            Priority => 'warning',
        );
    }

    $Checker = Pod::POM->new( warn => 1 );
    $Output = capture_merged { $Checker->parse_file("$File") || die $Checker->error() };
    $Output =~ s{(.+at\s).+(Kernel.+)}{$1$2}g;

    if (
        (
            $Checker->{WARN} >= 1
            || $Checker->{ERROR} >= 1
        )
        && defined $Output
        && length $Output
    ) {
        $Self->AddMessage(
            Message  => $Output . "\n",
            Priority => 'warning',
        );
    }
}

1;
