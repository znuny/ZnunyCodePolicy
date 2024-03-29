# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012-2022 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Perl::Critic::Policy::Znuny::RequireLabels;

use strict;
use warnings;

use Perl::Critic::Utils qw{};
use parent 'Perl::Critic::Policy';

my $Description = q{Please always use 'next' and 'last' with a label.};
my $Explanation = q{};

sub supported_parameters { return; }
sub default_severity     { return $Perl::Critic::Utils::SEVERITY_HIGHEST; }
sub default_themes       { return qw( otrs ) }
sub applies_to           { return 'PPI::Statement::Break' }

sub violates {
    my ( $Self, $Element ) = @_;

    my @Children = $Element->children();
    if ( $Children[0]->content() ne 'next' && $Children[0]->content() ne 'last' ) {
        return;
    }

    my $Label = $Children[0]->snext_sibling();

    if (
        !$Label
        || !$Label->isa('PPI::Token::Word')
        || $Label->content() !~ m{^[A-Z_]+}xms
        )
    {
        return $Self->violation( $Description, $Explanation, $Element );
    }

    return;
}

1;
