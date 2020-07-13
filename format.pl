use strict;
#use warnings;

my $tab_spaces = 2;
my $source_path = 'factorial.java';
my $target_path = 'formatted_factorial.java';

# Open source and target files
open (my $source_fh, '<', $source_path) or die "Can't open file $!";
open (my $target_fh, '>', $target_path) or die "Can't open file $!";

# Read source file conent
my $file_content = do { local $/; <$source_fh> };

# Start formatting
braces($file_content);
despace($file_content);
operators($file_content);
my @lines = split(/\r\n/, $file_content);
indent(@lines);

# Write output to target file
print $target_fh join ("\r\n", @lines);

# Close files
close($source_fh);
close($target_fh);

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
  $_[0] =~ s/\s*\{\s*/ \{\r\n/gm;                         # append open brace '{' to previous line
  $_[0] =~ s/(\r\n)*\}(\r\n)*[ \s]*(while.*)?/\r\n\} $3\r\n/gm;  # move  close brace '}' to new line
}

sub operators {
  $_[0] =~ s/ *(\+\=|\-=|\*=|\/=|\<\=|\>\=|==|!=|<<|>>|>>>|=|\+|\-|\*|\/|<|>) */ $1 /g;
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