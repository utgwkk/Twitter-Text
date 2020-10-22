package Twitter::Text;
use 5.008001;
use strict;
use warnings;
use utf8;
use constant {
    MAX_WEIGHTENED_LENGTH => 280,
    MAX_URL_LENGTH => 4096,
    MAX_TCO_SLUG_LENGTH => 40,
    URL_PROTOCOL_LENGTH => length 'https://',
};
use Carp qw(croak);
use Exporter 'import';
use List::Util qw(min);
use Net::IDN::Encode ':all';
use Twitter::Text::Regexp;
use Unicode::Normalize qw(NFC);

our $VERSION = "0.01";
our @EXPORT = qw(parse_tweet extract_urls extract_urls_with_indices);

sub extract_urls {
    my ($text) = @_;
    my $urls = extract_urls_with_indices($text);
    return [ map { $_->{url} } @$urls ];
}

sub extract_urls_with_indices {
    my ($text, $options) = @_;
    $options ||= {
        extract_url_without_protocol => 1,
    };

    return [] unless $text && ($options->{extract_url_without_protocol} ? $text =~ /\./ : $text =~ /:/);

    my $urls = [];

    while ($text =~ /($Twitter::Text::Regexp::valid_url)/g) {
        my $before = $3;
        my $url = $4;
        my $protocol = $5;
        my $domain = $6;
        my $path = $8;
        my ($start, $end) = ($-[4], $+[4]);

        if (!$protocol) {
            next if !$options->{extract_url_without_protocol} || $before =~ $Twitter::Text::Regexp::invalid_url_without_protocol_preceding_chars;
            my $last_url;
            while ($domain =~ /($Twitter::Text::Regexp::valid_ascii_domain)/g) {
                my $ascii_domain = $1;
                next unless is_valid_domain(length $url, $ascii_domain, $protocol);
                $last_url = {
                    url => $ascii_domain,
                    indices => [ $start + $-[0], $start + $+[0] ],
                };
                push @$urls, $last_url;
            }

            # no ASCII-only domain found. Skip the entire URL
            next unless $last_url;

            # last_url only contains domain. Need to add path and query if they exist.
            if ($path) {
                # last_url was not added. Add it to urls here.
                $last_url->{url} = $url =~ s/$domain/$last_url->{url}/re;
                $last_url->{indices}->[1] = $end;
            }
        } else {
            if ($url =~ /($Twitter::Text::Regexp::valid_tco_url)/) {
                next if $2 && length $2 >= MAX_TCO_SLUG_LENGTH;
                $url = $1;
                $end = $start + length $url;
            }

            next unless is_valid_domain(length $url, $domain, $protocol);

            push @$urls, {
                url => $url,
                indices => [ $start, $end ],
            };

        }
    }

    return $urls;
}

sub is_valid_domain {
    my ($url_length, $domain, $protocol) = @_;
    croak 'invalid empty domain' unless $domain;

    my $original_domain_length = length $domain;
    my $encoded_domain = eval { domain_to_ascii($domain) };
    if ($@) {
        return 0;
    }
    my $updated_domain_length = length $encoded_domain;
    $url_length += $updated_domain_length - $original_domain_length if $updated_domain_length > $original_domain_length;
    $url_length += URL_PROTOCOL_LENGTH unless $protocol;
    return $url_length <= MAX_URL_LENGTH;
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

