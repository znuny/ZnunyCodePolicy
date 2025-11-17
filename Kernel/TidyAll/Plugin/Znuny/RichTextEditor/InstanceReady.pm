# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::RichTextEditor::InstanceReady;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head2 InstanceReady()

This plugin validates and warns about old CKEDITOR type checks.

It checks for:

    if (typeof CKEDITOR !== 'undefined' && CKEDITOR && CKEDITOR.instances.RichText) {
    # To this:
    if (typeof ZnunyEditor !== 'undefined' && ZnunyEditor ? Core.UI.RichTextEditor.GetInstance('RichText') : null) {

    if (typeof CKEDITOR !== 'undefined' && CKEDITOR && CKEDITOR.instances['RichText']) {
    # To this:
    if (typeof ZnunyEditor !== 'undefined' && ZnunyEditor ? Core.UI.RichTextEditor.GetInstance('RichText') : null) {

    if (typeof CKEDITOR !== 'undefined' && CKEDITOR && CKEDITOR.instances[Editor]) {
    # To this:
    if (typeof ZnunyEditor !== 'undefined' && ZnunyEditor ? Core.UI.RichTextEditor.GetInstance(Editor) : null) {

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

        # Check for CKEDITOR type check patterns
        if ( $Line =~ m{typeof\s+CKEDITOR\s*!==\s*'undefined'} && $Line =~ m{CKEDITOR\.instances} ) {
            $ErrorLines .= "Line $LineCounter: $Line\n";
        }
    }

    return if !$ErrorLines;

    my $Message = <<'EOF';
The new CKEditor API uses event subscriptions instead of type checks.

Change this:
if (typeof CKEDITOR !== 'undefined' && CKEDITOR && CKEDITOR.instances['RichText']) {

To this:
Core.App.Subscribe('Event.UI.RichTextEditor.InstanceReady', function() {
    if (Core.UI.RichTextEditor.GetInstance('RichText')) {
EOF

    $Message .= "\n$ErrorLines";

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'warning',
    );

    return;
}

1;