function dummy()
assert(0)
-d function dummy()\nassert(0)
#!/usr/bin/perl

use warnings;
use File::Basename;

$run = 1; 				# 0 to debug this script, 1 otherwise

$thisfile  = fileparse($0);

#if (@ARGV < 5){
#  print STDERR "Usage: $0 cpd_type N arity\n";
#  exit 1;
#}

# read in command line args
$cpd_type = $ARGV[0];
$N = $ARGV[1];
$arity = $ARGV[2];
if ( $arity < 2 ){
	$discretize = 0;
	$discrete_or_cts = 'cts';
}else{
	$discretize = 1;
	$discrete_or_cts = 'discrete';
}	

# to determine output directory: results/2014_04_22/$
$outputdir = "../results/2014_04_022/$method/$network/";

# get timestamp to append to filenames
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
my $timestamp = sprintf ( "%04d%02d%02d%02d%02d%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);
$runfile = $timestamp . "-" . $thisfile;
$nodefile = "node-" . $timestamp . ".txt";


	print "\n\nEXPERIMENT #$exp\n\n";
	
	$datadir_full = $datadir . $exp . "/";
	$outputdir_full = $outputdir . $exp;
	if(!(-d $outputdir)) {
		print "mkdir($outputdir)\n";
		system("mkdir -p $outputdir");
	}
	if(!(-d $outputdir_full)) {
		print "mkdir($outputdir_full)\n";
		system("mkdir -p $outputdir_full");
	}

	# Copy this run script to output directory
	`cp $0 $outputdir_full/$runfile`;

	# Also record which machine this was run on
	`uname -n >$outputdir_full/$nodefile`;

	for($N=$N_start; $N<=$N_end; $N+=$N_increment) {   	# ***1 
	#foreach(@Narray){					# ***2
		#$N = $_;					# ***2
		print "\n$N\n";

		$time_file = $outputdir_full . "/bscore_time$N.dat";
		$model_file = $outputdir_full . "/model$N.mod";
		$mec_file = $outputdir_full . "/output$N.txt";
		#$mec_file2 = $outputdir_full . "/bn$N.mec";
		$bscore_file = $outputdir_full . "/bscore$N.out"; 
		$data_file = $datadir_full . $network . $N . ".dat";

		# Create model (score) file from this
		$start_time = time;
		$cmd = "$bscore $bic_bde -bde_alpha $bde_alpha -nodes $nodes -maxpa $maxpa -sb2_alpha $sb2_alpha -data $data_file -mod_out $model_file -edge_scores $eta -sb $sb -psi2 $psi > $bscore_file";
		print "$cmd\n";
		if ($run) {system($cmd);}
		print " ";
		$end_time = time;
		$total_time = $end_time - $start_time;
		open(FILE, ">$time_file");
		print FILE $total_time;
		close(FILE);

		# Create settings file
		`cp gobnilp.set $outputdir_full/gobnilp$N.set`;

		# sed commands for Linux (see original github script for corresonding commands for OSX) 
		`sed -i'' 's|%DIR|$outputdir_full|' $outputdir_full/gobnilp$N.set`; #in-place editing: '' is the SUFFIX in -i[SUFFIX]
		`sed -i'' 's/%N/$N/' $outputdir_full/gobnilp$N.set`;

		# Run (note, need "gobnilp.set") in same directory
		$cmd = "$gobnilp -g$outputdir_full/gobnilp$N.set $model_file > $mec_file";
		if ($run) {system($cmd);}

	}
}


