package Audio::Tools;

use strict;
use vars qw( $VERSION );

$VERSION = '0.01';

=head1 NAME

Audio::Tools - Common Tools for Audio::Wav, Audio::Mix & Audio::CoolEdit

=head1 DESCRIPTION

The modules in this package are ByteOrder, Time & Fades.

They are all independent and the only use, so far, for Audio::Tools is a place to hold the documentation.

ByteOrder is currently the unpacking rules for little endian machines,
I've seperated this from the other modules for ease of porting to big endian machines.

Fades is a collection of algorithms for fading in/ out audio files.

Time is a collection of tools for conversion between time, samples & bytes among other things.

=head1 AUTHOR

Nick Peskett - nick@soup.demon.co.uk

=head1 SEE ALSO

L<Audio::Tools::ByteOrder>

L<Audio::Tools::Time>

L<Audio::Tools::Fades>

L<Audio::Wav>

L<Audio::Mix>

L<Audio::CoolEdit>

=cut

1;
__END__
