# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::RichTextEditor::Ranges;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head2 Ranges()

This plugin validates and warns about old range selection methods.

It checks for:

    EditorID.getSelection().getRanges()

    # To this:

    EditorID.model.document.selection.getRanges()

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan('7.2');

    my $LineCounter = 0;
    my $ErrorLines  = '';

    # Check for getSelection().getRanges() usage
    if ( $Code =~ /getSelection\(\)\.getRanges\(\)/ ) {
        $ErrorLines .= "Found getSelection().getRanges() pattern. Use model.document.selection.getRanges() instead.\n";
    }

    LINE:
    for my $Line ( split "\n", $Code ) {
        $LineCounter++;

        # Check for old range selection patterns
        if ( $Line =~ /getSelection\(\)\.getRanges\(\)/ ) {
            $ErrorLines .= "Line $LineCounter: Found getSelection().getRanges() usage. Use model.document.selection.getRanges() instead.\n";
        }
    }

    return if !$ErrorLines;

    my $Message = <<'EOF';
The new CKEditor API uses different methods for range handling.

Change this:
EOF

    $Message .= "\n$ErrorLines";

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'warning',
    );

    return;
}

1;