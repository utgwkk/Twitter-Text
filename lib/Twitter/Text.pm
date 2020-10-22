package Twitter::Text;
use 5.008001;
use strict;
use warnings;
use utf8;
use constant {
    DEFAULT_TCO_URL_LENGTHS => {
        short_url_length => 23
    },
    MAX_WEIGHTENED_LENGTH => 280,
    MAX_URL_LENGTH => 4096,
    MAX_TCO_SLUG_LENGTH => 40,
    URL_PROTOCOL_LENGTH => length 'https://',
};
use Carp qw(croak);
use Exporter 'import';
use List::Util qw(min);
use Net::IDN::Encode ':all';
use Twitter::Text::Configuration;
use Twitter::Text::Regexp;
use Twitter::Text::Regexp::Emoji;
use Unicode::Normalize qw(NFC);

our $VERSION = "0.01";
our @EXPORT = qw(parse_tweet extract_urls extract_urls_with_indices);

sub extract_emoji_with_indices {
    my ($text) = @_;
    my $emoji = [];
    while ($text =~ /($Twitter::Text::Regexp::Emoji::valid_emoji)/g) {
        my $emoji_text = $1;
        my $start_position = $-[1];
        my $end_position = $+[1];
        push @$emoji, {
            emoji => $emoji_text,
            indices => [ $start_position, $end_position ],
        };
    }
    return $emoji;
}

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
    my ($text, $options) = @_;
    # merge options
    $options ||= {};
    $options->{$_} = DEFAULT_TCO_URL_LENGTHS()->{$_} for keys %{ DEFAULT_TCO_URL_LENGTHS() };

    my $normalized_text = NFC($text);

    return _empty_parse_results() unless length $normalized_text > 0;

    my $config = $options->{config} || Twitter::Text::Configuration::default_configuration;
    my $scale = $config->{scale};
    my $max_weighted_tweet_length = $config->{maxWeightedTweetLength};
    my $scaled_max_weighted_tweet_length = $max_weighted_tweet_length * $scale;
    my $transformed_url_length = $config->{transformedURLLength} * $scale;
    my $ranges = $config->{ranges};

    my $url_entities = extract_urls_with_indices($normalized_text);
    my $emoji_entities = $config->{emojiParsingEnabled} ? extract_emoji_with_indices($normalized_text) : [];

    my $has_invalid_chars = 0;
    my $weighted_count = 0;
    my $offset = 0;
    my $display_offset = 0;
    my $valid_offset = 0;

    while ($offset < length $normalized_text) {
        my $char_weight = $config->{defaultWeight};
        my $entity_length = 0;

        for my $url_entity (@$url_entities) {
            if ($url_entity->{indices}->[0] == $offset) {
                $entity_length = $url_entity->{indices}->[1] - $url_entity->{indices}->[0];
                $weighted_count += $transformed_url_length;
                $offset += $entity_length;
                $display_offset += $entity_length;
                if ($weighted_count <= $scaled_max_weighted_tweet_length){
                    $valid_offset += $entity_length;
                }
                # Finding a match breaks the loop
                last;
            }
        }

        for my $emoji_entity (@$emoji_entities) {
            if ($emoji_entity->{indices}->[0] == $offset) {
                $entity_length = $emoji_entity->{indices}->[1] - $emoji_entity->{indices}->[0];
                $weighted_count += $char_weight; # the default weight
                $offset += $entity_length;
                $display_offset += $entity_length;
                if ($weighted_count <= $scaled_max_weighted_tweet_length) {
                    $valid_offset += $entity_length;
                }
                # Finding a match breaks the loop
                last;
            }
        }

        next if $entity_length > 0;

        if ($offset < length $normalized_text) {
            my $code_point = substr $normalized_text, $offset, 1;

            for my $range (@$ranges) {
                my ($chr) = unpack 'U', $code_point;
                my ($range_start, $range_end) = ($range->{start}, $range->{end});
                if ($range_start <= $chr && $chr <= $range_end) {
                    $char_weight = $range->{weight};
                    last;
                }
            }

            $weighted_count += $char_weight;

            $has_invalid_chars = _contains_invalid($code_point) unless $has_invalid_chars;
            my $codepoint_length = length $code_point;
            $offset += $codepoint_length;
            $display_offset += $codepoint_length;

            if (!$has_invalid_chars && ($weighted_count < $scaled_max_weighted_tweet_length)) {
                $valid_offset += $codepoint_length;
            }
        }
    }

    my $normalized_text_offset = length($text) - length($normalized_text);
    my $scaled_weighted_length = $weighted_count / $scale;
    my $is_valid = !$has_invalid_chars && ($scaled_weighted_length <= $max_weighted_tweet_length);
    my $permilage = int($scaled_weighted_length * 1000 / $max_weighted_tweet_length);

    return +{
        weightedLength => $scaled_weighted_length,
        valid => $is_valid ? 1 : 0,
        permillage => $permilage,
        displayRangeStart => 0,
        displayRangeEnd => $display_offset + $normalized_text_offset - 1,
        validRangeStart => 0,
        validRangeEnd => $valid_offset + $normalized_text_offset - 1,
    };
}

sub _empty_parse_results {
    return {
        weightedLength => 0,
        valid => 1,
        permillage => 0,
        displayRangeStart => 0,
        displayRangeEnd => 0,
        validRangeStart => 0,
        validRangeEnd => 0,
    };
}

sub _contains_invalid {
    my ($text) = @_;

    return 0 if !$text || length $text == 0;
    return $text =~ qr/[$Twitter::Text::Regexp::INVALID_CHARACTERS]/;
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

