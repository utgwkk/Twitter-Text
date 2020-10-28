package Twitter::Text::Regexp;
use strict;
use warnings;
use utf8;
use Twitter::Text::Util qw(load_yaml);

# internal use only, do not use this module directly.

sub regex_range {
    my ($from, $to) = @_;

    if (defined $to) {
        return pack('U', $from) . '-' . pack('U', $to);
    } else {
        return pack('U', $from);
    }
}

our $TLDS = load_yaml("tld_lib.yml")->[0];
our $PUNCTUATION_CHARS = '!"#$%&\'()*+,-./:;<=>?@\[\]^_\`{|}~';
our $SPACE_CHARS = " \t\n\x0B\f\r";
our $CTRL_CHARS = "\x00-\x1F\x7F";
our $INVALID_CHARACTERS = join '', map { pack 'U', $_ } (
    0xFFFE, 0xFEFF, # BOM
    0xFFFF,         # Special
);
our $UNICODE_SPACES = join '', map { pack 'U*', $_ } (
    (0x0009..0x000D),  # White_Space # Cc   [5] <control-0009>..<control-000D>
    0x0020,          # White_Space # Zs       SPACE
    0x0085,          # White_Space # Cc       <control-0085>
    0x00A0,          # White_Space # Zs       NO-BREAK SPACE
    0x1680,          # White_Space # Zs       OGHAM SPACE MARK
    0x180E,          # White_Space # Zs       MONGOLIAN VOWEL SEPARATOR
    (0x2000..0x200A), # White_Space # Zs  [11] EN QUAD..HAIR SPACE
    0x2028,          # White_Space # Zl       LINE SEPARATOR
    0x2029,          # White_Space # Zp       PARAGRAPH SEPARATOR
    0x202F,          # White_Space # Zs       NARROW NO-BREAK SPACE
    0x205F,          # White_Space # Zs       MEDIUM MATHEMATICAL SPACE
    0x3000,          # White_Space # Zs       IDEOGRAPHIC SPACE
);

our $DIRECTIONAL_CHARACTERS = join '', map { pack 'U', $_ } (
    0x061C,          # ARABIC LETTER MARK (ALM)
    0x200E,          # LEFT-TO-RIGHT MARK (LRM)
    0x200F,          # RIGHT-TO-LEFT MARK (RLM)
    0x202A,          # LEFT-TO-RIGHT EMBEDDING (LRE)
    0x202B,          # RIGHT-TO-LEFT EMBEDDING (RLE)
    0x202C,          # POP DIRECTIONAL FORMATTING (PDF)
    0x202D,          # LEFT-TO-RIGHT OVERRIDE (LRO)
    0x202E,          # RIGHT-TO-LEFT OVERRIDE (RLO)
    0x2066,          # LEFT-TO-RIGHT ISOLATE (LRI)
    0x2067,          # RIGHT-TO-LEFT ISOLATE (RLI)
    0x2068,          # FIRST STRONG ISOLATE (FSI)
    0x2069,          # POP DIRECTIONAL ISOLATE (PDI)
);
our $DOMAIN_VALID_CHARS = "[^$DIRECTIONAL_CHARACTERS$PUNCTUATION_CHARS$SPACE_CHARS$CTRL_CHARS$INVALID_CHARACTERS$UNICODE_SPACES]";

our $LATIN_ACCENTS = join '', (
    regex_range(0xc0, 0xd6),
    regex_range(0xd8, 0xf6),
    regex_range(0xf8, 0xff),
    regex_range(0x0100, 0x024f),
    regex_range(0x0253, 0x0254),
    regex_range(0x0256, 0x0257),
    regex_range(0x0259),
    regex_range(0x025b),
    regex_range(0x0263),
    regex_range(0x0268),
    regex_range(0x026f),
    regex_range(0x0272),
    regex_range(0x0289),
    regex_range(0x028b),
    regex_range(0x02bb),
    regex_range(0x0300, 0x036f),
    regex_range(0x1e00, 0x1eff)
);
our $latin_accents = qr/[$LATIN_ACCENTS]+/o;

