use Test2::V0;
use Test2::Plugin::GitHub::Actions::AnnotateFailedTest;

use Twitter::Text::Util;
use Twitter::Text::Configuration;
use Twitter::Text;

sub expected_parse_result {
    my $testcase = shift;
    hash {
        field weighted_length => $testcase->{expected}->{weightedLength};
        field valid => bool($testcase->{expected}->{valid} eq 'true');
        field permillage => $testcase->{expected}->{permillage};
        # Note that we don't assert display and valid ranges
        #field display_range_start => $testcase->{expected}->{displayRangeStart};
        #field display_range_end => $testcase->{expected}->{displayRangeEnd};
        #field valid_range_start => $testcase->{expected}->{validRangeStart};
        #field valid_range_end => $testcase->{expected}->{validRangeEnd};
        field display_range_start => E;
        field display_range_end => E;
        field valid_range_start => E;
        field valid_range_end => E;
        etc;
    };
}

my $yaml = load_yaml("validate.yml");

subtest tweets => sub {
    my $testcases = $yaml->[0]->{tests}->{tweets};
    for my $testcase (@$testcases) {
        my $validation_result = is_valid_tweet(convert_yaml_unicode_literal($testcase->{text}), {
            config => Twitter::Text::Configuration::V2,
        });
        is $validation_result, bool($testcase->{expected} eq 'true'), $testcase->{description};
    }
};

subtest hashtags => sub {
    my $testcases = $yaml->[0]->{tests}->{hashtags};
    for my $testcase (@$testcases) {
        my $validation_result = is_valid_hashtag(convert_yaml_unicode_literal($testcase->{text}));
        is $validation_result, bool($testcase->{expected} eq 'true'), $testcase->{description};
    }
};

subtest lists => sub {
    my $testcases = $yaml->[0]->{tests}->{lists};
    for my $testcase (@$testcases) {
        my $validation_result = is_valid_list(convert_yaml_unicode_literal($testcase->{text}));
        is $validation_result, bool($testcase->{expected} eq 'true'), $testcase->{description};
    }
};

subtest urls => sub {
    my $testcases = $yaml->[0]->{tests}->{urls};
    for my $testcase (@$testcases) {
        my $validation_result = is_valid_url(convert_yaml_unicode_literal($testcase->{text}));
        is $validation_result, bool($testcase->{expected} eq 'true'), $testcase->{description};
    }
};

subtest urls_without_protocol => sub {
    my $testcases = $yaml->[0]->{tests}->{urls_without_protocol};
    for my $testcase (@$testcases) {
        my $validation_result = is_valid_url(convert_yaml_unicode_literal($testcase->{text}), require_protocol => 0);
        is $validation_result, bool($testcase->{expected} eq 'true'), $testcase->{description} , $testcase->{text};
    }
};

subtest usernames => sub {
    my $testcases = $yaml->[0]->{tests}->{usernames};
    for my $testcase (@$testcases) {
        my $validation_result = is_valid_username(convert_yaml_unicode_literal($testcase->{text}));
        is $validation_result, bool($testcase->{expected} eq 'true'), $testcase->{description};
    }
};

subtest WeightedTweetsCounterTest => sub {
    my $testcases = $yaml->[0]->{tests}->{WeightedTweetsCounterTest};

    for my $testcase (@$testcases) {
        my $parse_result = parse_tweet(convert_yaml_unicode_literal($testcase->{text}), {
            config => Twitter::Text::Configuration::V2,
        });
        is $parse_result, expected_parse_result($testcase), $testcase->{description};
    }
};

subtest WeightedTweetsWithDiscountedEmojiCounterTest => sub {
    my $testcases = $yaml->[0]->{tests}->{WeightedTweetsWithDiscountedEmojiCounterTest};

    for my $testcase (@$testcases) {
        my $parse_result = parse_tweet(convert_yaml_unicode_literal($testcase->{text}));
        is $parse_result, expected_parse_result($testcase), $testcase->{description};
    }
};

subtest UnicodeDirectionalMarkerCounterTest => sub {
    my $testcases = $yaml->[0]->{tests}->{UnicodeDirectionalMarkerCounterTest};

    for my $testcase (@$testcases) {
        my $parse_result = parse_tweet(convert_yaml_unicode_literal($testcase->{text}));
        is $parse_result, expected_parse_result($testcase), $testcase->{description};
    }
};

done_testing;
