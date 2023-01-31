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
        Name     => 'Valid database XML',
        Filename => 'otrs-schema.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::XSDValidator)],
        Source   => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <Unique Name="dynamic_field_object_name">
        <UniqueColumn Name="object_name"/>
        <UniqueColumn Name="object_type"/>
    </Unique>
</Table>
EOF
    },
    {
        Name     => 'Inalid database XML',
        Filename => 'otrs-schema.xml',
        Plugins  => [qw(TidyAll::Plugin::Znuny::XML::Database::XSDValidator)],
        Source   => <<"EOF",
<Table Name="dynamic_field_obj_id_name">
    <InvalidElement/>
</Table>
EOF
        ExpectedMessageSubstring => 'element InvalidElement: Schemas validity error',
    },
);

$Self->scripts::test::TidyAll::Plugin::Znuny::Run( Tests => \@Tests );

1;
