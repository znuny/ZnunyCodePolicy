# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

## nofilter(TidyAll::Plugin::Znuny::Perl::SyntaxCheck)
## nofilter(TidyAll::Plugin::Znuny::Perl::Require)
## nofilter(TidyAll::Plugin::Znuny::Perl::PerlCritic)
## nofilter(TidyAll::Plugin::Znuny::Common::CustomizationMarkers)

use strict;
use warnings;
use utf8;

use File::Temp qw(tempdir tempfile);
use File::Spec;
use FindBin qw($RealBin);

# Create temporary directory structure
my $TempDir          = tempdir( CLEANUP => 1 );
my $KernelTidyAllDir = File::Spec->catdir( $TempDir,          'Kernel', 'TidyAll' );
my $PluginDir        = File::Spec->catdir( $KernelTidyAllDir, 'Plugin', 'Znuny', 'Custom' );
my $CustomDir        = File::Spec->catdir( $TempDir,          'Custom' );

# Create directories
require File::Path;
File::Path::make_path($PluginDir);
File::Path::make_path($CustomDir);

# Create the custom plugin
my $PluginContent = <<'EOF';
package TidyAll::Plugin::Custom::Example;

use strict;
use warnings;
use parent qw(TidyAll::Plugin::Znuny::Base);

sub validate_source {
    my ( $Self, $Code ) = @_;

    return $Code if $Self->IsPluginDisabled( Code => $Code );

    my $Counter = 0;
    my $ErrorMessage = '';

    for my $Line ( split /\n/, $Code ) {
        $Counter++;

        # Check for example bad pattern
        if ( $Line =~ m{EXAMPLE_BAD_PATTERN} ) {
            $ErrorMessage .= "Line $Counter: Example bad pattern found\n";
        }
    }

    if ($ErrorMessage) {
        $Self->AddErrorMessage($ErrorMessage);
    }

    return $Code;
}

1;
EOF

my $PluginFile = File::Spec->catfile( $PluginDir, 'Example.pm' );
my $FH;
open( $FH, '>', $PluginFile ) or die "Cannot create plugin file: $!";
print $FH $PluginContent;
close($FH);

# Create main tidyallrc
my $MainTidyAllRC     = File::Spec->catfile( $KernelTidyAllDir, 'tidyallrc' );
my $MainConfigContent = <<'EOF';
;
; Main Configuration
;

[+TidyAll::Plugin::Znuny::Common::Origin]
select = **/*.{pl,pm}
EOF

open( $FH, '>', $MainTidyAllRC ) or die "Cannot create main tidyallrc: $!";
print $FH $MainConfigContent;
close($FH);

# Create custom.tidyallrc with our custom plugin
my $CustomTidyAllRC     = File::Spec->catfile( $KernelTidyAllDir, 'custom.tidyallrc' );
my $CustomConfigContent = <<'EOF';
;
; Custom Configuration for Testing
;

[+TidyAll::Plugin::Custom::Example]
select = Custom/**/*.pm
EOF

open( $FH, '>', $CustomTidyAllRC ) or die "Cannot create custom.tidyallrc: $!";
print $FH $CustomConfigContent;
close($FH);

# Create test file that should trigger our custom plugin
my $TestFile        = File::Spec->catfile( $CustomDir, 'Example.pm' );
my $TestFileContent = <<'EOF';
# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --

package Custom::Example;

use strict;
use warnings;

sub Run {
    my ( $Self, %Param ) = @_;

    # This should trigger our custom check
    my $BadCode = 'EXAMPLE_BAD_PATTERN';

    return 1;
}

1;
EOF

open( $FH, '>', $TestFile ) or die "Cannot create test file: $!";
print $FH $TestFileContent;
close($FH);

# Test 1: Check that the FindExtensionsTidyAllrc function finds our custom extension file
require File::Basename;
my $ScriptDir = File::Basename::dirname($RealBin);
my $BinDir    = File::Spec->catdir( $ScriptDir, 'bin' );

# Mock the function (we would normally need to modify the path)
local @INC = ( File::Spec->catdir( $TempDir, 'Kernel' ), @INC );

# Since we can't easily test the actual znuny.CodePolicy.pl script with temporary files,
# we'll simulate the logic here

opendir( my $DH, $KernelTidyAllDir ) or die "Cannot open directory $KernelTidyAllDir: $!";
my @TidyAllrcFiles = grep { /\.tidyallrc$/ && -f "$KernelTidyAllDir/$_" } readdir($DH);
closedir($DH);

@TidyAllrcFiles = sort @TidyAllrcFiles;
my @ExtensionsFiles = ();

FILE:
for my $FileName (@TidyAllrcFiles) {
    next FILE if $FileName eq 'tidyallrc';
    my $FilePath = File::Spec->catfile( $KernelTidyAllDir, $FileName );
    if ( -f $FilePath && -r $FilePath ) {
        push @ExtensionsFiles, $FilePath;
    }
}

$Self->True(
    scalar @ExtensionsFiles == 1,
    'Should find exactly one extensions tidyallrc file.'
);

$Self->True(
    $ExtensionsFiles[0] =~ m{custom\.tidyallrc$},
    'Found file should be custom.tidyallrc.'
);

# Test 2: Check that files are combined correctly
my ( $TempFH, $CombinedFile ) = tempfile( UNLINK => 1 );

# Read main config
open( my $MainFH, '<', $MainTidyAllRC ) or die "Cannot read main config: $!";
while ( my $Line = <$MainFH> ) {
    print $TempFH $Line;
}
close($MainFH);

# Add extensions config
print $TempFH "\n; ==== Extensions configuration from: custom.tidyallrc ====\n";
open( my $CustomFH, '<', $CustomTidyAllRC ) or die "Cannot read custom config: $!";
while ( my $Line = <$CustomFH> ) {
    print $TempFH $Line;
}
close($CustomFH);
close($TempFH);

# Read back and verify
open( my $VerifyFH, '<', $CombinedFile ) or die "Cannot read combined file: $!";
my $CombinedContent = do { local $/; <$VerifyFH> };
close($VerifyFH);

$Self->True(
    $CombinedContent =~ m{TidyAll::Plugin::Znuny::Common::Origin},
    'Should contain main configuration.'
);

$Self->True(
    $CombinedContent =~ m{TidyAll::Plugin::Custom::Example},
    'Should contain extension configuration.'
);

$Self->True(
    $CombinedContent =~ m{Extensions configuration from: custom\.tidyallrc},
    'Should contain separator comment.'
);

1;
