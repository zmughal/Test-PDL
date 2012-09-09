use PDL::Doc;
use Getopt::Std;
use Config;
use Cwd;

require PDL; # always needed to pick up PDL::VERSION

$opt_v = 0;

getopts('v');
$dir      = '.';		#shift @ARGV;
$outdb    = 'aux/pdldoc.db';	#shift @ARGV;
$outindex = 'aux/Index.pod';	#shift @ARGV;

#unless (defined $dir) {
#	($dir = $INC{'PDL.pm'}) =~ s/PDL\.pm$//i;
#	umask 0022;
#	print "DIR = $dir\n";
#}
#unless (defined $outdb) {
#	$outdb = "$dir/PDL/pdldoc.db";
#	print "DB  = $outdb\n";
#}

$currdir = getcwd;

chdir $dir or die "can't change to $dir";
$dir = getcwd;

unlink $outdb if -e $outdb;
$onldc = new PDL::Doc();
$onldc->outfile($outdb);
$onldc->scantree($dir."/lib",$opt_v);
#$onldc->scan($dir."PDL.pm",$opt_v);

chdir $currdir;

print STDERR "saving...\n";
$onldc->savedb();
@mods = $onldc->search('module:',['Ref'],1);
@mans = $onldc->search('manual:',['Ref'],1);
@scripts = $onldc->search('script:',['Ref'],1);
$outdir = "$dir/PDL";
# ($outdir = $INC{'PDL.pm'}) =~ s/\.pm$//i;
$outindex="$outdir/Index.pod" unless (defined $outindex);
open POD, ">$outindex"
  or die "couldn't open $outindex";
print POD <<'EOPOD';

=head1 NAME

PDL::Index - an index of PDL documentation

=head1 DESCRIPTION

A meta document listing the documented PDL modules and
the PDL manual documents

=head1 PDL manuals

EOPOD

#print POD "=over ",$#mans+1,"\n\n";
print POD "=over 4\n\n";
for (@mans) {
  my $ref = $_->[1]->{Ref};
  $ref =~ s/Manual:/L<$_->[0]|$_->[0]> -/;
##  print POD "=item L<$_->[0]>\n\n$ref\n\n";
#  print POD "=item $_->[0]\n\n$ref\n\n";
  print POD "=item *\n\n$ref\n\n";
}

print POD << 'EOPOD';

=back

=head1 PDL scripts

EOPOD

#print POD "=over ",$#mods+1,"\n\n";
print POD "=over 4\n\n";
for (@scripts) {
  my $ref = $_->[1]->{Ref};
  $ref =~ s/Script:/L<$_->[0]|PDL::$_->[0]> -/;
##  print POD "=item L<$_->[0]>\n\n$ref\n\n";
#  print POD "=item $_->[0]\n\n$ref\n\n";
  print POD "=item *\n\n$ref\n\n";
}

print POD << 'EOPOD';

=back

=head1 PDL modules

EOPOD

#print POD "=over ",$#mods+1,"\n\n";
print POD "=over 4\n\n";
for (@mods) {
  my $ref = $_->[1]->{Ref};
  next unless $_->[0] =~ /^PDL/;
  if( $_->[0] eq 'PDL'){ # special case needed to find the main PDL.pm file.
	  $ref =~ s/Module:/L<PDL::PDL|PDL::PDL> -/;
##	  print POD "=item L<PDL::PDL>\n\n$ref\n\n";
#	  print POD "=item PDL::PDL\n\n$ref\n\n";
	  print POD "=item *\n\n$ref\n\n";
	  next;
  }
  $ref =~ s/Module:/L<$_->[0]|$_->[0]> -/;
##  print POD "=item L<$_->[0]>\n\n$ref\n\n";
#  print POD "=item $_->[0]\n\n$ref\n\n";
  print POD "=item *\n\n$ref\n\n";
}

print POD << "EOPOD";

=back

=head1 HISTORY

Automatically generated by scantree.pl for PDL version $PDL::VERSION.

EOPOD

close POD;
