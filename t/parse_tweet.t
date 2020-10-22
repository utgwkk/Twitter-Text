use Test2::V0;
use Test2::Plugin::GitHub::Actions::AnnotateFailedTest;

use Twitter::Text::Util;
use Twitter::Text;

my $yaml = load_yaml("validate.yml");
my $testcases = $yaml->[0]->{tests}->{WeightedTweetsCounterTest};

for my $testcase (@$testcases) {
    my $parse_result = parse_tweet($testcase->{text});
    is $parse_result, hash {
        field weightedLength => $testcase->{expected}->{weightedLength};
        field valid => bool($testcase->{expected}->{valid} eq 'true');
        field permillage => $testcase->{expected}->{permillage};
        field displayRangeStart => $testcase->{expected}->{displayRangeStart};
        field displayRangeEnd => $testcase->{expected}->{displayRangeEnd};
        field validRangeStart => $testcase->{expected}->{validRangeStart};
        field validRangeEnd => $testcase->{expected}->{validRangeEnd};
        etc;
    }, $testcase->{description};
}

done_testing;
