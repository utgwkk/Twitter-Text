package
    Twitter::Text::Util; # hide from PAUSE
use strict;
use warnings;
use Exporter 'import';
use File::Share qw(dist_file);
use YAML::Tiny;
our @EXPORT = qw(
    convert_yaml_unicode_literal
    load_yaml
);

# internal use only, do not use this module directly.

sub convert_yaml_unicode_literal {
    my $text = shift;
    $text =~ s/\\u([0-9a-fA-F]{4})/"\"\\N{U+$1}\""/eeg;
    $text =~ s/\\U([0-9a-fA-F]{8})/"\"\\N{U+$1}\""/eeg;
    $text;
}

sub load_yaml {
    my $yamlname = shift;

    return YAML::Tiny->read(dist_file('Twitter-Text', "conformance/$yamlname"));
}

1;
