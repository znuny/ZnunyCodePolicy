# --
# Copyright (C) 2012-2026 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::XML::Database::AuditColumns;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head1 SYNOPSIS

Warns when a database column uses C<created>, C<created_by>, C<changed> or C<changed_by>.
Framework tables use C<create_time>, C<create_by>, C<change_time> and C<change_by>.

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my %ReplacementForColumnName = (
        created    => 'create_time',
        created_by => 'create_by',
        changed    => 'change_time',
        changed_by => 'change_by',
    );

    my $CurrentTableName = '';
    my $Counter          = 0;
    my $ErrorMessage     = '';

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        if ( $Line =~ m{ <Table(?:Create|Alter)? \s [^>]* \b Name="(?<TableName>[^"]+)" }xms ) {
            $CurrentTableName = $+{TableName};
        }

        my $ColumnName;

        # Column and ColumnAdd define the name. ColumnChange renames via NameNew.
        # NameOld and ColumnDrop are the previous name and must not warn.
        if ( $Line =~ m{ <Column(?:Add)? \s [^>]* \b Name="(?<ColumnName>created_by|created|changed_by|changed)" }xms ) {
            $ColumnName = $+{ColumnName};
        }
        elsif ( $Line =~ m{ <ColumnChange \s [^>]* \b NameNew="(?<ColumnName>created_by|created|changed_by|changed)" }xms ) {
            $ColumnName = $+{ColumnName};
        }

        next LINE if !$ColumnName;

        my $TableName   = $CurrentTableName || 'unknown';
        my $Replacement = $ReplacementForColumnName{$ColumnName};

        $ErrorMessage .= "Line $Counter, table '$TableName': column '$ColumnName'. Use '$Replacement'.\n";
    }

    return if !length $ErrorMessage;

    $Self->AddMessage(
        Message =>
            "Use framework audit column names (create_time, create_by, change_time, change_by).\n$ErrorMessage",
        Priority => 'warning',
    );

    return;
}

1;
