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
our @EXPORT = qw(
    extract_hashtags
    extract_hashtags_with_indices
    extract_urls
    extract_urls_with_indices
    is_valid_tweet
    parse_tweet
);

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

sub extract_hashtags {
    my ($text) = @_;
    return [ map { $_->{hashtag} } @{ extract_hashtags_with_indices($text) } ];
}

sub extract_hashtags_with_indices {
    my ($text, $options) = @_;
    return [];
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

sub is_valid_tweet {
    my ($text) = @_;
    return parse_tweet($text, {
        config => Twitter::Text::Configuration::V1,
    })->{valid};
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

            if (!$has_invalid_chars && ($weighted_count <= $scaled_max_weighted_tweet_length)) {
                $valid_offset += $codepoint_length;
            }
        }
    }

    my $normalized_text_offset = length($text) - length($normalized_text);
    my $scaled_weighted_length = $weighted_count / $scale;
    my $is_valid = !$has_invalid_chars && ($scaled_weighted_length <= $max_weighted_tweet_length);
    my $permilage = int($scaled_weighted_length * 1000 / $max_weighted_tweet_length);

    return +{
        weighted_length => $scaled_weighted_length,
        valid => $is_valid ? 1 : 0,
        permillage => $permilage,
        display_range_start => 0,
        display_range_end => $display_offset + $normalized_text_offset - 1,
        valid_range_start => 0,
        valid_range_end => $valid_offset + $normalized_text_offset - 1,
    };
}

sub _empty_parse_results {
    return {
        weighted_length => 0,
        valid => 0,
        permillage => 0,
        display_range_start => 0,
        display_range_end => 0,
        valid_range_start => 0,
        valid_range_end => 0,
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

Twitter::Text - Perl implementation of the twitter-text parsing library (under construction)

=head1 SYNOPSIS

    use Twitter::Text;

    $result = parse_tweet('Hello world こんにちは世界');
    print $result->{valid} ? 'valid tweet' : 'invalid tweet';

=head1 DESCRIPTION

Twitter::Text is a Perl implementation of the twitter-text parsing library.

=head2 WARNING

This library is under construction. Many functionalities of original L<twitter-text|https://github.com/twitter/twitter-text> library are not implemented yet.

Please refer L<Implementation progress|https://github.com/utgwkk/Twitter-Text/issues/5> for latest status.

=head1 FUNCTIONS

=head2 Extraction

=head3 extract_urls

    my \@urls = extract_urls($text);

=head3 extract_urls_with_indices

    my \@urls = extract_urls_with_indices($text, [\%options]);

=head2 Validation

=head3 parse_tweet

    my \%parse_result = parse_tweet($text, [\%options]);

The C<parse_tweet> function takes a C<$text> string and optional C<\%options> parameter and returns a hash reference with following values:

=over 4

=item C<weighted_length>: the overall length of the tweet with code points weighted per the ranges defined in the configuration file.

=item C<permillage>: indicates the proportion (per thousand) of the weighted length in comparison to the max weighted length. A value > 1000 indicates input text that is longer than the allowable maximum.

=item C<valid>: indicates if input text length corresponds to a valid result.

=item C<display_range_start>, C<display_range_end>: An array reference of two unicode code point indices identifying the inclusive start and exclusive end of the displayable content of the Tweet.

=item C<vaildRangeStart>, C<valid_range_end>: An array reference of two unicode code point indices identifying the inclusive start and exclusive end of the valid content of the Tweet.

=back

=head1 SEE ALSO

L<twitter-text|https://github.com/twitter/twitter-text>. This implementation is heavily based on L<Ruby implementation of twitter-text|https://github.com/twitter/twitter-text/tree/master/rb>.

L<https://developer.twitter.com/en/docs/counting-characters>

=head1 COPYRIGHT & LICENSE

Copyright (C) Twitter, Inc and other contributors

Copyright (C) utgwkk.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

utgwkk E<lt>utagawakiki@gmail.comE<gt>

=cut

