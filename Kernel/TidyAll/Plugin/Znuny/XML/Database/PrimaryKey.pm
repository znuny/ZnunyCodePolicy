# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::XML::Database::PrimaryKey;

use strict;
use warnings;

use utf8;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Errors when a C<TableCreate> in an add-on has no column with C<PrimaryKey="true">.
Applies from framework 7.1 on. Znuny 7.1 added real primary keys to tables that
previously only had unique indexes.

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan('7.1');

    my $ErrorMessage = '';

    TABLE:
    while (
        $Code =~ m{
            <TableCreate \b
            (?<Attributes> [^>]* )
            >
            (?<Body> .*? )
            </TableCreate>
        }xsg
        )
    {
        my $Attributes = $+{Attributes};
        my $Body       = $+{Body};
        my $MatchStart = $-[0];

        my $TableName = 'unknown';
        if ( $Attributes =~ m{ \b Name \s* = \s* "(?<TableName>[^"]+)" }xms ) {
            $TableName = $+{TableName};
        }

        # Comments must not satisfy the check.
        my $ColumnBody = $Body;
        $ColumnBody =~ s{ <!-- .*? --> }{}xsg;

        my $HasPrimaryKey = $ColumnBody =~ m{ <Column \b [^>]* \b PrimaryKey \s* = \s* "true" }xsi;
        next TABLE if $HasPrimaryKey;

        my $LineNumber = 1 + ( substr( $Code, 0, $MatchStart ) =~ tr/\n// );
        $ErrorMessage .= "Line $LineNumber, table '$TableName': no column with PrimaryKey=\"true\".\n";
    }

    return if !length $ErrorMessage;

    $Self->AddErrorMessage(
        "TableCreate without a primary key is not allowed for framework 7.1 and later.\n$ErrorMessage"
    );

    return;
}

1;
