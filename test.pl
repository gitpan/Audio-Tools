$| = 1;

my %mods	= (
		  'tools'	=> 'Audio::Tools',
		  'byteorder'	=> 'Audio::Tools::ByteOrder',
		  'time'	=> 'Audio::Tools::Time',
		  'fades'	=> 'Audio::Tools::Fades',
		  );

my %present;
foreach my $type ( keys %mods ) {
	$present{$type} = eval "require $mods{$type}";
}

my $tests = 7;

print "1..$tests\n";

my $cnt;
foreach $type ( qw( tools byteorder time fades ) ) {
	$cnt ++;
	unless ( $present{$type} ) {
		print "not ok $cnt, unable to load $mods{$type}\n";
		die;
	} else {
		print "ok $cnt, $mods{$type} loadable\n";
	}
}

print "\nTesting Audio::Tools::ByteOrder\n";

my $order = new Audio::Tools::ByteOrder;

print "pack_type;\n";
&dump_hash( $order -> pack_type() );

print "pack_length;\n";
&dump_hash( $order -> pack_length() );

$cnt ++;
print "ok $cnt\n";

my $up_to = 5;
my @names = qw( in out );
my $volume = 1;

print "\nTesting Audio::Tools::Fades\n";
my $fades = new Audio::Tools::Fades;

foreach my $type ( qw( linear exp invexp trig invtrig ) ) {
	for my $direction ( 0, 1 ) {
		my $fade = $fades -> fade( $up_to, $direction, $type );
		print "fade $names[$direction] type: $type;\n\t";
		for my $sample ( 0 .. $up_to ) {
			printf ' %2d->%2.2f', $sample, &$fade( $sample, $volume );
		}
		print "\n";
	}
}

$cnt ++;
print "ok $cnt\n";

print "\nTesting Audio::Tools::Time (44100, 16, 2)\n";
my $time = Audio::Tools::Time -> new( 44100, 16, 2 );

my $bytes = $time -> seconds_to_bytes( 90 );;
print "bytes($bytes) - from 90 secs\n";

$bytes = $time -> nice_bytes( $bytes );
print "nice_bytes($bytes)\n";

my $sample = $time -> bytes_to_samples( $bytes );
print "bytes_to_samples($sample)\n";

my $secs = $time -> samples_to_seconds( $sample );
print "samples_to_seconds($secs)\n";

$secs = $time -> bytes_to_seconds( $bytes );
print "bytes_to_seconds($secs)\n";

my $dao_time = $time -> dao_time( $secs );
print "dao_time($dao_time)\n";

my( $mins, $insecs, $fract_secs )
	= $time -> split_time( $secs );
print "split_time($mins, $insecs, $fract_secs)\n";

print "secs($secs)\n";

my $text = $time -> nice_time( $secs );
print "full nice_time($text)\n";

$text = $time -> nice_time( $secs, 1 );
print "brief nice_time($text)\n";

$cnt ++;
print "ok $cnt\n";

sub dump_hash {
	my $hash = shift;
	foreach my $key ( sort keys %$hash ) {
		print "\t$key -> ", $hash -> {$key}, "\n";
	}
}
