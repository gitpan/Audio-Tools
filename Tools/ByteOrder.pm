package Audio::Tools::ByteOrder;

use strict;
use vars qw( $VERSION );

$VERSION = '0.01';

=head1 NAME

Audio::Tools::ByteOrder - Unpacking rules for little endian machines.

=head1 SYNOPSIS

	use Audio::Tools::ByteOrder;
	my $pack_order = new Audio::Tools::ByteOrder;
	my $pack_type = $pack_order -> pack_type(),
	my $pack_length = $pack_order -> pack_length(),

=head1 DESCRIPTION

This is currently the unpacking rules for little endian machines,

=head1 AUTHOR

Nick Peskett - nick@soup.demon.co.uk

=head1 SEE ALSO

L<Audio::Tools>

=cut

my $double = 'd';
#my $int = 'i';
my $int = 'L';
my $word = 'S';
my $stringz = 'a';

my $long = 'l';
my $ulong = 'L';
my $short = 's';
my $ushort = 'S';
my $char = 'c';
my $uchar = 'C';

my %out_formats =
		(
#			'z'		=> $stringz,
			'double'	=> $double,
			'int'		=> $int,
			'word'		=> $word,

			'long'		=> $long,
			'ulong'		=> $ulong,
			'short'		=> $short,
			'ushort'	=> $short,
			'char'		=> $char,
			'uchar'		=> $uchar,
		);

my %len_formats;
foreach my $format ( keys %out_formats ) {
	my $type = $out_formats{ $format };
	my $test = pack( $type, 0 );
	$len_formats{$type} = length( $test );
#	print "$format ($type) = $len_formats{$type}\n";
}

=head1 METHODS

=head2 new

Returns a blessed Audio::Tools::ByteOrder object.

	my $pack_order = new Audio::Tools::ByteOrder;

=cut

sub new {
	my $class = shift;
	my $self =	{
			'pack_type'	=> { %out_formats },
			'pack_length'	=> { %len_formats },
			};
	bless $self, $class;
	return $self;
}

=head2 pack_type

Returns a reference to a hash containing the pack types for various data formats.

	my $pack_type = $pack_order -> pack_type(),

=cut

sub pack_type {
	my $self = shift;
	return $self -> {'pack_type'};
}

=head2 pack_length

Returns a reference to a hash containing the packed lengths for various data formats.

	my $pack_length = $pack_order -> pack_length(),

=cut

sub pack_length {
	my $self = shift;
	return $self -> {'pack_length'};
}

1;