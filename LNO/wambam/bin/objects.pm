#! /usr/bin/perl
use warnings;

package WebServiceObj;

use Class::ObjectTemplate;
@ISA = qw(ObjectTemplate Exporter);
require Exporter;
attributes qw(name documentation methods);

sub initialize {
	my $self = shift;

	$self->name();
	$self->documentation("The user was to lazy to fill in this field, Shame!");
}

sub ls {
	my $self = shift;

	opendir(DIR,'./services/') or die "Can't open dir ./services: $!\n";
	my @files = map substr($_,0,-4),grep { /.xml$/ } readdir(DIR);
	closedir DIR or die "Can't close dir ./services: $!\n";

	return (@files);
}

sub old_name {
	my ($self,$name) = @_;

	foreach ($self->ls) {
		if ($name eq $_) {return(1);}
	}
	return(0);
}

sub census {
	my $self = shift;
	my $i = 0;
	if ($self->methods) {
		while ($self->methods->[$i]) { $i++; }
	}
	return $i;
}

sub prune {
	my ($self,$name) = @_;
	my @arr;
	for (my $j=0;$j<$self->census;$j++) {
		my $method = $self->methods->[$j];
		if ($method->method ne $name) {
			push @arr,$method;
		}
	}
	return(@arr);	
}

sub get_ref {
	my ($self,$name) = @_;
	for (my $j=0;$j<$self->census;$j++) {
		if ($self->methods->[$j]->method eq $name) {
			$ref = $self->methods->[$j];
		}
	}
	return ($ref);
}

sub push_method {
	my ($self,$method_obj) = @_;
	my @a;
	my $j = 0;

	if ($self->methods) {
		for ($j=0;$j<$self->census;$j++) {
			my $method_ref = $self->methods->[$j];
			push @a, $method_ref;
		}
		$self->methods([@a,$method_obj]);
	} else {
		$self->methods([$method_obj]);
	}
	return($method_obj);
}

###
# END OF PACKAGE WebServiceObject
###

package MethodObj;

use Class::ObjectTemplate;
@ISA = qw(ObjectTemplate Exporter);
require Exporter;
attributes qw(method type request_names response_names DSN user password sqlcmd documentation module class);

sub initialize {
	my $self = shift;

}

1;

