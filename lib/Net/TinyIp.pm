package Net::TinyIp;
use strict;
use warnings;
use Carp qw( croak );
use Math::BigInt;

our $VERSION = '0.01';

sub import {
    my $class = shift;
    my @tags;

    foreach my $tag ( @_ ) {
        my $module = join q{::}, $class, map { ucfirst } split m{_}, $tag;
        eval "require $module"
            or die;
    }
}

sub parse_int {
    my $class = shift;
    my $ascii = shift;

    return $class->parse_int_as_v4( $ascii )
        if $ascii =~ m{ [.] }msx;
    return $class->parse_int_as_v6( $ascii )
        if $ascii =~ m{ [:] }msx;
}

sub parse_int_as_v4 {
    my $class = shift;
    my $ascii = shift;

    return Math::BigInt->from_bin(
        join q{}, q{0b}, map { sprintf "%08b", $_ } split m{[.]}, $ascii,
    );
}

sub parse_int_as_v6 {
    my $class = shift;
    my $ascii = shift;

    return Math::BigInt->from_hex(
        join q{}, q{0x}, map { $_ } split m{[:]}, $ascii,
    );
}

sub to_ascii {
    my $class   = shift;
    my $int     = shift;
    my $version = shift || 4;
    my $method  = "to_ascii_as_v$version";

    return $class->$method( $int );
}

sub to_ascii_as_v4 {
    my $class = shift;
    my $int   = shift;
    ( my $bin_str = $int->as_bin ) =~ s{\A 0b }{}msx;

    $bin_str = "0" x ( 8 * 4 - length $bin_str ) . $bin_str;

    return join q{.}, map { sprintf "%03d", eval "0b$_" } ( $bin_str =~ m{ (\d{8}) }gmsx );
}

sub new {
    my $class = shift;
    my( $host, $mask ) = @_;
    my %self;

    croak "Host required"
        unless defined $host;

    $self{host}    = $class->parse_int( $host );
    $self{mask}    = $class->parse_int( $mask );
    $self{version} = $host =~ m{[.]} ? 4 : $host =~ m{[:]} ? 6 : undef;

    return bless \%self, $class;
}

sub cidr { length sprintf "%s", shift->{mask}->as_bin =~ m{\A 0b (1+) }msx }

sub human_readable {
    my $self = shift;

    return join q{/}, $self->to_ascii( @{ $self }{ qw( host version ) } ), $self->cidr;
}

1;
__END__

=head1 NAME

Net::TinyIp - IP object

=head1 SYNOPSIS

  use Net::TinyIp;
  my $ip = Net::TinyIp->new( "192.168.1.1", "255.255.255.0" );
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

