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
$hours=$hours+2;
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
$styles=$data->{'tt:head'}->{'tt:styling'}->{'tt:style'};
$items=$data->{'tt:body'}->{'tt:div'}->{'tt:p'};

#print Dumper($items);

$count=0;
for my $curItem ( @{ $items} )
{
  
 

  $begin=$curItem->{begin};
  $end=$curItem->{end};
  
  $content=$curItem->{'tt:span'};
 #print  Dumper $content;
  
  if(is_array($content))
  { 
    $text="";
    $sep="";
    for $a (@{$content})
    { 
       $text=$text . $sep.$a->{content};
       $sep="\n";
    }
    $content=$text;
  }else{
       $content=$content->{content};
  }
  #   print $begin. "\n";
$startFrame=   toFrames($begin);
$endFrame= toFrames($end);
$begin=~s/^1/0/;
 $end=~s/^1/0/;
 $begin=~s/\./,/;
 $end=~s/\./,/;


 #print OUT "{$startFrame}{$endFrame}$attr$content\n";
print OUT "\n$count\n$begin --> $end\n$content\n";
$count=$count+1;


}
