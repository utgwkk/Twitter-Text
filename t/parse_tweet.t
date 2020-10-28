use Test2::V0;
use Test2::Plugin::GitHub::Actions::AnnotateFailedTest;

use Twitter::Text::Util;
use Twitter::Text::Configuration;
use Twitter::Text;

sub convert_yaml_unicode_literal {
    my $text = shift;
    $text =~ s/\\u([0-9a-fA-F]{4})/"\"\\N{U+$1}\""/eeg;
    $text =~ s/\\U([0-9a-fA-F]{8})/"\"\\N{U+$1}\""/eeg;
    $text;
}

sub expected_parse_result {
    my $testcase = shift;
    hash {
        field weightedLength => $testcase->{expected}->{weightedLength};
        field valid => bool($testcase->{expected}->{valid} eq 'true');
        field permillage => $testcase->{expected}->{permillage};
        # Note that we don't assert display and valid ranges
        #field displayRangeStart => $testcase->{expected}->{displayRangeStart};
        #field displayRangeEnd => $testcase->{expected}->{displayRangeEnd};
        #field validRangeStart => $testcase->{expected}->{validRangeStart};
        #field validRangeEnd => $testcase->{expected}->{validRangeEnd};
        field displayRangeStart => E;
        field displayRangeEnd => E;
        field validRangeStart => E;
        field validRangeEnd => E;
        etc;
    };
}

my $yaml = load_yaml("validate.yml");

subtest WeightedTweetsCounterTest => sub {
    my $testcases = $yaml->[0]->{tests}->{WeightedTweetsCounterTest};

    for my $testcase (@$testcases) {
        my $parse_result = parse_tweet(convert_yaml_unicode_literal($testcase->{text}), {
            config => Twitter::Text::Configuration::configuration_from_file('v2'),
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
