# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Common::Origin;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks that only valid origins are used in customized files.

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    my $Origin = '$origin:';

    # Check the origin if customization markers are found
    if ( $Code =~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ --- [ ]* $ }xms ) {

        my $FoundOrigin;
        my $LineCounter = 0;
        ORIGINLINE:
        for my $Line ( split /\n/, $Code ) {
            $LineCounter++;

            # Ignore exact position of origin tag because there could be more than two copyright lines in the header.
#             last ORIGINLINE if $LineCounter > 5;

            next ORIGINLINE if $Line !~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ \$origin: [ ]+ [^\n]+ $ }xms;

            $FoundOrigin = 1;

            last ORIGINLINE;
        }

        if ( !$FoundOrigin ) {

            my $PackageCounter = 0;

            PACKAGELINE:
            for my $Line ( split /\n/, $Code ) {

                next PACKAGELINE if $Line !~ m{ ^ package [ ]+ ( [A-Za-z0-9\:]+ ) \; $ }xms;

                # count lines with any 'package..;'
                $PackageCounter++;
            }

            return $Code if $PackageCounter == 0;

            # only one 'package' allowed per file - split first if there are more packages combined.
            if ($PackageCounter > 1) {
                $Self->AddErrorMessage("$PackageCounter package lines found.\n");
            }

            my ($FilePath) = $Code =~ m{ ^ package [ ]+ ( [A-Za-z0-9\:]+ ) \; $ }xms;

            # just allow Kernel and scripts::tests to be modified automatically
            return $Code if $FilePath !~ m{ ^ ( Kernel | scripts \:\: tests )? \:\: }xms;

            $FilePath =~ s{ \:\: }{/}gsmx;

            my $NewOrigin = $Origin . ' znuny - 0000000000000000000000000000000000000000 - ' . $FilePath . '.pm';

            # place new origin after Copyright
            $Code =~ s{ ( \# [ ]+ Copyright .* \/ \n \# [ ]+ -- \n \# [ ]+ ) }{$1$NewOrigin\n# --\n# }xms;
        }
    }

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Check the origin if customization markers are found
    if ( $Code =~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ --- [ ]* $ }xms ) {
        my $FoundOrigin;
        my $Counter = 0;
        LINE:
        for my $Line ( split /\n/, $Code ) {
            $Counter++;

            # Ignore exact position of origin tag because there could be more than two copyright lines in the header.
#             last LINE if $Counter > 5;

            next LINE if $Line !~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ \$origin: [ ]+ [^\n]+ $ }xms;

            $FoundOrigin = 1;
            last LINE;
        }

        if (!$FoundOrigin) {
            $Self->AddErrorMessage("Customization markers found but no origin present.\n");
        }
    }

    return $Code;
}

sub validate_file {
    my ( $Self, $Filename ) = @_;

    return if $Self->IsPluginDisabled( FilePath => $Filename );

    my $Code = $Self->GetFileContent($Filename);

    # Check if all files in the Custom directory has an origin
    if ( $Filename =~ m{ \/Custom\/ }xms ) {

        # Check if an origin exist.
        if ( $Code !~ m{ ^ [ ]* (?: \# | \/\/ ) [ ]+ \$origin: [ ]+ [^\n]+ $ }xms ) {
            $Self->AddErrorMessage("File is in Custom directory but no origin present.\n");
        }
    }

    if ( $Filename =~ m{ .* \.css }xmsi ) {

        # Check if a CSS file is overritten in Custom directory.
        if ( $Filename =~ m{ \/Custom\/var\/ }xms ) {

            $Self->AddErrorMessage(<<"EOF");
Forbidden to have a CSS file in Custom folder, because it's not allowed to override an existing CSS file.
Use a new one to override existing CSS classes.
EOF
        }

        # Check if an origin exist.
        if ( $Code =~ m{ ^ [ ]* (?: \# | \/\/ | \* ) [ ]+ (?: \$ | \@ ) origin: [ ]+ [^\n]+ $ }xms ) {

            $Self->AddErrorMessage(<<"EOF");
Forbidden to have an origin in a CSS file, because it's not allowed to override an existing CSS file.
Use a new one to override existing CSS classes.
EOF
        }

        # Check if customization markers exists.
        if ( $Code =~ m{ ^ [ ]* (?: \# | \/\/ | \* | \/\* ) [ ]+ --- [ ]* $ }xms ) {

            $Self->AddErrorMessage(<<"EOF");
Forbidden to have customization markers in a CSS file, because it's not allowed to override an existing CSS file.
Use a new one to override existing CSS classes.
EOF
        }
    }

    return;
}

1;
