package Audio::Tools::Fades;

use strict;
use vars qw( $VERSION );

$VERSION = '0.01';

=head1 NAME

Audio::Tools::Fades - Fading in & out algorithms.

=head1 DESCRIPTION

Fades is a collection of algorithms for fading in/ out audio files.

=head1 SYNOPSIS

	use Audio::Tools::Fades;

	my $up_to = 5;
	my @names = qw( in out );
	my $volume = 1;

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

=head1 AUTHOR

Nick Peskett - nick@soup.demon.co.uk

=head1 SEE ALSO

L<Audio::Wav>

L<Audio::Mix>

L<Audio::CoolEdit>

=cut

my $pi = 22 / 14;

my %fade_types =	(
				'linear'	=> sub { $_[0] / $_[1] },
				'exp'		=> sub { ( $_[0] / $_[1] ) ** .5 },
				'invexp'	=> sub { ( $_[0] / $_[1] ) ** 2 },
				'trig'		=> sub { sin( ( $_[0] / $_[1] ) * $pi ) },
				'invtrig'	=> sub { 1 - ( cos( ( $_[0] / $_[1] ) * $pi ) ) },
			);

=head1 METHODS

=head2 new

Returns a blessed Audio::Tools::Fades object.

	my $fades = new Audio::Tools::Fades;

=cut

sub new {
	my $class = shift;
	my $details = shift;
	my $self = {};
	bless $self, $class;
	return $self;
}

=head2 fade

Returns a reference to a subroutine that is initialised to the length of samples the fade is to last for.
The subroutine returned takes the current sample offset & the current sample value as parameters.
In the example I have used sample value 1 so you can see the effect of the fade.

	my $fade = $fades -> fade( $length, $direction, $type );
	for my $sample ( 0 .. $length ) {
		printf ' %2d->%2.2f', $sample, &$fade( $sample, 1 );
	}
	print "\n";


Where;

	$length		= length of fade
	$direction	= 0 for in, 1 for out
	$type is one of;
		linear	= smooth gradient
		exp	= exponential (gets loud quickly)
		invexp	= inverse exponential (gets loud slowly)
		trig	= trigonomic, roughly in between linear & exp
		invtrig	= inverse trigonomic

=cut

sub fade {
	my $self = shift;
	my $leng = shift;
	my $fade_out = shift;
	my $type = shift;

	die "unknown fade type '$type'" unless ( $type && exists( $fade_types{$type} ) );

	my $sub = $fade_types{$type};
	my $sub_out;
	if ( $fade_out ) {
		$sub_out = sub {
				my $samp = shift;
				return map $_ * &$sub( $leng - $samp, $leng ), @_;
				};
	} else {
		$sub_out = sub {
				my $samp = shift;
				return map $_ * &$sub( $samp, $leng ), @_;
				};
	}
	return $sub_out;
}

1;
