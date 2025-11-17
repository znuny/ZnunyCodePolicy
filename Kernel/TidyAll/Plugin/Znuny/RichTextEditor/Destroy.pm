# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::RichTextEditor::Destroy;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head2 Destroy()

This plugin validates and warns about old CKEDITOR.instances usage.

Destroy all instances of CKEDITOR
specific in Core.Agent.TicketProcess.js

It checks for:

    if (typeof CKEDITOR !== 'undefined' && CKEDITOR.instances) {
        $.each(CKEDITOR.instances, function (Key) {
            CKEDITOR.instances[Key].destroy();
        });
    }

    # To this:

    Core.UI.RichTextEditor.DestroyAllInstances().then(function(){
        // some code after destroy...
    }
    .catch(function(error){
        console.error('Error while destroying CKEditor instances:', error);
    }));

# Destroy single instance
# specific in Znuny.Form.Input.js

It checks for:

    var EditorID = $(this).attr('id');
    var Editor   = CKEDITOR.instances[EditorID];
    if (!Editor) return true;
    $(this).removeClass('HasCKEInstance');
    Editor.destroy(true);
    Core.UI.RichTextEditor.DestroyInstance(EditorID)

    # To this:

    var EditorID = $(this).attr('id');
    Core.UI.RichTextEditor.DestroyInstance(EditorID).then(function(){
        // some code after destroy...
    }.catch(function(error){
        console.error('Error while destroying CKEditor instance:', error);
    }));

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );
    return if $Self->IsFrameworkVersionLessThan('7.2');


    my $LineCounter = 0;
    my $ErrorLines  = '';

    # Check for "destroy all instances" pattern
    if ( $Code =~ /if\s*\(\s*typeof\s+CKEDITOR\s*!==\s*['"]undefined['"]\s*(?:&&\s*CKEDITOR)?\s*&&\s*CKEDITOR\.instances\s*\)\s*\{.*?\$\.each\(CKEDITOR\.instances,\s*function\s*\([^)]*\)\s*\{.*?CKEDITOR\.instances\[[^\]]+\]\.destroy\(\).*?\}\).*?\}/s ) {
        $ErrorLines .= "Found CKEDITOR destroy all instances pattern. Use Core.UI.RichTextEditor.DestroyAllInstances() instead.\n";
    }

    # Check for "destroy single instance" pattern
    if ( $Code =~ /var\s+EditorID\s*=\s*\$\(this\)\.attr\('id'\);\s*var\s+Editor\s*=\s*CKEDITOR\.instances\[EditorID\]/s ) {
        $ErrorLines .= "Found CKEDITOR destroy single instance pattern. Use Core.UI.RichTextEditor.DestroyInstance(EditorID) instead.\n";
    }

    # Check for direct CKEDITOR.instances usage
    LINE:
    for my $Line ( split "\n", $Code ) {
        $LineCounter++;

        # Check for direct CKEDITOR.instances access
        if ( $Line =~ /CKEDITOR\.instances\[/ && $Line !~ /Core\.UI\.RichTextEditor/ ) {
            $ErrorLines .= "Line $LineCounter: Found direct CKEDITOR.instances access. Consider using Core.UI.RichTextEditor methods.\n";
        }
    }

    return if !$ErrorLines;

    my $Message = <<'EOF';
The new CKEditor API uses a method to destroy all instances.

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