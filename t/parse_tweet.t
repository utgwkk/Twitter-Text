use Test2::V0;
use Test2::Plugin::GitHub::Actions::AnnotateFailedTest;

use Twitter::Text::Util;
use Twitter::Text;

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
        etc;
    };
}

my $yaml = load_yaml("validate.yml");
my $testcases = $yaml->[0]->{tests}->{WeightedTweetsWithDiscountedEmojiCounterTest};

for my $testcase (@$testcases) {
    my $parse_result = parse_tweet($testcase->{text});
    is $parse_result, expected_parse_result($testcase), $testcase->{description};
}

done_testing;
