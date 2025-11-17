# --
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package TidyAll::Plugin::Znuny::RichTextEditor::Events;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Base);

=head2 Events()

This plugin validates and warns about old CKEditor event handling patterns.

Supported events:

- key
- keyup
- blur
- paste
- clipboardOutput
- contentDom click
- focus

It checks for:

    # key
    CKEDITOR.instances['InstanceName'].on('key', function (Event) {
    # To this:
    Core.UI.RichTextEditor.GetInstance('InstanceName').editing.view.document.on('keyup', function (Event, Data) {


    # keyup
    CKEDITOR.instances['InstanceName'].document.on('keyup', function () {
    # To this:
    Core.UI.RichTextEditor.GetInstance('InstanceName').editing.view.document.on('keyup', function () {


    # blur
    CKEDITOR.instances['InstanceName'].on('blur', function (Event) {
    # To this:
    Core.App.Subscribe("Event.UI.RichTextEditor.Blur", function () {


    # paste
    CKEDITOR.instances['InstanceName'].on('paste', function () {
    # To this:
    Core.UI.RichTextEditor.GetInstance('InstanceName').editing.view.document.on('clipboardOutput', function (Event, Data) {


    # focus
    Core.UI.RichTextEditor.GetInstance('InstanceName').on('focus', function () {
    # To this:
    Core.App.Subscribe('Event.UI.RichTextEditor.Focus', function(ZnunyEditor) {

    TODO: Not implemented yet

    # contentDom click
    CKEDITOR.instances['RichText'].on('contentDom', function() {
        CKEDITOR.instances['RichText'].document.on('click', function () {
    Core.UI.RichTextEditor.GetInstance('RichText').on('contentDom', function() {
        Core.UI.RichTextEditor.GetInstance('RichText').document.on('click', function () {
    # To this
    Core.UI.RichTextEditor.GetInstance('RichText').editing.view.document.on('clipboardOutput', function (Event, Data) {

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

        # Check for old event patterns
        if ( $Line =~ m{CKEDITOR\.instances\[.*?\]\.on\('key'} ) {
            $ErrorLines .= "Line $LineCounter: $Line\n";
            next LINE;
        }
        if ( $Line =~ m{CKEDITOR\.instances\[.*?\]\.document\.on\('keyup'} ) {
            $ErrorLines .= "Line $LineCounter: $Line\n";
            next LINE;
        }
        if ( $Line =~ m{CKEDITOR\.instances\[.*?\]\.on\('blur'} ) {
            $ErrorLines .= "Line $LineCounter: $Line\n";
            next LINE;
        }
        if ( $Line =~ m{CKEDITOR\.instances\[.*?\]\.on\('paste'} ) {
            $ErrorLines .= "Line $LineCounter: $Line\n";
            next LINE;
        }
        if ( $Line =~ m{Core\.UI\.RichTextEditor\.GetInstance\(.*?\)\.on\('focus'} ) {
            $ErrorLines .= "Line $LineCounter: $Line\n";
            next LINE;
        }
        if ( $Line =~ m{Core\.UI\.RichTextEditor\.GetInstance\(.*?\)\.document\.on\('click'} ) {
            $ErrorLines .= "Line $LineCounter: $Line\n";
            next LINE;
        }
        if ( $Line =~ m{CKEDITOR\.instances\[.*?\]\.on\('contentDom'} ) {
            $ErrorLines .= "Line $LineCounter: $Line\n";
            next LINE;
        }
    }

    return if !$ErrorLines;

    my $Message = <<'EOF';
The new CKEditor API uses different event handling patterns.

Supported events and their migrations:
- key: Use Core.UI.RichTextEditor.GetInstance('Name').editing.view.document.on('keyup', function (Event, Data) {
- keyup: Use Core.UI.RichTextEditor.GetInstance('Name').editing.view.document.on('keyup', function () {
- blur: Use Core.App.Subscribe("Event.UI.RichTextEditor.Blur", function () {
- paste: Use Core.UI.RichTextEditor.GetInstance('Name').editing.view.document.on('clipboardOutput', function (Event, Data) {
- focus: Use Core.App.Subscribe('Event.UI.RichTextEditor.Focus', function(ZnunyEditor) {
- contentDom click: Use Core.UI.RichTextEditor.GetInstance('Name').editing.view.document.on('click', function () {
EOF

    $Message .= "\n$ErrorLines";

    $Self->AddMessage(
        Message  => $Message,
        Priority => 'warning',
    );

    return;
}

1;