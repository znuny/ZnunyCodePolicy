# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Simple function translation, invalid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
[% Translate("Hello, world!") %]
EOF
        ExpectedMessageSubstring => 'Found unfiltered translation string',
    },
    {
        Name     => 'Simple function translation with HTML filter, valid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
[% Translate("Hello, world!") | html %]
EOF
    },
    {
        Name     => 'Simple function translation with JSON filter, valid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
[% Translate("Hello, world!") | JSON %]
EOF
    },
    {
        Name     => 'Variable function translation, invalid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
[% Translate(Data.Language) %]
EOF
        ExpectedMessageSubstring => 'Found unfiltered translation string',
    },
    {
        Name     => 'Variable function translation, valid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
[% Translate(Data.Language) | html %]
EOF
    },
    {
        Name     => 'Complex function translation, invalid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
&ndash; <span title="[% Translate("Created") %]: [% Data.CreateTime | Localize("TimeShort") %]">[% Data.CreateTime | Localize("TimeShort") %]</span> [% Translate("via %s", Translate(Data.CommunicationChannel)) | html %]
EOF
        ExpectedMessageSubstring => 'Found unfiltered translation string',
    },
    {
        Name     => 'Complex function translation, valid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
&ndash; <span title="[% Translate("Created") | html %]: [% Data.CreateTime | Localize("TimeShort") %]">[% Data.CreateTime | Localize("TimeShort") %]</span> [% Translate("via %s", Translate(Data.CommunicationChannel)) | html %]
EOF
    },
    {
        Name     => 'Function translation with placeholder, invalid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
<a href="[% Env("Baselink") %]Action=AdminOTRSBusiness" class="Button"><i class="fa fa-angle-double-up"></i> [% Translate("Upgrade to %s", OTRSBusinessLabel) %]</a>
EOF
        ExpectedMessageSubstring => 'Found unfiltered translation string',
    },
    {
        Name     => 'Function translation with placeholder, valid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
<a href="[% Env("Baselink") %]Action=AdminOTRSBusiness" class="Button"><i class="fa fa-angle-double-up"></i> [% Translate("Upgrade to %s") | html | ReplacePlaceholders(OTRSBusinessLabel) %]</a>
EOF
    },
    {
        Name     => 'Function translation with placeholders, invalid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
[% Translate('This system uses the %s without a proper license! Please make contact with %s to renew or activate your contract!', OTRSBusinessLabel, '<a href="mailto:sales@otrs.com">sales@otrs.com</a>') %]
EOF
        ExpectedMessageSubstring => 'Found unfiltered translation string',
    },
    {
        Name     => 'Function translation with placeholders, valid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
[% Translate('This system uses the %s without a proper license! Please make contact with %s to renew or activate your contract!') | html | ReplacePlaceholders(OTRSBusinessLabel, '<a href="mailto:sales@otrs.com">sales@otrs.com</a>') %]
EOF
    },
    {
        Name     => 'Function translation with no spaces, invalid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
<button class="Primary CallForAction" type="submit" value="[%Translate("Add")%]"><span>[% Translate("Add") | html %]</span></button>
EOF
        ExpectedMessageSubstring => 'Found unfiltered translation string',
    },
    {
        Name     => 'Function translation with no spaces, valid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
<button class="Primary CallForAction" type="submit" value="[%Translate("Add")|html%]"><span>[% Translate("Add") | html %]</span></button>
EOF
    },
    {
        Name     => 'Filter translation, invalid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
<span title="[% Translate(Data.Content) | html %]">[% Data.Content | Translate | truncate(Data.MaxLength) %]</span>
EOF
        ExpectedMessageSubstring => 'Found unfiltered translation string',
    },
    {
        Name     => 'Filter translation, valid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
<span title="[% Translate(Data.Content) | html %]">[% Data.Content | Translate | truncate(Data.MaxLength) | html %]</span>
EOF
    },
    {
        Name     => 'Second filter translation, invalid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
var Message = [% Data.CustomerRegExErrorMessageServerErrorMessage | Translate %];
EOF
        ExpectedMessageSubstring => 'Found unfiltered translation string',
    },
    {
        Name     => 'Second filter translation, valid',
        Filename => 'Template.tt',
        Plugins  => [qw(TidyAll::Plugin::Znuny::TT::TranslationFilter)],
        Source   => <<'EOF',
var Message = [% Data.CustomerRegExErrorMessageServerErrorMessage | Translate | JSON %];
EOF
    },

);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
