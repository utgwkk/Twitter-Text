requires 'perl', '5.008001';

on 'test' => sub {
    requires 'FindBin';
    requires 'Test::More', '0.98';
    requires 'Test2::Plugin::GitHub::Actions::AnnotateFailedTest';
    requires 'Test2::V0';
    requires 'YAML::Tiny';
};

