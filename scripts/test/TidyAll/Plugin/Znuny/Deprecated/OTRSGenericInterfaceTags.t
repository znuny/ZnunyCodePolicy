# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Deprecated::OTRSGenericInterfaceTags)
## no critic (RequireExplicitPackage)

use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::TidyAll::Plugin::Znuny;

my @Tests = (
    {
        Name     => 'Keep OTRS_* tags below Znuny 7.5',
        Filename => 'scripts/webservices/Example.yml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSGenericInterfaceTags)],
        Settings => {
            'Framework::Version' => '7.4.1',
        },
        Source => <<'EOF',
      AdditionalHeaders:
        Authorization: Bearer <OTRS_OAUTH2_TOKEN>
EOF
        ExpectedSource => <<'EOF',
      AdditionalHeaders:
        Authorization: Bearer <OTRS_OAUTH2_TOKEN>
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename config, JWT and OAuth2 placeholders',
        Filename => 'scripts/webservices/Example.yml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSGenericInterfaceTags)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
      AdditionalHeaders:
        Authorization: Bearer <OTRS_OAUTH2_TOKEN>
        X-JWT: <OTRS_JWT>
        X-Host: <OTRS_CONFIG_FQDN>
      JWTAuthPayload:
        exp: <OTRS_JWT_ExpirationDateTimestamp>
        sub: <OTRS_JWT_CertSubject>
EOF
        ExpectedSource => <<'EOF',
      AdditionalHeaders:
        Authorization: Bearer <ZNUNY_OAUTH2_TOKEN>
        X-JWT: <ZNUNY_JWT>
        X-Host: <ZNUNY_CONFIG_FQDN>
      JWTAuthPayload:
        exp: <ZNUNY_JWT_ExpirationDateTimestamp>
        sub: <ZNUNY_JWT_CertSubject>
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename HTML escaped config placeholder in XSLT template',
        Filename => 'scripts/webservices/Example.yml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSGenericInterfaceTags)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
            <url>&lt;OTRS_CONFIG_HttpType&gt;://&lt;OTRS_CONFIG_FQDN&gt;/</url>
EOF
        ExpectedSource => <<'EOF',
            <url>&lt;ZNUNY_CONFIG_HttpType&gt;://&lt;ZNUNY_CONFIG_FQDN&gt;/</url>
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Rename response tags of invoker Ticket::Generic',
        Filename => 'scripts/webservices/Example.yml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSGenericInterfaceTags)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
      MappingInbound:
        Config:
          KeyMapExact:
            Title: OTRS_TicketTitleUpdate
            State: OTRS_TicketStateSet
            Field: OTRS_TicketDynamicFieldSet_Field
            Async: OTRS_AsynchronousInvokerExecution
        Type: Simple
      Type: Ticket::Generic
EOF
        ExpectedSource => <<'EOF',
      MappingInbound:
        Config:
          KeyMapExact:
            Title: ZNUNY_TicketTitleUpdate
            State: ZNUNY_TicketStateSet
            Field: ZNUNY_TicketDynamicFieldSet_Field
            Async: ZNUNY_AsynchronousInvokerExecution
        Type: Simple
      Type: Ticket::Generic
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Keep response tags without invoker Ticket::Generic',
        Filename => 'scripts/webservices/Example.yml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSGenericInterfaceTags)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
            Title: OTRS_TicketTitleUpdate
      Type: Custom::Invoker
EOF
        ExpectedSource => <<'EOF',
            Title: OTRS_TicketTitleUpdate
      Type: Custom::Invoker
EOF
        ExpectedMessageSubstring => undef,
    },
    {
        Name     => 'Keep smart tags without ZNUNY_* alias',
        Filename => 'scripts/webservices/Example.yml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::Deprecated::OTRSGenericInterfaceTags)],
        Settings => {
            'Framework::Version' => '7.5.1',
        },
        Source => <<'EOF',
            Subject: <OTRS_TICKET_Title> <OTRS_Ticket_DynamicField_Field> <OTRS_CUSTOMER_Body>
            Name: OTRS_TicketCreateCustom
      Type: Ticket::Generic
EOF
        ExpectedSource => <<'EOF',
            Subject: <OTRS_TICKET_Title> <OTRS_Ticket_DynamicField_Field> <OTRS_CUSTOMER_Body>
            Name: OTRS_TicketCreateCustom
      Type: Ticket::Generic
EOF
        ExpectedMessageSubstring => undef,
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
