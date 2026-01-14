# --
# Copyright (C) 2012-2024 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package TidyAll::Plugin::Znuny::Perl::UUID;

use strict;
use warnings;

use parent qw(TidyAll::Plugin::Znuny::Perl);

=head1 SYNOPSIS

This plugin checks for direct usage of Data::UUID methods and recommends
using the new Util::CreateUUIDString function instead.

=cut

sub validate_source {
    my ( $Self, $Code ) = @_;

    return if $Self->IsPluginDisabled( Code => $Code );

    my $ErrorMessage = '';
    my $Counter = 0;

    LINE:
    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        next LINE if $Line =~ m/^\s*\#/smx;

        # Check for direct Data::UUID usage
        if ( $Line =~ m{
            (?:
                Data::UUID->new\(\)->create_str\(\)        |  # Data::UUID->new()->create_str()
                Data::UUID::create_str                     |  # Data::UUID::create_str
                \$.*?UUID.*?->create_str\(\)               |  # $UUIDObject->create_str()
                use\s+Data::UUID                           |  # use Data::UUID
                ->create_str\(\)                              # any ->create_str()
            )
        }xmsi ) {

            $ErrorMessage .= "Line $Counter: $Line\n";
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage(<<"EOF");
Found direct usage of Data::UUID methods.
Please use Util::CreateUUIDString() instead for consistent UUID generation.

Example:
  # Instead of:
  my \$UUID = Data::UUID->new()->create_str();
  my \$UUID = \$UUIDObject->create_str();

  # Use:
  my \$UUID = \$Kernel::OM->Get('Kernel::System::Util')->CreateUUIDString();

Lines with issues:
$ErrorMessage
EOF
    }

    return;
}

1;
