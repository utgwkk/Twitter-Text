requires 'perl', '5.008001';
requires 'Carp';
requires 'Exporter';
requires 'List::Util';
requires 'Net::IDN::Encode';
requires 'Path::Tiny';
requires 'Unicode::Normalize';

on 'test' => sub {
    requires 'FindBin';
    requires 'Test::More', '0.98';
    requires 'Test2::Plugin::GitHub::Actions::AnnotateFailedTest';
    requires 'Test2::V0';
    requires 'YAML::Tiny';
};

