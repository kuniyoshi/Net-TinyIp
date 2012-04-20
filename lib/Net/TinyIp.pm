package Net::TinyIp;
use strict;
use warnings;
use Net::TinyIp::Address;
use Net::TinyIp::Address::v4;
use Net::TinyIp::Address::v6;

use overload q{""} => \&human_readable;

our $VERSION = '0.01';

### # Might import util method by this.
### sub import {
###     my $class = shift;
###     my @tags  = @_;
### 
###     foreach my $tag ( @tags ) {
###         my $module = join q{::}, $class, map { ucfirst } split m{_}, $tag;
###         eval "require $module"
###             or die;
###     }
### }

sub new {
    my $class   = shift;
    my $address = shift;
    my %self;

    my( $host, $cidr ) = split m{/}, $address;

    my $version = $host =~ m{[.]} ? 4 : $host =~ m{[:]} ? 6 : undef;
    my $module  = join q{::}, __PACKAGE__, "Address", "v$version";

    $self{host}    = $module->from_string( $host );
    $self{network} = $module->from_cidr( $cidr );

    return bless \%self, $class;
}

sub network {
    my $self = shift;

    if ( @_ ) {
        $self->{network} = shift;
    }

    return $self->{network};
}

sub host {
    my $self = shift;

    if ( @_ ) {
        $self->{host} = shift;
    }

    return $self->{host};
}

sub human_readable {
    my $self = shift;

    return join q{/}, $self->host, $self->network->cidr;
}

1;
__END__

=head1 NAME

Net::TinyIp - IP object

=head1 SYNOPSIS

  use Net::TinyIp;
  my $ip = Net::TinyIp->new( "192.168.1.1/24" );
  say $ip;

=head1 DESCRIPTION

Net::TinyIp represents IP address.

=head1 AUTHOR

kuniyoshi E<lt>kuniyoshi@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

