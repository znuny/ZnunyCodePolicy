# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::RichTextEditor::ZnunyEditor;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head2 ZnunyEditor()

This plugin validates and warns about global CKEDITOR object usage.

It checks for:

    typeof CKEDITOR
    # To this:
    typeof ZnunyEditor

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

        # Check for CKEDITOR reference (but not CKEDITOR.instances which is handled by GetInstance.pm)
        if ( $Line =~ m{\bCKEDITOR\b} && $Line !~ m{CKEDITOR\.instances} ) {
            $ErrorLines .= "Line $LineCounter: $Line\n";
        }
    }

    return if !$ErrorLines;

    my $Message = <<'EOF';
The global CKEDITOR object is no longer used in the new CKEditor API.

Change this:
CKEDITOR

To this:
ZnunyEditor
EOF

    $Message .= "\n$ErrorLines";

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'warning',
    );

    return;
}

1;