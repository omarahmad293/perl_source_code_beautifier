#!/usr/bin/perl

use strict;
use Term::ANSIColor;
use Getopt::Long qw(GetOptions);

my $indent = 1;
my $tab_spaces = 2;
my $print_output = 0;

my $USAGE = "USAGE: $0 [input_file] [output_file] [OPTIONS]
[OPTIONS]:
  --noindent: do not indent output file
  --tab-spaces=s: s is number of spaces in a tab
  --print-output: prints the output to the terminal\n";

# Check number of arguments
if (scalar @ARGV < 2){
  print("2 arguments are required\n");
  die(color("red"), $USAGE);
};

# Get files' paths
my ($source_path, $target_path) = @ARGV;

# Get optional parameters
GetOptions(
    'tab-spaces=i' => \$tab_spaces,
    'indent!' => \$indent,
    'print-output' => \$print_output
) or die(color("red"), $USAGE);

# Open source and target files
open (my $source_fh, '<', $source_path) or die "Can't open file $!";
open (my $target_fh, '>', $target_path) or die "Can't open file $!";

# Read source file conent
my $file_content = do { local $/; <$source_fh> };

# Start formatting
braces($file_content);
despace($file_content);
operators($file_content);
despace($file_content);
my @lines = split(/\r\n/, $file_content);
indent(@lines) if $indent;

# Write output to target file
print $target_fh join ("\r\n", @lines);

# Print output to terminal
print (join ("\r\n", @lines) . "\n") if $print_output;

# Close files
close($source_fh);
close($target_fh);

# Subroutines
sub despace {
  $_[0] =~ s/\t/    /g;                       # Convert tabs to space
  $_[0] =~ s/^\s+//g;                         # Remove leading whitespace
  $_[0] =~ s/ *\r\n/\r\n/g;                   # Remove trailing whitespace
  $_[0] =~ s/ *([,;])/$1/g;                   # Remove space before commas or semi-colons
  $_[0] =~ s/ +/ /g;                          # remove duplicate spaces
  $_[0] =~ s/(\r|\n)+/\r\n/g;                 # remove duplicate new lines 
  $_[0] =~ s/\r\n */\r\n/g;                   # remove duplicate new lines 
  $_[0] =~ s/\( *(.*?)(?= *\)) *\)/\($1\)/g;  # remove redundant spaces in-between brackets ( ... )
}

sub braces {
  $_[0] =~ s/\s*\{\s*/ \{\r\n/gm;                                 # append open brace '{' to previous line
  $_[0] =~ s/(\r\n)*\}(\r\n)*[ \s]*(while.*)?/\r\n\} $3\r\n/gm;   # move  close brace '}' to new line
}

sub operators {
  $_[0] =~ s/ *(\/\/|\/\*|\*\/|\+\=|\-=|\*=|\/=|\<\=|\>\=|==|!=|<<|>>|>>>|=|\+|\-|\*|\/|<|>) */ $1 /g;
                                              # put spaces around operators
}

sub indent {
  my $depth = 0;

  for my $line (@_) {
    $depth-- if ($line =~ /.*\}.*/);
    $line = (" " x $tab_spaces x $depth) . $line;
    $depth++ if ($line =~ /.*\{.*/);
  }
}