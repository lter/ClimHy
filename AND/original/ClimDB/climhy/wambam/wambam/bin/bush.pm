#! perl -w
use strict;

package bush;
use SOAP::Lite +trace => qw(debug);
sub bushisms {
	my $result = SOAP::Lite
		->uri("urn:RandomBushism")
		->proxy("http://greg.froh.ca/fun/random_bushism/soap/index.php")
		->getRandomBushism();

	my $a = $result->valueof('//Envelope/Body/getRandomBushismResponse/RandomBushism/bushism');
	my $b = $result->valueof('//Envelope/Body/getRandomBushismResponse/RandomBushism/context');
	print "\n\n\n\n$a\n$b\n\n";
	return($a,$b);
}
1;
