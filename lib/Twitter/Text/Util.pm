package Twitter::Text::Util;
use strict;
use warnings;
use Exporter 'import';
use File::Share qw(dist_file);
use YAML::Tiny;
our @EXPORT = qw(load_yaml);

sub load_yaml {
    my $yamlname = shift;

    return YAML::Tiny->read(dist_file('Twitter-Text', "conformance/$yamlname"));
}

1;
