package Twitter::Text::Extractor;
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
use List::Util qw(min);
use List::UtilsBy qw(nsort_by);
use Net::IDN::Encode ':all';
use Twitter::Text::Configuration;
use Twitter::Text::Regexp;
use Twitter::Text::Regexp::Emoji;
use Unicode::Normalize;
use Unicode::Normalize qw(NFC);

sub extract_emoji_with_indices {
    my ($class, $text) = @_;
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

sub extract_cashtags {
    my ($class, $text) = @_;
    return [ map { $_->{cashtag} } @{ extract_cashtags_with_indices($text) }];
}

sub extract_cashtags_with_indices {
    my ($class, $text) = @_;

    return [] unless $text =~ /\$/;

    my $tags = [];
    while ($text =~ /($Twitter::Text::Regexp::valid_cashtag)/g) {
        my ($before, $dollar, $cash_text) = ($2, $3, $4);
        my $start_position = $-[3];
        my $end_position = $+[4];
        push @$tags, {
            cashtag => $cash_text,
            indices => [$start_position, $end_position],
        };
    }

    return $tags;
}

sub extract_hashtags {
    my ($class, $text) = @_;
    return [ map { $_->{hashtag} } @{ extract_hashtags_with_indices($text) } ];
}

sub extract_hashtags_with_indices {
    my ($class, $text, $options) = @_;
    return [] unless $text =~ /[#＃]/;
    $options->{check_url_overlap} = 1 unless exists $options->{check_url_overlap};

    my $tags = [];

    while ($text =~ /($Twitter::Text::Regexp::valid_hashtag)/gp) {
        my ($before, $hash, $hash_text) = ($2, $3, $4);
        my $start_position = $-[3];
        my $end_position = $+[4];
        my $after = ${^POSTMATCH};
        unless ($after =~ $Twitter::Text::Regexp::end_hashtag_match) {
            push @$tags, {
                hashtag => $hash_text,
                indices => [$start_position, $end_position],
            };
        }
    }

    if ($options->{check_url_overlap}) {
        my $urls = extract_urls_with_indices($text);
        if (@$urls) {
            $tags = [ @$tags, @$urls ];
            # remove duplicates
            $tags = remove_overlapping_entities($tags);
            # remove URL entities
            $tags = [ grep { $_->{hashtag} } @$tags ];
        }
    }

    return $tags;
}

sub extract_mentioned_screen_names {
    my ($class, $text) = @_;
    return [ map { $_->{screen_name} } @{ extract_mentioned_screen_names_with_indices($text) } ];
}

sub extract_mentioned_screen_names_with_indices {
    my ($class, $text) = @_;

    return [] unless $text;

    my $possible_screen_name = [];
    for my $mention_or_list (@{ extract_mentions_or_lists_with_indices($text) }) {
        next if length $mention_or_list->{list_slug};
        push @$possible_screen_name, {
            screen_name => $mention_or_list->{screen_name},
            indices => $mention_or_list->{indices},
        };
    }

    return $possible_screen_name;
}

sub extract_mentions_or_lists_with_indices {
    my ($class, $text) = @_;

    return [] unless $text =~ /[@＠]/;

    my $possible_entries = [];
    while ($text =~ /($Twitter::Text::Regexp::valid_mention_or_list)/gp) {
        my ($before, $at, $screen_name, $list_slug) = ($2, $3, $4, $5);
        my $start_position = $-[4] - 1;
        my $end_position = $+[defined $list_slug ? 5 : 4];
        my $after = ${^POSTMATCH};
        unless ($after =~ $Twitter::Text::Regexp::end_mention_match) {
            push @$possible_entries, {
                screen_name => $screen_name,
                list_slug => $list_slug || '',
                indices => [$start_position, $end_position],
            };
        }
    }
    return $possible_entries;
}

sub extract_urls {
    my ($class, $text) = @_;
    my $urls = extract_urls_with_indices($text);
    return [ map { $_->{url} } @$urls ];
}

sub extract_urls_with_indices {
    my ($class, $text, $options) = @_;
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

1;
