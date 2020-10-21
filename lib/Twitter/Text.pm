package Twitter::Text;
use 5.008001;
use strict;
use warnings;
use Exporter 'import';

our $VERSION = "0.01";
our @EXPORT = qw(parse_tweet);

# TODO
sub parse_tweet {
    return +{
        weightedLength => 0,
        valid => 0,
        permillage => 0,
        displayRangeStart => 0,
        displayRangeEnd => 0,
        validRangeStart => 0,
        validRangeEnd => 0,
    };
}

1;
__END__

=encoding utf-8

=head1 NAME

Twitter::Text - It's new $module

=head1 SYNOPSIS

    use Twitter::Text;

=head1 DESCRIPTION

Twitter::Text is ...

=head1 LICENSE

Copyright (C) utgwkk.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

utgwkk E<lt>utagawakiki@gmail.comE<gt>

=cut

