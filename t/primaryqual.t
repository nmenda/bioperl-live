# -*-Perl-*-
## Bioperl Test Harness Script for Modules
## $Id$
#
# modeled after the t/Allele.t test script

use ExtUtils::testlib;
use strict;
require 'dumpvar.pl';

BEGIN {
    # to handle systems with no installed Test module
    # we include the t dir (where a copy of Test.pm is located)
    # as a fallback
    eval { require Test; };
    if( $@ ) {
        use lib 't';
    }
    use Test;
    plan tests => 26;
}

	# redirect STDERR to STDOUT
open (STDERR, ">&STDOUT");


print("Checking to see if Bio::SeqIO can be used.\n");
use Bio::SeqIO;
ok(1);


print("Checking to see if PrimaryQual.pm can be used...\n");
use Bio::Seq::PrimaryQual;
ok(1);

print("Checking Bio::Seq::PrimaryQual methods...\n");
print("Note: These are more for Chad's benefit then for yours because I run these every time I mangle the modules to make sure that things did not break. So there.\n");
print("Ready? There are 7 tests.\n");

print("1. Checking that new() works...\n");
print("1a) New with quality values...\n");
my $string_quals = "10 20 30 40 50 40 30 20 10";
print("Quals are $string_quals\n");
my $qualobj = Bio::Seq::PrimaryQual->new( -qual => $string_quals,
                            -id  => 'QualityFragment-12',
                            -accession_number => 'X78121',
                            );
ok(1);
print("1b) New with a reference to an array of quality values...\n");
my @q2 = split/ /,$string_quals;
$qualobj = Bio::Seq::PrimaryQual->new( -qual => \@q2,
			-primary_id	=>	'chads primary_id',			
			-desc		=>	'chads desc',
                            -accession_number => 'chads accession_number',
			-id		=>	'chads id'
                            );

ok(1);
print("2. Checking that qual() works...\n");
print("2a) is the returned value an array?\n");
my $rqual = $qualobj->qual();
ok(ref($rqual) eq "ARRAY");
print("2b) Can qual() set the quality values for this object using a string?\n");
	my $newqualstring = "50 90 1000 20 12 0 0";
	print("Setting the quality values to $newqualstring\n");
	$qualobj->qual($newqualstring);
	my $retrieved_quality = $qualobj->qual();
		# i would just like to state, for the record, that it REALLY SUCKS
		# that perl's join and split functions don't share the same syntax.
	my $retrieved_quality_string = join(' ',@$retrieved_quality);
	print("The setting string was $newqualstring and the retrieved string was $retrieved_quality_string\n");
ok($newqualstring eq $retrieved_quality_string);

print("2c) Can qual() set the quality values for this object using a reference to an array?\n");
	my @newqualarray = split/ /,$newqualstring;
	$qualobj->qual(\@newqualarray);
	$retrieved_quality = $qualobj->qual();
	$retrieved_quality_string = join(' ',@$retrieved_quality);
ok($newqualstring eq $retrieved_quality_string);

print("2d) Can qual() set the quality values to something that is invalid? Should throw an exception\n");
	eval {
		$qualobj->qual("chad");
	};
	ok($@ =~ /not look healthy/);

print("2e) Can qual() set the quality values to empty?\n");
	eval { $qualobj->qual(""); };
	ok(!$@);

print("2f) Can qual() set the quality values to a single digit?\n");
	eval { $qualobj->qual(" 4"); };
	ok(!$@);

