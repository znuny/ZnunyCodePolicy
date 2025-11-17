# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::RichTextEditor::Editable;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);


=head2 Editable()

This plugin validates and warns about old CKEditor editable selectors.

It checks for

    $('body.cke_editable', $('.cke_wysiwyg_frame'))"
    # To this:
    $('.ck-editor__editable');"

    $('body.cke_editable', $('.cke_wysiwyg_frame').contents())
    # To this:
    $('.ck-editor__editable').contents();"

    $('body.cke_editable', $('.cke_wysiwyg_frame').contents()).length == 1
    # To this:
    $('.ck-editor__editable').contents().length == 1

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

        # Skip line if it contains NONE of the problematic patterns
        next LINE if $Line !~ m{body\.cke_editable} && $Line !~ m{cke_wysiwyg_frame};

        $ErrorLines .= "Line $LineCounter: $Line\n";
    }

    return if !$ErrorLines;

    my $Message = <<'EOF';
The new CKEditor API no longer uses the old '.cke_editable' | 'cke_wysiwyg_frame' selector.

Change this:
$('body.cke_editable', $('.cke_wysiwyg_frame').contents()

To this:
$('.ck-editor__editable').contents()
EOF

    $Message .= "\n$ErrorLines";

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'warning',
    );

    return;
}

1;