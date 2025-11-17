# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::RichTextEditor::GetInstance;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head2 GetInstance()

This plugin validates and warns about old CKEDITOR.instances usage.

It checks for:

    CKEDITOR.instances.InstanceName
    # To this:
    Core.UI.RichTextEditor.GetInstance('InstanceName')

    CKEDITOR.instances['InstanceName']
    # To this:
    Core.UI.RichTextEditor.GetInstance('InstanceName')

    CKEDITOR.instances[InstanceName]
    # To this:
    Core.UI.RichTextEditor.GetInstance(InstanceName)
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

        # Check for CKEDITOR.instances patterns
        if ( $Line =~ m{CKEDITOR\.instances} ) {
            $ErrorLines .= "Line $LineCounter: $Line\n";
        }
    }

    return if !$ErrorLines;

    my $Message = <<'EOF';
The new CKEditor API no longer uses CKEDITOR.instances.

Change this:
CKEDITOR.instances.**InstanceName**
or
CKEDITOR.instances['**InstanceName**']

To this:
Core.UI.RichTextEditor.GetInstance('**InstanceName**')
EOF

    $Message .= "\n$ErrorLines";

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'warning',
    );

    return;
}

1;