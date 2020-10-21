package Twitter::Text;
use 5.008001;
use strict;
use warnings;
use utf8;
use constant MAX_WEIGHTENED_LENGTH => 280;
use Exporter 'import';
use List::Util qw(min);
use Unicode::Normalize qw(NFC);

our $VERSION = "0.01";
our @EXPORT = qw(parse_tweet extract_urls_with_indices);

# see also: perldoc URI
my $url_regex = qr|((https?)(?:(://)?([^/?#\s]*))?([^?#\s'"!;:+]*)(?:\?([^#\s]*))?(?:#(.*))?)|;

# TODO
sub extract_urls_with_indices {
    my $text = shift;
    my $urls = [];

    while ($text =~ /$url_regex/g) {
        push @$urls, {
            url => $1,
            indices => [ $-[0], $+[0] ],
        };
    }

    return $urls;
}

sub parse_tweet {
    my $tweet = shift;
    my $normalized_tweet = NFC($tweet);

    my $weighted_length = length $normalized_tweet; # TODO
    my $valid = $weighted_length <= MAX_WEIGHTENED_LENGTH ? 1 : 0;
    my $permilage = int($weighted_length / MAX_WEIGHTENED_LENGTH * 1000); # TODO
    my $display_range_end = $weighted_length - 1; # TODO
    my $valid_range_end = min($weighted_length, MAX_WEIGHTENED_LENGTH) - 1; # TODO

    return +{
        weightedLength => $weighted_length,
        valid => $valid,
        permillage => $permilage,
        displayRangeStart => 0,
        displayRangeEnd => $display_range_end,
        validRangeStart => 0,
        validRangeEnd => $valid_range_end,
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Twitter::Text - It's new $module

=head1 SYNOPSIS

    use Twitter::Text;

=head1 DESCRIPTION

Twitter::Text is ...

=head1 LICENSE

Copyright (C) utgwkk.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

utgwkk E<lt>utagawakiki@gmail.comE<gt>

=cut

