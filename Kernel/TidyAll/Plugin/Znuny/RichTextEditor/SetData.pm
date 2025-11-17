# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::RichTextEditor::SetData;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head2 SetData()

This plugin validates and warns about .setData() calls without parameters.

It checks for:

    Core.UI.RichTextEditor.GetInstance('Body').setData();
    # To this:
    Core.UI.RichTextEditor.GetInstance('Body').setData('');

    Core.UI.RichTextEditor.GetInstance('InstanceName').setData();
    # To this:
    Core.UI.RichTextEditor.GetInstance('InstanceName').setData('');

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

        # Check for .setData() without parameters
        if ( $Line =~ m{\.setData\(\)} ) {
            $ErrorLines .= "Line $LineCounter: $Line\n";
        }
    }

    return if !$ErrorLines;

    my $Message = <<'EOF';
The setData() method requires a parameter in the new CKEditor API.

Change this:
Core.UI.RichTextEditor.GetInstance('Body').setData();

To this:
Core.UI.RichTextEditor.GetInstance('Body').setData('');
EOF

    $Message .= "\n$ErrorLines";

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'warning',
    );

    return;
}

1;