our $valid_subdomain = qr/(?:(?:$DOMAIN_VALID_CHARS(?:[_-]|$DOMAIN_VALID_CHARS)*)?$DOMAIN_VALID_CHARS\.)/io;
our $valid_domain_name = qr/(?:(?:$DOMAIN_VALID_CHARS(?:[-]|$DOMAIN_VALID_CHARS)*)?$DOMAIN_VALID_CHARS\.)/io;

our $GENERIC_TLDS = join '|', @{$TLDS->{generic}};
our $CC_TLDS = join '|', @{$TLDS->{country}};

our $valid_gTLD = qr{
    (?:
    (?:$GENERIC_TLDS)
    (?=[^0-9a-z@+-]|$)
    )
}ix;

our $valid_ccTLD = qr{
    (?:
    (?:$CC_TLDS)
    (?=[^0-9a-z@+-]|$)
    )
}ix;
our $valid_punycode = qr/(?:xn--[0-9a-z]+)/i;

our $valid_domain = qr/(?:
    $valid_subdomain*$valid_domain_name
    (?:$valid_gTLD|$valid_ccTLD|$valid_punycode)
)/iox;

# This is used in Extractor
our $valid_ascii_domain = qr/
    (?:(?:[a-z0-9\-_]|$latin_accents)+\.)+
    (?:$valid_gTLD|$valid_ccTLD|$valid_punycode)
/iox;

# This is used in Extractor for stricter t.co URL extraction
our $valid_tco_url = qr/^https?:\/\/t\.co\/([a-z0-9]+)/i;

our $valid_port_number = qr/[0-9]+/;

our $valid_url_preceding_chars = qr/(?:[^A-Z0-9@＠\$#＃$INVALID_CHARACTERS]|[$DIRECTIONAL_CHARACTERS]|^)/io;
our $invalid_url_without_protocol_preceding_chars = qr/[-_.\/]$/;

our $valid_general_url_path_chars = qr/[a-z\p{Cyrillic}0-9!\*';:=\+\,\.\$\/%#\[\]\p{Pd}_~&\|$LATIN_ACCENTS]/io;
# Allow URL paths to contain up to two nested levels of balanced parens
#  1. Used in Wikipedia URLs like /Primer_(film)
#  2. Used in IIS sessions like /S(dfd346)/
#  3. Used in Rdio URLs like /track/We_Up_(Album_Version_(Edited))/
our $valid_url_balanced_parens = qr/
    \(
    (?:
        $valid_general_url_path_chars+
        |
        # allow one nested level of balanced parentheses
        (?:
        $valid_general_url_path_chars*
        \(
            $valid_general_url_path_chars+
        \)
        $valid_general_url_path_chars*
        )
    )
    \)
/iox;
# Valid end-of-path chracters (so /foo. does not gobble the period).
#   1. Allow =&# for empty URL parameters and other URL-join artifacts
our $valid_url_path_ending_chars = qr/[a-z\p{Cyrillic}0-9=_#\/\+\-$LATIN_ACCENTS]|(?:$valid_url_balanced_parens)/io;
our $valid_url_path = qr/(?:
    (?:
    $valid_general_url_path_chars*
    (?:$valid_url_balanced_parens $valid_general_url_path_chars*)*
    $valid_url_path_ending_chars
    )|(?:$valid_general_url_path_chars+\/)
)/iox;
our $valid_url_query_chars = qr/[a-z0-9!?\*'\(\);:&=\+\$\/%#\[\]\-_\.,~|@]/i;
our $valid_url_query_ending_chars = qr/[a-z0-9_&=#\/\-]/i;
our $valid_url = qr{
  (                                                                         #   $1 total match
    ($valid_url_preceding_chars)                                            #   $2 Preceeding chracter
    (                                                                       #   $3 URL
      (https?:\/\/)?                                                        #   $4 Protocol (optional)
      ($valid_domain)                                                       #   $5 Domain(s)
      (?::($valid_port_number))?                                            #   $6 Port number (optional)
      (/$valid_url_path*)?                                                  #   $7 URL Path and anchor
      (\?$valid_url_query_chars*$valid_url_query_ending_chars)?             #   $8 Query String
    )
  )}ix;

1;
