# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::XML::Configuration::UnitTestBlacklist;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks if a blacklisted unit test via C<UnitTest::Blacklist> feature is present in the filesystem.

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $ErrorMessage;
    my $PackageName = '';

    LINE:
    for my $Line ( split /\n/, $Code ) {
        if ( !$PackageName && $Line =~ m{<Setting.*?Name="UnitTest::Blacklist###\d+-(.*?)"}sm ) {
            $PackageName = $1;
            next LINE;
        }

        if ( $PackageName && $Line =~ /<Item.*?>(.*)<\/Item>/ ) {
            my @TestNames = split /\//, $1;
            $TestNames[-1] = $PackageName . $TestNames[-1];

            my $PackageUnitTest = 'scripts/test/' . join( '/', @TestNames );
            if ( !grep { $_ eq $PackageUnitTest } @TidyAll::OTRS::FileList ) {
                $ErrorMessage .= $PackageUnitTest . "\n";
            }
        }

        if ( $Line =~ /<\/Setting>/ ) {
            $PackageName = '';
            next LINE;
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage(<<"EOF");
In order to blacklist unit test file(s), you need to first provide a suitable replacement under these path(s):
$ErrorMessage
EOF
    }

    return;
}

1;
