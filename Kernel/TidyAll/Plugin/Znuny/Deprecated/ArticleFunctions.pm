# --
# Copyright (C) 2012-2017 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::Deprecated::ArticleFunctions;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

This plugin checks for deprecated article function calls.

=cut

sub validate_source {    ## no critic
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my @DeprecatedArticleFunctions = (
        'ArticleGetTicketIDOfMessageID',
        'ArticleGetContentPath',
        'ArticleTypeLookup',
        'ArticleTypeList',
        'ArticleLastCustomerArticle',
        'ArticleFirstArticle',
        'ArticleContentIndex',
        'ArticleCount',
        'ArticlePage',
    );

    my $FunctionLookupRegex = '->('. join('|', @DeprecatedArticleFunctions) .')\(';
    my $DeprecatedCallLines = '';
    my $LineCounter         = 0;

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $LineCounter++;

        next LINE if $Line !~ m{$FunctionLookupRegex}xms;

        $DeprecatedCallLines .= "\n\tLine $LineCounter: $Line";
    }

    return if !$DeprecatedCallLines;

    my $Message = <<EOF;
Found deprecated article function call(s):
$DeprecatedCallLines

See OTRS commit 5fdf3471d4e2e7505470e5f44eebe82911267e72 for alternatives.
Using the CLI is recommended since GitHub doesn't show all the diffs by default which makes it hard to find the calls.
EOF

    $Self->AddErrorMessage($Message);

    return;
}

# Just a short overview:
#
# Same:

# Backends:

# ArticleCreate
# ArticleGet
# ArticleUpdate
# ArticleSend
# ArticleBounce
# SendAutoResponse
# ArticleAttachment
# ArticleAttachmentIndex


# Article.pm:

# ArticleSenderTypeList
# ArticleSenderTypeLookup
# ArticleFlagSet
# ArticleFlagDelete
# ArticleFlagGet
# ArticleFlagsOfTicketGet
# ArticleAccountedTimeGet
# ArticleAccountedTimeDelete



# Lost via 5fdf3471d4e2e7505470e5f44eebe82911267e72:
# ArticleGetTicketIDOfMessageID => ArticleGetByMessageID + UserID
# ArticleGetContentPath => Deleted / now internal
# ArticleTypeLookup => Deleted / new 'IsVisibleForCustomer' logic
# ArticleTypeList => Deleted / new 'IsVisibleForCustomer' logic
# ArticleLastCustomerArticle (Bug) => Deleted / see new code block
# ArticleFirstArticle => Deleted / see new code block
# ArticleIndex => Now ArticleList
# ArticleContentIndex => Deleted / see new code block
# ArticleCount => Deleted / see new code block
# ArticlePage => Deleted / see new code block


# 6:

# Article.pm:

# BackendForArticle
# BackendForChannel
# ArticleList
# TicketIDLookup
# ArticleSearchIndexRebuildFlagSet
# ArticleSearchIndexRebuildFlagList
# ArticleSearchIndexStatus
# ArticleSearchIndexBuild
# ArticleSearchIndexDelete
# ArticleSearchIndexSQLJoinNeeded
# ArticleSearchIndexSQLJoin
# ArticleSearchIndexWhereCondition
# SearchStringStopWordsFind
# SearchStringStopWordsUsageWarningActive
# ArticleSearchableFieldsList


# Backends:

# ChannelNameGet
# ChannelIDGet
# ArticleHasHTMLContent
# BackendSearchableFieldsGet
# ArticleSearchableContentGet

1;
