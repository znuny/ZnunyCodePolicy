# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::RichTextEditor::UpdateSourceElement;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);


=head2 UpdateSourceElement()

This plugin validates and warns about .updateElement() method calls.

It checks for:

    return window.editor.updateElement();
    # To this:
    return window.editor.updateSourceElement();

    Core.UI.RichTextEditor.GetInstance('Body').updateElement();
    # To this:
    Core.UI.RichTextEditor.GetInstance('Body').updateSourceElement();

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan('7.2');

    my $LineCounter = 0;
    my $ErrorLines  = '';

    LINE:
    for my $Line ( split "\n", $Code ) {
        $LineCounter++;

        # Check for .updateElement() pattern
        if ( $Line =~ m{\.updateElement\(\)} ) {
            $ErrorLines .= "Line $LineCounter: $Line\n";
        }
    }

    return if !$ErrorLines;

    my $Message = <<'EOF';
The method name has changed in the new CKEditor API.

Change this:
return window.editor.updateElement();
or
Core.UI.RichTextEditor.GetInstance('Body').updateElement();

To this:
return window.editor.updateSourceElement();
or
Core.UI.RichTextEditor.GetInstance('Body').updateSourceElement();
EOF

    $Message .= "\n$ErrorLines";

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'warning',
    );

    return;
}

1;