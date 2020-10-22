package Twitter::Text::Util;
use strict;
use warnings;
use Exporter 'import';
use Path::Tiny qw(path);
use YAML::Tiny;
our @EXPORT = qw(load_yaml);

sub load_yaml {
    my $yamlname = shift;

    my @path_candidates = (
        # ../../../twitter-text/conformance/$yamlname
        path(__FILE__)->parent->parent->parent->parent->child("twitter-text/conformance/$yamlname"),
        # ../../../../twitter-text/conformance/$yamlname
        # for `minil test`
        path(__FILE__)->parent->parent->parent->parent->parent->child("twitter-text/conformance/$yamlname"),
    );

    for my $path (@path_candidates) {
        return YAML::Tiny->read($path->stringify) if $path->is_file;
    }

    die "$yamlname not found";
}

1;
