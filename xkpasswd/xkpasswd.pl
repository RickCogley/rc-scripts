#!/usr/bin/perl
use lib '/usr/local/xkpasswd.pm/';
use XKPasswd;

my $config_overrides = {
    num_words => 4,
    word_length_max => 9,
    word_length_min => 5,
    padding_characters_before => 2,
    padding_characters_after => 2,
    case_transform => 'ALTERNATE',
    padding_alphabet => ['!', '&', '?', '@', '=', '^', '~'],
    separator_alphabet => ['-', '.', ':', ';', '_']
};

# my $password_generator = XKPasswd->new('/usr/local/xkpasswd.pm/cogley_en_romaji.dict', 'APPLEID', $config_overrides);
my $password_generator = XKPasswd->new('/Users/rcogley/dev/rc-scripts/xkpasswd-cogley_en_romaji.dict', 'APPLEID', $config_overrides);




# print $password_generator->status()."\n";
print $password_generator->password()."\n";
