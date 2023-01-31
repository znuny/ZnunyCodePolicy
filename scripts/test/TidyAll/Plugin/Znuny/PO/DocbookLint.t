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
        Name     => 'PO::DocbookLint, valid docbook',
        Filename => 'doc-admin-test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::PO::DocbookLint)],
        Source   => <<'EOF',
msgid "Yes <link linkend=\"123\">this</link> works"
msgstr "Ja <link linkend=\"123\">das</link> funktioniert"
EOF
    },
    {
        Name     => 'PO::DocbookLint, valid docbook (ignored tag missing)',
        Filename => 'doc-admin-test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::PO::DocbookLint)],
        Source   => <<'EOF',
msgid "Yes <emphasis>this</emphasis> works"
msgstr "Ja das funktioniert"
EOF
    },
    {
        Name     => 'PO::DocbookLint, invalid docbook (invalid xml)',
        Filename => 'doc-admin-test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::PO::DocbookLint)],
        Source   => <<'EOF',
msgid "Yes <link linkend=\"123\">this</link> works"
msgstr "Ja <link linkend=\"123\">das</link> funktioniert <extratag unclosed>"
EOF
        ExpectedMessageSubstring => 'Invalid XML translation found',
    },
    {
        Name     => 'PO::DocbookLint, invalid docbook (missing tags)',
        Filename => 'doc-admin-test.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::PO::DocbookLint)],
        Source   => <<'EOF',
msgid "<placeholder type=\"screeninfo\" id=\"0\"/> <graphic srccredit=\"process-"
"management - screenshot\" scale='40' fileref=\"screenshots/pm-accordion-new-"
"transition.png\"></graphic>"
msgstr "Falsch übersetzt"
EOF
        ExpectedMessageSubstring => 'Invalid XML translation found',
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
