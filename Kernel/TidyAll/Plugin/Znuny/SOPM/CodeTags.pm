# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::SOPM::CodeTags;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my ( @SelfUsed, @CDATAMissing );

    $Code =~ s{
        (<Code[a-zA-Z]+.*?>)    # start tag
        (.*?)                   # content
        </Code[a-zA-Z]+.*?>     # end tag
    }{
        my $StartTag = $1;
        my $TagContent = $2;

        if ($TagContent =~ m{\$Self}smx) {
            push @SelfUsed, $StartTag;
        }
        if ($TagContent !~ m{ \A\s*<!\[CDATA\[ }smx) {
            push @CDATAMissing, $StartTag;
        }

    }smxge;

    my $ErrorMessage;

    if (@SelfUsed) {
        $ErrorMessage
            .= "Don't use \$Self in <Code*> tags. Use \$Kernel::OM->Get() instead to access objects.\n";
        $ErrorMessage .= "Wrong tags found: " . join( ', ', @SelfUsed ) . "\n";
    }

    if (@CDATAMissing) {
        $ErrorMessage .= "<Code*> tags should always be wrapped in CDATA sections.\n";
        $ErrorMessage .= "Wrong tags found: " . join( ', ', @SelfUsed ) . "\n";
    }

    ## nofilter(TidyAll::Plugin::OTRS::Perl::ObjectDependencies)
    my $Example = <<'EOF';
Valid example tag:
    <CodeInstall Type="post"><![CDATA[
        $Kernel::OM->Get('var::packagesetup::MyPackage')->CodeInstall();
    ]]></CodeInstall>
EOF

    if ($ErrorMessage) {
        $Self->AddErrorMessage("$ErrorMessage\n$Example");
    }
}

1;
