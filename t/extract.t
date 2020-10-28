use Test2::V0;
use Test2::Plugin::GitHub::Actions::AnnotateFailedTest;

use Twitter::Text::Util;
use Twitter::Text;

my $yaml = load_yaml("extract.yml");

subtest extract_hashtags => sub {
    my $testcases = $yaml->[0]->{tests}->{hashtags};
    for my $testcase (@$testcases) {
        my $parse_result = extract_hashtags(convert_yaml_unicode_literal($testcase->{text}));
        my $expected = $testcase->{expected};
        $expected = eval($expected) unless ref $expected eq 'ARRAY';
        is(
            $parse_result,
            $expected,
            $testcase->{description},
        );
    }
};

subtest extract_hashtags_with_indices => sub {
    my $testcases = $yaml->[0]->{tests}->{hashtags_with_indices};
    for my $testcase (@$testcases) {
        my $parse_result = extract_hashtags_with_indices(convert_yaml_unicode_literal($testcase->{text}));
        my $expected = [ map {
            {
                hashtag => $_->{hashtag},
                indices => eval($_->{indices}),
            };
        } @{$testcase->{expected}} ];
        is(
            $parse_result,
            $expected,
            $testcase->{description},
        );
    }
};

subtest extract_urls => sub {
    my $testcases = $yaml->[0]->{tests}->{urls};
    for my $testcase (@$testcases) {
        my $parse_result = extract_urls($testcase->{text});
        my $expected = $testcase->{expected};
        $expected = eval($expected) unless ref $expected eq 'ARRAY';
        is(
            $parse_result,
            $expected,
            $testcase->{description},
        );
    }
};

subtest extract_urls_with_indices => sub {
    my $testcases = $yaml->[0]->{tests}->{urls_with_indices};
    for my $testcase (@$testcases) {
        my $parse_result = extract_urls_with_indices(convert_yaml_unicode_literal($testcase->{text}));
        is $parse_result, [ map {
            {
                url => $_->{url},
                indices => eval($_->{indices}), # XXX: treal YAML's array as Perl's ArrayRef
            }
        } @{$testcase->{expected}} ], $testcase->{description};
    }
};

subtest extract_urls_with_directional_markers => sub {
    my $testcases = $yaml->[0]->{tests}->{urls_with_directional_markers};
    for my $testcase (@$testcases) {
        my $parse_result = extract_urls_with_indices(convert_yaml_unicode_literal($testcase->{text}));
        is $parse_result, [ map {
            {
                url => $_->{url},
                indices => eval($_->{indices}), # XXX: treal YAML's array as Perl's ArrayRef
            }
        } @{$testcase->{expected}} ], $testcase->{description};
    }
};

done_testing;
