# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::SOPM::RequiredElements;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $ErrorMessage;

    my $Name            = 0;
    my $Version         = 0;
    my $Counter         = 0;
    my $Framework       = 0;
    my $Vendor          = 0;
    my $URL             = 0;
    my $License         = 0;
    my $BuildDate       = 0;
    my $BuildHost       = 0;
    my $DescriptionEN   = 0;
    my $Table           = 0;
    my $DatabaseUpgrade = 0;
    my $NameLength      = 0;
    my $BuildFlag       = 0;
    my $PackageName     = '';

    my $TableNameLength = 30;

    my @CodeLines = split /\n/, $Code;

    for my $Line (@CodeLines) {
        $Counter++;
        if ( $Line =~ /<Name>([^<>]+)<\/Name>/ ) {

            $Name        = 1;
            $PackageName = $1;
        }
        elsif ( $Line =~ /<Description Lang="en"[^<>]*>[^<>]+<\/Description>/ ) {
            $DescriptionEN = 1;
        }
        elsif ( $Line =~ /<License>([^<>]+)<\/License>/ ) {
            $License = 1;
        }
        elsif ( $Line =~ /<URL>([^<>]+)<\/URL>/ ) {
            $URL = 1;
        }
        elsif ( $Line =~ /<BuildHost>[^<>]*<\/BuildHost>/ ) {
            $BuildHost = 1;
        }
        elsif ( $Line =~ /<BuildDate>[^<>]*<\/BuildDate>/ ) {
            $BuildDate = 1;
        }
        elsif ( $Line =~ /<Vendor>([^<>]+)<\/Vendor>/ ) {
            $Vendor = 1;
        }
        elsif ( $Line =~ m{ <Framework (?: [ ]+ [^<>]* )? > ( [^<>]+ ) <\/Framework> }xms ) {
            $Framework = 1;

            my $FrameworkVersion = $1;

            if ( $FrameworkVersion !~ m{ \d+ \. \d+ \. [x\d]+ }xms ) {
                $ErrorMessage .= "Version needs to have the format 0.0.x or 0.0.0!\n";
            }
        }
        elsif ( $Line =~ /<Version>([^<>]+)<\/Version>/ ) {
            $Version = 1;
        }
        elsif ( $Line =~ /<File([^<>]+)>([^<>]*)<\/File>/ ) {
            my $Attributes = $1;
            my $Content    = $2;
            if ( $Content ne '' ) {
                $ErrorMessage .= "Don't insert something between <File><\/File>. Also, it's better to use <File ... /> instead.\n";
            }
            if ( $Attributes =~ /(Type|Encode)=/ ) {
                $ErrorMessage .= "Don't use the attribute 'Type' or 'Encode' in File tags.\n";
            }
            if ( $Attributes =~ /Location=.+?\.sopm/ ) {
                $ErrorMessage .= "Don't include other SOPM files in an SOPM's file list (line $Line).";
            }
        }
        elsif ( $Line =~ /(<Table .+?>|<\/Table>)/ ) {
            $Table = 1;
        }
        elsif ( $Line =~ /<DatabaseUpgrade>/ ) {
            $DatabaseUpgrade = 1;
        }
        elsif ( $Line =~ /<\/DatabaseUpgrade>/ ) {
            $DatabaseUpgrade = 0;
        }
        elsif ( $Line =~ /<Table.+?>/ ) {
            if ( $DatabaseUpgrade && $Line =~ /<Table/ && $Line !~ /Version=/ ) {
                $ErrorMessage
                    .= "If you use a Table tag in a DatabaseUpgrade context you need to have a Version attribute with the starting package version introducing this change (e.g. <TableAlter Name=\"some_table\" Version=\"1.0.6\">)!\n";
            }
        }

        if ( $Line =~ /<(Column.*|TableCreate.*) Name="(.+?)"/ ) {
            $Name = $2;
            if ( length $Name > $TableNameLength ) {
                $NameLength .= "Line $Counter: $Name\n";
            }
        }

        if ( $Line =~ m{ <PackageIsBuildable>(?: \d )<\/PackageIsBuildable> }xms ) {
            $BuildFlag = 1;
        }
    }

    if ($Table) {
        $ErrorMessage
            .= "The tag Table is not allowed in SOPM files. Perhaps you meant TableCreate.\n";
    }

    if ( !$DescriptionEN ) {
        $ErrorMessage .= "Missing tag <Description Lang=\"en\">.\n";
    }

    if ( !$Name ) {
        $ErrorMessage .= "Missing tag Name.\n";
    }

    if ( !$Version ) {
        $ErrorMessage .= "Missing tag Version.\n";
    }

    if ( !$Framework ) {
        $ErrorMessage .= "Missing tag Framework.\n";
    }

    if ( !$Vendor ) {
        $ErrorMessage .= "Missing tag Vendor.\n";
    }

    if ( !$URL ) {
        $ErrorMessage .= "Missing tag URL.\n";
    }

    if ( !$License ) {
        $ErrorMessage .= "Missing tag License.\n";
    }

    if ($NameLength) {
        $ErrorMessage
            .= "Column and table names must not be longer than $TableNameLength characters.\n";
        $ErrorMessage .= $NameLength;
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage($ErrorMessage);
    }

    return;
}

1;
