# NAME

Twitter::Text - Perl implementation of the twitter-text parsing library (under construction)

# SYNOPSIS

    use Twitter::Text;

    $result = parse_tweet('Hello world こんにちは世界');
    print $result->{valid} ? 'valid tweet' : 'invalid tweet';

# DESCRIPTION

Twitter::Text is a Perl implementation of the twitter-text parsing library.

## WARNING

This library is under construction. Many functionalities of original [twitter-text](https://github.com/twitter/twitter-text) library are not implemented yet.

Please refer [Implementation progress](https://github.com/utgwkk/Twitter-Text/issues/5) for latest status.

# FUNCTIONS

## Extraction

### extract\_urls

    my \@urls = extract_urls($text);

### extract\_urls\_with\_indices

    my \@urls = extract_urls_with_indices($text, [\%options]);

## Validation

### parse\_tweet

    my \%parse_result = parse_tweet($text, [\%options]);

The `parse_tweet` function takes a `$text` string and optional `\%options` parameter and returns a hash reference with following values:

- `weighted_length`: the overall length of the tweet with code points weighted per the ranges defined in the configuration file.
- `permillage`: indicates the proportion (per thousand) of the weighted length in comparison to the max weighted length. A value > 1000 indicates input text that is longer than the allowable maximum.
- `valid`: indicates if input text length corresponds to a valid result.
- `display_range_start`, `display_range_end`: An array reference of two unicode code point indices identifying the inclusive start and exclusive end of the displayable content of the Tweet.
- `vaildRangeStart`, `valid_range_end`: An array reference of two unicode code point indices identifying the inclusive start and exclusive end of the valid content of the Tweet.

# SEE ALSO

[twitter-text](https://github.com/twitter/twitter-text). This implementation is heavily based on [Ruby implementation of twitter-text](https://github.com/twitter/twitter-text/tree/master/rb).

# COPYRIGHT & LICENSE

Copyright (C) Twitter, Inc and other contributors

Copyright (C) utgwkk.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

utgwkk <utagawakiki@gmail.com>
