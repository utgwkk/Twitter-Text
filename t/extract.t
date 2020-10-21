use Test2::V0;
use FindBin;
use YAML::Tiny;

use Twitter::Text;

my $yaml = YAML::Tiny->read("$FindBin::Bin/../twitter-text/conformance/extract.yml");

my $testcases = $yaml->[0]->{tests}->{urls_with_indices};
for my $testcase (@$testcases) {
    my $parse_result = extract_urls_with_indices($testcase->{text});
    is $parse_result, [ map {
        {
            url => $_->{url},
            indices => eval($_->{indices}), # XXX: treal YAML's array as Perl's ArrayRef
        }
    } @{$testcase->{expected}} ], $testcase->{description};
}

done_testing;
