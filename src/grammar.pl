use YAML::XS;
use Data::Dumper;

$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Sortkeys = 1;

my $hash = Data::Dumper::Dumper YAML::XS::LoadFile(shift);
chomp($hash);

print <<"...";
package TestML::Parser::Grammar;
use base 'TestML::Parser::Pegex';
use strict;
use warnings;

our \$grammar = +$hash;

sub grammar {
    return \$grammar;
}

1;
...
