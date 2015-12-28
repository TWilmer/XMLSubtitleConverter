#!/usr/bin/perl
use XML::Simple;
use Data::Dumper;
sub toFrames {
   my $time = shift;
  print "Time is $time\n";

   @items=split(/\./,$time);
print Dumper @items;
#  print "fettich\n";
#offset should be give by commandline
$second=$items[0];
$mseconds=$items[1];
#fps should come from XML
$mstime=$second*1000+$mseconds;


print "s $second ms $mseconds = $mstime\n";

# print "frame $frame\n";
$ms=$mstime%1000;
$mstime=$mstime-$ms;
$mstime=$mstime/1000;

$seconds=$mstime%60;
$mstime=$mstime-$seconds;
$mstime=$mstime/60;

$minutes=$mstime%60;
$mstime=$mstime-$minutes;
$mstime=$mstime/60;

$hours=$mstime;
$ret= "$hours:$minutes:$seconds,$ms";
print "Return $ret\n";
return $ret;
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
$items=$data->{'body'}->{'div'}->{'p'};
#print Dumper($items);

$count=0;
for my $curItem ( @{ $items} )
{
  
 

  $begin=$curItem->{begin};
  $end=$curItem->{end};
  
  $content=$curItem->{'content'};

  
  if(is_array($content))
  { 

    $text="";
    $sep="";

    for $a (@$content)
    { 

       $text=$text . $sep.$a;
       $sep="\n";
    }

    $content=$text;

  }else{
       $content=$content;
  }
  #   print $begin. "\n";

$startFrame=   toFrames($begin);
$endFrame= toFrames($end);
$begin=~s/^1/0/;
 $end=~s/^1/0/;
 $begin=~s/\./,/;
 $end=~s/\./,/;


 #print OUT "{$startFrame}{$endFrame}$attr$content\n";
print OUT "\n$count\n$startFrame --> $endFrame\n$content\n";
$count=$count+1;


}
print "Subtiles found ". $count."\n";
