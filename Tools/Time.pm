package Audio::Tools::Time;

use strict;
use vars qw( $VERSION );

$VERSION = '0.01';

=head1 NAME

Audio::Tools::Time - time / sample / byte conversion tools.

=head1 DESCRIPTION

Tools for converting bytes into samples, samples into time etc.

=head1 SYNOPSIS

	my $time = new Audio::Tools::Time 44100, 16, 2;
	my $bytes = $time -> nice_bytes( 11025 );
	my $sample = $time -> bytes_to_samples( $bytes );
	my $secs = $time -> samples_to_seconds( $sample );
	my( $mins, $secs, $fract_secs )
		= $time -> split_time( $secs );
	my $dao_time = $time -> dao_time( $secs );

=head1 AUTHOR

Nick Peskett - nick@soup.demon.co.uk

=head1 SEE ALSO

L<Audio::Wav>

L<Audio::Mix>

L<Audio::CoolEdit>

=head1 METHODS

=head2 new

Returns a blessed Audio::Tools::Time object.

	my $time = new Audio::Tools::Time sample_rate, bits_per_sample, channels;

Where;

	sample_rate	= number of samples per second (44100 is cd quality)
	bits_per_sample	= number of bits per samples (16 is cd quality)
	channels	= number of channels of sound (stereo is 2)

=cut

sub new {
	my $class = shift;
	my @needed = qw( sample_rate bits_sample channels );
	my $self = {};
	my @missing;
	foreach my $need ( @needed ) {
		$self -> {$need} = shift;
		next if defined( $self -> {$need} );
		push @missing, $need;
	}
	if ( @missing ) {
		die "I need parameters; ", join( ', ', @needed ),
			"\nI got ", join( ', ', map "$_=" . $self ->{$_}, @needed ), "\n";
	}
	bless $self, $class;
	$self -> _init();
	return $self;
}

=head2 samples_to_bytes

Converts a sample offset to it's byte offset.

	my $bytes = $time -> samples_to_bytes( $sample );

=cut

sub samples_to_bytes {
	my $self = shift;
	my $samples = shift;
	return $samples * $self -> {'block_align'};
}

=head2 bytes_to_samples

Converts a byte offset to it's sample offset.

	my $sample = $time -> bytes_to_samples( $bytes );

=cut

sub bytes_to_samples {
	my $self = shift;
	my $bytes = shift;
	return $bytes / $self -> {'block_align'};
}

=head2 samples_to_seconds

Converts a sample offset to it's position as floating point
seconds.

	my $secs = $time -> samples_to_seconds( $sample );

=cut

sub samples_to_seconds {
	my $self = shift;
	my $samples = shift;
	return $samples / $self -> {'sample_rate'};
}

=head2 bytes_to_seconds

Converts a byte offset to it's position as floating point
seconds.

	my $secs = $time -> bytes_to_seconds( $samples );

=cut

sub bytes_to_seconds {
	my $self = shift;
	my $bytes = shift;
	return $bytes / $self -> {'bytes_sec'};
}

=head2 seconds_to_samples

Converts a position in seconds (can be floating point) to
it's sample offset.

	my $sample = $time -> seconds_to_samples( $secs );

=cut

sub seconds_to_samples {
	my $self = shift;
	my $time = shift;
	return $time * $self -> {'sample_rate'};
}

=head2 seconds_to_bytes

Converts a position in seconds (can be floating point) to
it's byte offset.

	my $sample = $time -> seconds_to_bytes( $secs );

=cut

sub seconds_to_bytes { # was time_samples
	my $self = shift;
	my $time = shift;
	return $self -> nice_bytes( $time * $self -> {'bytes_sec'} );
}

=head2 nice_bytes

Rounds down a byte offset to a appropriate byte offset for the
current settings.

	$bytes = $time -> nice_bytes( $bytes );

=cut

sub nice_bytes {
	my $self = shift;
	my $bytes = shift;
	$bytes -= $bytes % $self -> {'block_align'};
	return int( $bytes );
}

=head2 split_time

Converts a floating point seconds position to minutes,
seconds & fractional seconds.

	my( $mins, $secs, $fract_secs )
		= $time -> split_time( $secs );

=cut

sub split_time { # used to take bytes
	my $self = shift;
	my $in_secs = shift;
	my $mins = int( $in_secs / 60 );
	my $secs = int( $in_secs % 60 );
	my $fract = $in_secs;
	$fract -= ( $mins * 60 ) + $secs;
	return ( $mins, $secs, $fract );
}

