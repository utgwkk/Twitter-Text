use Test2::V0;
no if $^V lt v5.13.9, 'warnings', 'utf8'; ## no critic (ValuesAndExpressions::ProhibitMismatchedOperators)
use Test2::Plugin::NoWarnings;
BEGIN {
    eval { ## no critic (ErrorHandling::RequireCheckingReturnValueOfEval)
        require Test2::Plugin::GitHub::Actions::AnnotateFailedTest;
        Test2::Plugin::GitHub::Actions::AnnotateFailedTest->import;
    };
}

use Twitter::Text::Util;
use Twitter::Text;

my $yaml = load_yaml("autolink.yml");

for my $testcase_name (qw(usernames lists hashtags urls cashtags all)) {
    subtest $testcase_name => sub {
        my $testcases = $yaml->[0]->{tests}->{$testcase_name};

        for my $testcase (@$testcases) {
            my $auto_link_text = auto_link($testcase->{text});
            is(
                $auto_link_text,
                $testcase->{expected},
                $testcase->{description},
            );
        }
    };
}

done_testing;
