# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
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
        Name     => 'PO::HTMLTags, valid bold tag',
        Filename => 'otrs.de.po',
        Plugins  => [qw(TidyAll::Plugin::Znuny::PO::HTMLTags)],
        Source   => <<'EOF',
msgid "String with <b>tag</b>"
msgstr "Zeichenkette mit <b>Tag</b>"
EOF
    },
    {
        Name     => 'PO::HTMLTags, forbidden script tag',
        Filename => 'otrs.de.po',
        Plugins  => [qw(TidyAll::Plugin::Znuny::PO::HTMLTags)],
        Source   => <<'EOF',
msgid "String with <sCrIpT>evil tag</script>"
msgstr "Zeichenkette mit <script>bösem Tag</script>"
EOF
        ExpectedMessageSubstring => 'Invalid HTML tags found',
    },
    {
        Name      => 'PO::HTMLTags, valid paragraph tag',
        Filename  => 'otrs.pot',
        Plugins   => [qw(TidyAll::Plugin::Znuny::PO::HTMLTags)],
        Framework => '6.0',
        Source    => <<'EOF',
msgid "<p>Paragraph string</p>"
msgstr ""
EOF
    },
    {
        Name     => 'PO::HTMLTags, forbidden meta tag',
        Filename => 'otrs.pot',
        Plugins  => [qw(TidyAll::Plugin::Znuny::PO::HTMLTags)],
        Source   => <<'EOF',
msgid "Redirecting now... <META http-equiv=\"refresh\" content=\"0; url=http://example.com/\">"
msgstr ""
EOF
        ExpectedMessageSubstring => 'Invalid HTML tags found',
    },
    {
        Name     => 'PO::HTMLTags, paragraph tag with forbidden attribute',
        Filename => 'otrs.pot',
        Plugins  => [qw(TidyAll::Plugin::Znuny::PO::HTMLTags)],
        Source   => <<'EOF',
msgid "<p onmouseover=\"alert(1);\">Paragraph string</p>"
msgstr ""
EOF
        ExpectedMessageSubstring => 'Invalid HTML tags found',
    },
    {
        Name     => 'PO::HTMLTags, anchor tag with forbidden attributes',
        Filename => 'otrs.pot',
        Plugins  => [qw(TidyAll::Plugin::Znuny::PO::HTMLTags)],
        Source   => <<'EOF',
msgid "<a href=\"https://evil.com/danger.php\" style=\"color:red\">No more space on device! OTRS will stop. Click here for details.</a>"
msgstr ""
EOF
        ExpectedMessageSubstring => 'Invalid HTML tags found',
    },
    {
        Name     => 'PO::HTMLTags, link tag with forbidden attributes',
        Filename => 'otrs.pot',
        Plugins  => [qw(TidyAll::Plugin::Znuny::PO::HTMLTags)],
        Source   => <<'EOF',
msgid "foo<link href=\"https://evil.com/danger.php\" rel=\"stylesheet\">bar"
msgstr ""
EOF
        ExpectedMessageSubstring => 'Invalid HTML tags found',
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
