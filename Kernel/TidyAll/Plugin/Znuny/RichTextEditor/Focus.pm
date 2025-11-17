# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::RichTextEditor::Focus;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head2 Focus()

This plugin validates and warns about old CKEditorInstances.focus() usage.

It checks for:

    CKEditorInstances[EditorID].focus();

    # To this:

    Core.UI.RichTextEditor.Focus($('#' + EditorID.sourceElement.id))

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan('7.2');

    my $LineCounter = 0;
    my $ErrorLines  = '';

    # Check for CKEditorInstances focus() usage
    if ( $Code =~ /CKEditorInstances\[[^\]]+\]\.focus\(\)/ ) {
        $ErrorLines .= "Found CKEditorInstances[].focus() pattern. Use Core.UI.RichTextEditor.Focus() instead.\n";
    }

    LINE:
    for my $Line ( split "\n", $Code ) {
        $LineCounter++;

        # Check for direct CKEditorInstances focus usage
        if ( $Line =~ /CKEditorInstances\[.*?\]\.focus\(\)/ ) {
            $ErrorLines .= "Line $LineCounter: Found CKEditorInstances focus usage. Use Core.UI.RichTextEditor.Focus() instead.\n";
        }
    }

    return if !$ErrorLines;

    my $Message = <<'EOF';
The new CKEditor API uses Core.UI.RichTextEditor.Focus() method.

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