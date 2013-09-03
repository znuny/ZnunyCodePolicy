package TidyAll::Plugin::OTRS::Perl::UseWarnings;

use strict;
use warnings;

use File::Basename;

use base qw(TidyAll::Plugin::OTRS::Base);

# Perl::Critic will make sure that use strict is enabled.
# Now we check that use warnings is also.
sub transform_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled(Code => $Code);
    #return $Code if ($Self->IsFrameworkVersionLessThan(3, 3));

    # Check if use warnings is present, otherwise add it
    if ( $Code !~ m{^[ \t]*use\s+warnings;}mx ) {
        $Code =~ s{^[ \t]*use\s+strict;}{use strict;\nuse warnings;}mx;
    }

    return $Code;
}

1;
