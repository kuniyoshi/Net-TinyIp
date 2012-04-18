package Net::TinyIp;
use strict;
use warnings;
use Net::TinyIp::Address;

use overload q{""} => \&human_readable;

our $VERSION = '0.01';

=for comment
sub import {
    my $class = shift;
    my @tags  = @_;

    foreach my $tag ( @tags ) {
        my $module = join q{::}, $class, map { ucfirst } split m{_}, $tag;
        eval "require $module"
            or die;
    }
}
=cut

sub new {
    my $class   = shift;
    my $address = shift;
    my %self;

    my( $host, $cidr ) = split m{/}, $address;

    $self{host}    = Net::TinyIp::Address->from_v4( $host );
    $self{cidr}    = Net::TinyIp::Address->from_v4_cidr( $cidr );
#    $self{network}; # now writing...
#    $self{version} = $host =~ m{[.]} ? 4 : $host =~ m{[:]} ? 6 : undef;

    return bless \%self, $class;
}

sub human_readable {
    my $self = shift;
    return join q{/}, @{ $self }{ qw( host cidr ) };
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

