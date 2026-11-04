# --
# Copyright (C) 2012-2024 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Deprecated::OTRSGenericInterfaceTags;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Checks and transforms for deprecated OTRS_* tags in web service configurations
to their ZNUNY_* aliases:

    <OTRS_CONFIG_*>, <OTRS_JWT*>, <OTRS_OAUTH2_TOKEN>
    OTRS_Ticket* response tags of invoker Ticket::Generic

Other OTRS_* smart tags (e.g. <OTRS_TICKET_*> or <OTRS_Ticket_*>) are not affected.

Note: This plugin is only available for Znuny 7.5.0 and higher.

=cut

sub transform_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );
    return $Code if $Self->IsFrameworkVersionLessThan('7.5');

    # Rename config, JWT and OAuth2 placeholders
    $Code =~ s{(<|&lt;)OTRS_(CONFIG_|JWT|OAUTH2_TOKEN)}{$1ZNUNY_$2}g;

    # Response tags are only normalized by invoker Ticket::Generic.
    return $Code if $Code !~ m{\bTicket::Generic\b};

    $Code =~ s{
        \bOTRS_(
            Ticket(?:
                TitleUpdate|ServiceSet|TypeSet|QueueSet|SLASet|CustomerSet|StateSet
                |OwnerSet|ResponsibleSet|PrioritySet|HistoryAdd|ArticleAdd
                |ArticleCreateEvent|Create
            )
            |AsynchronousInvokerExecution
        )\b
    }{ZNUNY_$1}xg;
    $Code =~ s{\bOTRS_(TicketDynamicFieldSet_\w)}{ZNUNY_$1}g;

    return $Code;
}

1;