print("3. Checking that subqual() works..\n");
print("3a) Checking to see if subqual works when given proper parameters (3 and 6)...\n");
	print("There are ".($qualobj->length())." quals in the object now.\n");
	print("Setting qual to a sane value now...\n");
	$qualobj->qual("10 20 30 40 50 40 30 20 10");
	my @subquals = @{$qualobj->subqual(3,6);};
	print("\@subquals are @subquals\n");
		# i know, i know
	my @false_comparator = qw(30 40 70 40);
	my @true_comparator = qw(30 40 50 40);
	ok(!&compare_arrays(\@subquals,\@true_comparator));
	print("Checking boundry conditions for subqual\n");
	eval { $qualobj->subqual(-1,6); };
	ok($@);
	eval { $qualobj->subqual(1,6); };
	ok(!$@);
	eval { $qualobj->subqual(1,9); };
	ok(!$@);
	eval { $qualobj->subqual(9,1); };
	ok($@);

print("3. Checking display_id()...\n");
	print("\t3a) Get...\n");
	ok($qualobj->display_id() eq "chads id");
	print("\t3b) Set...\n");
	$qualobj->display_id("chads new display_id");
	ok($qualobj->display_id() eq "chads new display_id");
print("4. Checking accession_number()...\n");
	print("\t4a) Get...\n");
	ok($qualobj->accession_number() eq "chads accession_number");
	print("\t4b) Set...\n");
	$qualobj->accession_number("chads new accession_number");
	ok($qualobj->accession_number() eq "chads new accession_number");
print("5. Checking primary_id()\n");
	print("\t5a) Get...\n");
	ok($qualobj->primary_id() eq "chads primary_id");
	print("\t5b) Set...\n");
	$qualobj->primary_id("chads new primary_id");
	ok($qualobj->primary_id() eq "chads new primary_id");
print("6. Checking desc()\n");
	print("\t6a) Get...\n");
	ok($qualobj->desc() eq "chads desc");
	print("\t6b) Set...\n");
	$qualobj->desc("chads new desc");
	ok($qualobj->desc() eq "chads new desc");
print("7. Checking id()\n");
	print("\t7a) Get...\n");
	ok($qualobj->id() eq "chads new display_id");
	print("\t7b) Set...\n");
	$qualobj->id("chads new id");
	ok($qualobj->id() eq "chads new id");



print("Checking to see if PrimaryQual objects can be created from a file...\n");
my $in_qual  = Bio::SeqIO->new(-file => "<t/data/qualfile.qual" , '-format' => 'qual');
ok(1);
my $pq = $in_qual->next_qual();


print("Trying to write a primary qual object to a file...\n");
my $out_qual = Bio::SeqIO->new(-file => ">t/data/write_qual.qual",-format => 'qual');
$out_qual->write_qual(-source	=>	$pq);

print("Now creating a SeqWithQuality object and trying to write _that_...\n");
my $swq545 = Bio::Seq::SeqWithQuality->new (	-seq	=>	"ATA",
						-qual	=>	$pq
					);
$out_qual->write_qual(-source	=>	$swq545);


print("Now trying to write quals from one file to another, batchwise...\n");
$in_qual = Bio::SeqIO->new(-file => "<t/data/qualfile.qual" , -format => 'qual');
my $out_qual2 = Bio::SeqIO->new(-file => ">t/data/batch_write_qual.qual",-format => 'qual');

while ( my $batch_qual = $in_qual->next_qual() ) {
	print("Sending ".$batch_qual->id()," to write_qual\n");
	$out_qual2->write_qual(-source	=>	$batch_qual);
}

print("Done!\n");

sub display {
	my @quals;
	print("I saw these in qualfile.qual:\n");
	while ( my $qual = $in_qual->next_qual() ) {
			# ::dumpValue($qual);
		print($qual->display_id()."\n");
		@quals = @{$qual->qual()};
		print("(".scalar(@quals).") quality values.\n");
	}
}





# dumpValue($qualobj);


sub compare_arrays {
        my ($a1,$a2) = @_;
        return 1 if (scalar(@{$a1}) != scalar(@{$a2}));
        my ($v1,$v2,$diff,$curr);
        for ($curr=0;$curr<scalar(@{$a1});$curr++){
                return 1 if ($a1->[$curr] ne $a2->[$curr]);
        }
        return 0;
}
