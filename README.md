# NAME

Twitter::Text - Perl implementation of the twitter-text parsing library

# SYNOPSIS

    use Twitter::Text;

    $result = parse_tweet('Hello world こんにちは世界');
    print $result->{valid} ? 'valid tweet' : 'invalid tweet';

# DESCRIPTION

Twitter::Text is a Perl implementation of the twitter-text parsing library.

## WARNING

This library does not implement auto-linking and hit highlighting.

Please refer [Implementation progress](https://github.com/utgwkk/Twitter-Text/issues/5) for latest status.

# FUNCTIONS

All functions below are exported by default.

## Extraction

### extract\_hashtags

    my \@hashtags = extract_hashtags($text);

### extract\_hashtags\_with\_indices

    my \@hashtags_with_indices = extract_hashtags_with_indices($text, [\%options]);

### extract\_mentioned\_screen\_names

    my \@screen_names = extract_mentioned_screen_names($text);

### extract\_mentioned\_screen\_names\_with\_indices

    my \@screen_names_with_indices = extract_mentioned_screen_names_with_indices($text);

### extract\_mentions\_or\_lists\_with\_indices

    my \@mentions_or_lists_with_indices = extract_mentions_or_lists_with_indices($text);

### extract\_urls

    my \@urls = extract_urls($text);

### extract\_urls\_with\_indices

    my \@urls = extract_urls_with_indices($text, [\%options]);

## Validation

### parse\_tweet

    my \%parse_result = parse_tweet($text, [\%options]);

The `parse_tweet` function takes a `$text` string and optional `\%options` parameter and returns a hash reference with following values:

- `weighted_length`

    The overall length of the tweet with code points weighted per the ranges defined in the configuration file.

- `permillage`

    Indicates the proportion (per thousand) of the weighted length in comparison to the max weighted length. A value > 1000 indicates input text that is longer than the allowable maximum.

- `valid`

    Indicates if input text length corresponds to a valid result.

- `display_range_start`, `display_range_end`

    An array of two unicode code point indices identifying the inclusive start and exclusive end of the displayable content of the Tweet.

- `valid_range_start`, `valid_range_end`

    An array of two unicode code point indices identifying the inclusive start and exclusive end of the valid content of the Tweet.

#### EXAMPLES

    use Data::Dumper;
    use Twitter::Text;

    $result = parse_tweet('Hello world こんにちは世界');
    print Dumper($result);
    # $VAR1 = {
    #       'weighted_length' => 33
    #       'permillage' => 117,
    #       'valid' => 1,
    #       'display_range_start' => 0,
    #       'display_range_end' => 32,
    #       'valid_range_start' => 0,
    #       'valid_range_end' => 32,
    #     };

### is\_valid\_hashtag

    my $valid = is_valid_hashtag($hashtag);

### is\_valid\_list

    my $valid = is_valid_list($username_list);

### is\_valid\_url

    my $valid = is_valid_url($url, [unicode_domains => 1, require_protocol => 1]);

### is\_valid\_username

    my $valid = is_valid_username($username);

# SEE ALSO

[twitter-text](https://github.com/twitter/twitter-text). Implementation of Twitter::Text (this library) is heavily based on [Ruby implementation of twitter-text](https://github.com/twitter/twitter-text/tree/master/rb).

[https://developer.twitter.com/en/docs/counting-characters](https://developer.twitter.com/en/docs/counting-characters)

# COPYRIGHT & LICENSE

Copyright (C) Twitter, Inc and other contributors

Copyright (C) utgwkk.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

utgwkk <utagawakiki@gmail.com>
