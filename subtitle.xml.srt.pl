#!/usr/bin/perl
use XML::Simple;
use Data::Dumper;
sub toFrames {
   my $time = shift;
   $time=~s/\./:/g;
 # print "Time is $time\n";
   @items=split(/:/,$time);
#print Dumper @items;
#  print "fettich\n";
#offset should be give by commandline
$hours=$items[0]+0-10;
$minutes=$items[1]+0;
$seconds=$items[2]+0;
$mseconds=$items[3]+0;
#fps should come from XML
$fps=25;
$msperframe=1000/$fps;
$mstime=((($hours*60)+$minutes)*60+$seconds)*1000+$mseconds;
#print "ms $mstime\n";
$frame=$mstime/$msperframe;
# print "frame $frame\n";
return $frame;
}

sub is_array {
  my ($ref) = @_;
  # Firstly arrays need to be references, throw
  #  out non-references early.
  return 0 unless ref $ref;

  # Now try and eval a bit of code to treat the
  #  reference as an array.  If it complains
  #  in the 'Not an ARRAY reference' then we're
  #  sure it's not an array, otherwise it was.
  eval {
    my $a = @$ref;
  };
  if ($@=~/^Not an ARRAY reference/) {
    return 0;
  } elsif ($@) {
    die "Unexpected error in eval: $@\n";
  } else {
    return 1;
  }

}

$in=shift;
$out=shift;

open(OUT,">$out") or die "Could not write $out\n";

$xml = new XML::Simple;

$data = $xml->XMLin($in) or die "Could not read $in\n";
$styles=$data->{head}->{styling}->{style};
$items=$data->{body}->{div}->{p};

# print Dumper($items);
$end=1;
foreach my $key ( keys  %{ $items} )
{
 $num=$key;
$num=~ s/subtitle//g;
$num=$num+0;
if($end<$num)
{
  $end=$num;
}

}
print "max subtitle $end\n";
for my $i (1..$end)
{
  
  $curItem=$items->{"subtitle$i"};

  $begin=$curItem->{begin};
  $end=$curItem->{end};
  $style=$curItem->{style};
  $content=$curItem->{content};
# print  Dumper $curItem;
  if(is_array($content))
  { 
    $text="";
    for $a (@{$content})
    { 
       $text=$text . "\n".$a;
    }
    $content=$text;
  }
  #   print $begin. "\n";
$startFrame=   toFrames($begin);
$endFrame= toFrames($end);
$curStyle= $styles->{$style};
#print Dumper $curStyle;
$color=$curStyle->{'tts:color'};
if(defined $curStyle->{'tts:backgroundColor'})
{
  $color="red";
}

$attr="";
if (defined $color)
{

if($color=~/aqua/)	{ $attr="{c:\$00FFFF}";  }
elsif($color=~/blue/)	{  $attr="{c:\$191970}";  }
elsif($color=~/yellow/)	{  $attr="{c:\$EEEE00}";  }
elsif($color=~/lime/)	{  $attr="{c:\$00FF00}";  }
elsif($color=~/red/)	{  $attr="{c:\$B81324}";  }



}
 $begin=~s/^1/0/;
 $end=~s/^1/0/;
 $begin=~s/\./,/;
 $end=~s/\./,/;
 print OUT "\n$i\n$begin --> $end$content\n";

}
