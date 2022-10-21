# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Common::NoFilter;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Harmonizes "nofilter" lines.

=cut

sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    # Replace nofilter lines in pm like files.
    #
    # Original:
    #     # nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator)
    #     # nofilter (TidyAll::Plugin::Znuny::Legal::LicenseValidator)
    #     ## nofilter (TidyAll::Plugin::Znuny::Legal::LicenseValidator)
    #     ## nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator);
    #     my $Dump = Data::Dumper::Dumper($HashRef);    #nofilter(TidyAll::Plugin::Znuny::Perl::Dumper)
    #
    # Replacement:
    #     ## nofilter (TidyAll::Plugin::Znuny::Legal::LicenseValidator)
    #     my $Dump = Data::Dumper::Dumper($HashRef);    ## nofilter(TidyAll::Plugin::Znuny::Perl::Dumper)
    #
    $Code =~ s{ ^ ( [^\#\n]* ) \#+ \s* no \s* filter \s* \( ( .+? ) \) .*? \n }{$1## nofilter($2)\n}xmsg;

    # Replace nofilter lines in js like files.
    #
    # Original:
    #     // nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator)
    #     // nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator)
    #     // nofilter(TidyAll::Plugin::Znuny::JavaScript::FileName)
    #     // nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator)
    #     my $Dump = Data::Dumper::Dumper($HashRef);    // nofilter(TidyAll::Plugin::Znuny::Perl::Dumper)
    #
    # Replacement:
    #     // nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator)
    #     my $Dump = Data::Dumper::Dumper($HashRef);    // nofilter(TidyAll::Plugin::Znuny::Perl::Dumper)
    #
    $Code =~ s{ ^ ( [^\/\n]* ) \/+ \s* no \s* filter \s* \( ( .+? ) \) .*? \n }{$1// nofilter($2)\n}xmsg;

    # Replace nofilter lines in css like files.
    #
    # Original:
    #     /* nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator) */
    #     /**  no filter (TidyAll::Plugin::Znuny::Legal::LicenseValidator) */
    #     /*  nofilter (TidyAll::Plugin::Znuny::Legal::LicenseValidator); */
    #
    # Replacement:
    #     /* nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator) */
    #
    $Code
        =~ s{ ^ ( \s* ) \/ \*+ [^\n]* no \s* filter \s* \( ( .+? ) \) .*? \*+ \/ [^\n]* \n }{$1/* nofilter($2) */\n}xmsg;

    # Replace nofilter lines in xml like files.
    #
    # Original:
    #     <!-- nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator) -->
    #     <!--  no filter (TidyAll::Plugin::Znuny::Legal::LicenseValidator) -->
    #     <!--  nofilter (TidyAll::Plugin::Znuny::Legal::LicenseValidator); -->
    #
    # Replacement:
    #     <!-- nofilter(TidyAll::Plugin::Znuny::Legal::LicenseValidator) -->
    #
    $Code
        =~ s{ ^ ( \s* ) <!-- [^\n]* no \s* filter \s* \( ( .+? ) \) .*? --> [^\n]* \n }{$1<!-- nofilter($2) -->\n}xmsg;

    # get all available plugins and store them into a hash (remove leading '+')
    # with the old plugin name as key
    # and the new znuny plugin name as value

    # TidyAll::Plugin::OTRS::Legal::LicenseValidator => TidyAll::Plugin::Znuny::Legal::LicenseValidator
    my %PluginMap = map { s{\+(.+Plugin::)Znuny}{$1OTRS}r => s{\+}{}r } sort keys %{$Self->{tidyall}->{plugins}};

    for my $OldKey (sort keys %PluginMap){
        my $NewKey = $PluginMap{$OldKey};
        $Code =~ s{nofilter\($OldKey\)}{nofilter\($NewKey\)}xmsg;
    }

    $Code =~ s{(.+nofilter\(TidyAll::Plugin::OTRS.*\))}{}x;

    return $Code;
}

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    return $Code if $Code !~ m{ nofilter \( .+? \) }xms;

    if ( $Code =~ m{ <!-- \s* nofilter \s* \( }xms ) {
        if ( $Code !~ m{ <!-- \s nofilter \( .+? \) \s --> }xms ) {
            $Self->AddErrorMessage("Found invalid nofilter() XML line!");
        }
    }
    else {
        if ( $Code !~ m{ (?: \#\# | \/\/ | \/\* ) \s nofilter \( .+? \) }xms ) {
            $Self->AddErrorMessage("Found invalid nofilter() line!");
        }
    }

    return $Code;
}

1;
