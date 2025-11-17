# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::RichTextEditor::ListAllInstances;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head2 ListAllInstances()

This plugin validates and warns about CKEDITOR.instances usage without property access.

It checks for:

    var Instances = CKEDITOR.instances;
    # To this:
    var Instances = Core.UI.RichTextEditor.ListAllInstances();

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

        # Check for CKEDITOR.instances (without property access)
        if ( $Line =~ m{CKEDITOR\.instances\s*(?!\[]|\.)} ) {
            $ErrorLines .= "Line $LineCounter: $Line\n";
        }
    }

    return if !$ErrorLines;

    my $Message = <<'EOF';
The new CKEditor API uses a method to list all instances.

Change this:
var Instances = CKEDITOR.instances;

To this:
var Instances = Core.UI.RichTextEditor.ListAllInstances();
EOF

    $Message .= "\n$ErrorLines";

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'warning',
    );

    return;
}

1;