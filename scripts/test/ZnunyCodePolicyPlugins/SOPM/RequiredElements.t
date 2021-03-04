# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
use strict;
use warnings;

use vars (qw($Self));
use utf8;

use scripts::test::ZnunyCodePolicyPlugins;

my @Tests = (
#     {
#         Name      => 'Minimal valid SOPM.',
#         Filename  => 'Test.pm',
#         Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
#         Framework => '7.0',
#         Source    => <<'EOF',
# <?xml version="1.0" encoding="utf-8" ?>
# <otrs_package version="1.0">
#     <Name>ZnunyCodePolicy</Name>
#     <Version>0.0.0</Version>
#     <Framework>7.0.x</Framework>
#     <Vendor>Znuny GmbH</Vendor>
#     <URL>https://znuny.com/</URL>
#     <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
#     <Description Lang="en" Translatable="1">OTRS code quality checks.</Description>
#     <PackageIsDownloadable>0</PackageIsDownloadable>
#     <PackageIsBuildable>0</PackageIsBuildable>
#     <Filelist>
#         <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
#     </Filelist>
# </otrs_package>
# EOF
#         Exception => 0,
#     },
#     {
#         Name      => 'Missing name.',
#         Filename  => 'Test.pm',
#         Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
#         Framework => '7.0',
#         Source    => <<'EOF',
# <?xml version="1.0" encoding="utf-8" ?>
# <otrs_package version="1.0">
#     <Version>0.0.0</Version>
#     <Framework>7.0.x</Framework>
#     <Vendor>Znuny GmbH</Vendor>
#     <URL>https://znuny.com/</URL>
#     <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
#     <Description Lang="en">OTRS code quality checks.</Description>
#     <Filelist>
#         <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
#     </Filelist>
# </otrs_package>
# EOF
#         Exception => 1,
#         STDOUT    => 'TidyAll::Plugin::Znuny::SOPM::RequiredElements
# You have forgotten to use the element <Name>!
# ',
#     },
#     {
#         Name      => 'Missing description.',
#         Filename  => 'Test.pm',
#         Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
#         Framework => '7.0',
#         Source    => <<'EOF',
# <?xml version="1.0" encoding="utf-8" ?>
# <otrs_package version="1.0">
#     <Name>ZnunyCodePolicy</Name>
#     <Version>0.0.0</Version>
#     <Framework>7.0.x</Framework>
#     <Vendor>Znuny GmbH</Vendor>
#     <URL>https://znuny.com/</URL>
#     <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
#     <Filelist>
#         <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
#     </Filelist>
# </otrs_package>
# EOF
#         Exception => 1,
#         STDOUT    => 'TidyAll::Plugin::Znuny::SOPM::RequiredElements
# You have forgotten to use the element <Description Lang="en">!
# ',
#     },
#     {
#         Name      => 'Missing version.',
#         Filename  => 'Test.pm',
#         Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
#         Framework => '7.0',
#         Source    => <<'EOF',
# <?xml version="1.0" encoding="utf-8" ?>
# <otrs_package version="1.0">
#     <Name>ZnunyCodePolicy</Name>
#     <Framework>7.0.x</Framework>
#     <Vendor>Znuny GmbH</Vendor>
#     <URL>https://znuny.com/</URL>
#     <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
#     <Description Lang="en">OTRS code quality checks.</Description>
#     <Filelist>
#         <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
#     </Filelist>
# </otrs_package>
# EOF
#         Exception => 1,
#         STDOUT    => 'TidyAll::Plugin::Znuny::SOPM::RequiredElements
# You have forgotten to use the element <Version>!
# ',
#     },
#     {
#         Name      => 'Missing framework.',
#         Filename  => 'Test.pm',
#         Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
#         Framework => '7.0',
#         Source    => <<'EOF',
# <?xml version="1.0" encoding="utf-8" ?>
# <otrs_package version="1.0">
#     <Name>ZnunyCodePolicy</Name>
#     <Version>0.0.0</Version>
#     <Vendor>Znuny GmbH</Vendor>
#     <URL>https://znuny.com/</URL>
#     <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
#     <Description Lang="en">OTRS code quality checks.</Description>
#     <Filelist>
#         <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
#     </Filelist>
# </otrs_package>
# EOF
#         Exception => 1,
#         STDOUT    => 'TidyAll::Plugin::Znuny::SOPM::RequiredElements
# You have forgotten to use the element <Framework>!
# ',
#     },
#     {
#         Name      => 'Missing vendor.',
#         Filename  => 'Test.pm',
#         Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
#         Framework => '7.0',
#         Source    => <<'EOF',
# <?xml version="1.0" encoding="utf-8" ?>
# <otrs_package version="1.0">
#     <Name>ZnunyCodePolicy</Name>
#     <Version>0.0.0</Version>
#     <Framework>7.0.x</Framework>
#     <URL>https://znuny.com/</URL>
#     <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
#     <Description Lang="en">OTRS code quality checks.</Description>
#     <Filelist>
#         <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
#     </Filelist>
# </otrs_package>
# EOF
#         Exception => 1,
#         STDOUT    => 'TidyAll::Plugin::Znuny::SOPM::RequiredElements
# You have forgotten to use the element <Vendor>!
# ',
#     },
#     {
#         Name      => 'Missing URL.',
#         Filename  => 'Test.pm',
#         Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
#         Framework => '7.0',
#         Source    => <<'EOF',
# <?xml version="1.0" encoding="utf-8" ?>
# <otrs_package version="1.0">
#     <Name>ZnunyCodePolicy</Name>
#     <Version>0.0.0</Version>
#     <Framework>7.0.x</Framework>
#     <Vendor>Znuny GmbH</Vendor>
#     <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
#     <Description Lang="en">OTRS code quality checks.</Description>
#     <Filelist>
#         <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
#     </Filelist>
# </otrs_package>
# EOF
#         Exception => 1,
#         STDOUT    => 'TidyAll::Plugin::Znuny::SOPM::RequiredElements
# You have forgotten to use the element <URL>!
# ',
#     },
#     {
#         Name      => 'Missing license.',
#         Filename  => 'Test.pm',
#         Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
#         Framework => '7.0',
#         Source    => <<'EOF',
# <?xml version="1.0" encoding="utf-8" ?>
# <otrs_package version="1.0">
#     <Name>ZnunyCodePolicy</Name>
#     <Version>0.0.0</Version>
#     <Framework>7.0.x</Framework>
#     <Vendor>Znuny GmbH</Vendor>
#     <URL>https://znuny.com/</URL>
#     <Description Lang="en">OTRS code quality checks.</Description>
#     <Filelist>
#         <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
#     </Filelist>
# </otrs_package>
# EOF
#         Exception => 1,
#         STDOUT    => 'TidyAll::Plugin::Znuny::SOPM::RequiredElements
# You have forgotten to use the element <License>!
# ',
#     },
    {
        Name      => 'Invalid content for PackageIsDownloadable flag.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>ZnunyCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Znuny GmbH</Vendor>
    <URL>https://znuny.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <PackageIsDownloadable>test</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
        STDOUT    => 'TidyAll::Plugin::Znuny::SOPM::RequiredElements
You have forgotten to use the element <PackageIsDownloadable>!
',
    },
    {
        Name      => 'ZnunyCodePolicy - missing PackageIsDownloadable + PackageIsBuildable.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>ZnunyCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Znuny GmbH</Vendor>
    <URL>https://znuny.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
        STDOUT    => 'TidyAll::Plugin::Znuny::SOPM::RequiredElements
You have forgotten to use the element <PackageIsDownloadable>!
You have forgotten to use the element <PackageIsBuildable>!
',
    },
    {
        Name      => 'ZnunyCodePolicy - valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>ZnunyCodePolicy</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Znuny GmbH</Vendor>
    <URL>https://znuny.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'ITSMIncidentProblemManagement - missing PackageIsDownloadable + PackageIsBuildable.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>ITSMIncidentProblemManagement</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Znuny GmbH</Vendor>
    <URL>https://znuny.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
        STDOUT    =>  'TidyAll::Plugin::Znuny::SOPM::RequiredElements
You have forgotten to use the element <PackageIsDownloadable>!
You have forgotten to use the element <PackageIsBuildable>!
',
    },
    {
        Name      => 'ITSMIncidentProblemManagement - valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>ITSMIncidentProblemManagement</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Znuny GmbH</Vendor>
    <URL>https://znuny.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'TimeAccounting - missing PackageIsDownloadable + PackageIsBuildable.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>TimeAccounting</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Znuny GmbH</Vendor>
    <URL>https://znuny.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
        STDOUT    =>  'TidyAll::Plugin::Znuny::SOPM::RequiredElements
You have forgotten to use the element <PackageIsDownloadable>!
You have forgotten to use the element <PackageIsBuildable>!
',
    },
    {
        Name      => 'TimeAccounting - valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>TimeAccounting</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Znuny GmbH</Vendor>
    <URL>https://znuny.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'OTRSSTORM - missing PackageIsDownloadable + PackageIsBuildable.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSSTORM</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Znuny GmbH</Vendor>
    <URL>https://znuny.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 1,
        STDOUT    => 'TidyAll::Plugin::Znuny::SOPM::RequiredElements
You have forgotten to use the element <PackageIsDownloadable>!
You have forgotten to use the element <PackageIsBuildable>!
',
    },
    {
        Name      => 'OTRSSTORM - valid SOPM.',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>OTRSSTORM</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Znuny GmbH</Vendor>
    <URL>https://znuny.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <PackageIsDownloadable>0</PackageIsDownloadable>
    <PackageIsBuildable>0</PackageIsBuildable>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 0,
    },
    {
        Name      => 'Test123 - valid SOPM (no restricted package).',
        Filename  => 'Test.pm',
        Plugins   => [qw(TidyAll::Plugin::Znuny::SOPM::RequiredElements)],
        Framework => '7.0',
        Source    => <<'EOF',
<?xml version="1.0" encoding="utf-8" ?>
<otrs_package version="1.0">
    <Name>Test123</Name>
    <Version>0.0.0</Version>
    <Framework>7.0.x</Framework>
    <Vendor>Znuny GmbH</Vendor>
    <URL>https://znuny.com/</URL>
    <License>GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007</License>
    <Description Lang="en">OTRS code quality checks.</Description>
    <Filelist>
        <File Permission="755" Location="bin/otrs.CodePolicy.pl" />
    </Filelist>
</otrs_package>
EOF
        Exception => 0,
    },
);

$Self->scripts::test::ZnunyCodePolicyPlugins::Run( Tests => \@Tests );

1;
