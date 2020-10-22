package Twitter::Text::Configuration;
use strict;
use warnings;
use JSON::XS ();
use Path::Tiny qw(path);

my %config_cache;

sub configuration_from_file {
    my $config_name = shift;

    return $config_cache{$config_name} if exists $config_cache{$config_name};

    my @path_candidates = (
        # ../../../twitter-text/conformance/config/$config_name.json
        path(__FILE__)->parent->parent->parent->parent->child("twitter-text/conformance/config/$config_name.json"),
        # ../../../../twitter-text/conformance/config/$config_name.json
        # for `minil test`
        path(__FILE__)->parent->parent->parent->parent->parent->child("twitter-text/conformance/config/$config_name.json"),
    );

    for my $path (@path_candidates) {
        next unless $path->is_file;
        return $config_cache{$config_name} ||= JSON::XS::decode_json($path->slurp);
    }

    die "$config_name not found";
}

sub default_configuration {
    return configuration_from_file('v3');
}

1;