=head2 dao_time

Converts a floating point seconds position to a string containing
the format used by disk-at-once & CDRWin.
(L<http://www.goldenhawk.com>)

	my $dao_time = $time -> dao_time( $secs );

=cut

sub dao_time { # used to take bytes
	my $self = shift;
	my( $mins, $secs, $frames ) = $self -> split_time( shift );
	# mm:ss:ff
	$frames = int( $frames * 75 );
	my $output = sprintf( "%02d:%02d:%02d", $mins, $secs, $frames );
	return $output;
}

=head2 nice_time

Converts a floating point seconds position into a string that
verbosely describes the time. If $terse is true then the output
will only show the most significant value (to one decimal place
if hour or minute).

	print $time -> nice_time( 90 );
	# returns "1 min, 30 secs"
	print $time -> nice_time( 90, 1 );
	# returns "1.5 mins"

=cut

sub nice_time {
	my $self = shift;
	my $secs = shift;
	my $brief = shift;
	my @names = qw( hour min sec );
	my @times = ( 3600, 60, 1 );
	my( @output, $pic );
	for my $id ( 0 .. 2 ) {
		next unless $secs >= $times[$id];
		$pic = ( $id < 2 && $brief ) ? '%6.1f' : '%6d';
		my $res = sprintf( $pic, $secs / $times[$id] );
		$res =~ s/\.0$// if ( $id < 2 && $brief );
		$res =~ s/^ +//;
		my $text = join ' ', $res, $names[$id];
		$text .= 's' unless $res eq '1';
		push @output, $text;
		last if $brief;
		$secs = $secs % $times[$id];
		last unless $secs;
	}
	@output = ( '0 ' . $names[2] . 's' ) unless @output;
	return join( ', ', @output );
}

=head2 dao_cue_file

Writes a cue file in the format used by disk-at-once & CDRWin.
(L<http://www.goldenhawk.com>)

	$time -> dao_cue_file( $breaks, './audio.wav', './output.cue' );

Where $breaks is a reference to an array of byte offsets.

=cut

sub dao_cue_file {
	my $self = shift;

	my $breaks = shift;
	my $file = shift;
	my $to_file = shift;

	require FileHandle;
	my $handle = new FileHandle '>' . $to_file;
	die "unable to open cue file '$to_file'" unless defined( $handle );

	my @output = ( "FILE $file WAVE" );
	foreach my $id ( 0 .. $#$breaks ) {
		my $pos = $breaks -> [$id];
		my $secs = $self -> bytes_to_seconds( $pos );
		my $daotime = $self -> dao_time( $secs );
		my $track = sprintf( "%02d", $id + 1 );
		push @output, "\tTRACK $track AUDIO";
#		push @output, "\tFLAGS DCP";
		push @output, "\t\tINDEX 01 $daotime";
	}
	print $handle join( "\n", @output, '' );
	$handle -> close();
}

=head2 block_align

Returns the current block alignment,
ie 44.1khz 16 bit stereo: 1 sample = 4 bytes

	my block_align = $time -> block_align();

=cut

sub block_align {
	my $self = shift;
	return $self -> {'block_align'};
}

sub un_deci_time {
	my $self = shift;
	my $time = shift;
	my( $mins, $secs ) = split /:/, $time;
	$mins *= 60;
	my $bytes = $self -> {'bytes_sec'} * ( $mins + $secs );
	print "do($time) $mins - $secs [$bytes]\n";
	return int( $bytes );
}

sub deci_time {
	my $self = shift;
	my $bytes = shift;
	my $points = 3;
	my( $mins, $secs, $frames ) = $self -> split_time( $bytes );
	my $output = sprintf( '%02d:%02d.%0' . $points . 'd', $mins, $secs, $frames * ( 10 ** $points ) );
	return $output;
}

#---------private functions-------------------------------

sub _init {
	my $self = shift;
	my( $rate, $bits, $channels ) = map $self -> {$_}, qw( sample_rate bits_sample channels );
	my $bits_bytes = int $bits / 8;
	$bits_bytes ++ if $bits % 8;
	$self -> {'bytes_sec'} = $channels * $rate * $bits_bytes;
	$self -> {'block_align'} = $channels * $bits_bytes;
}

1;