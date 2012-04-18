package Net::TinyIp::Address;
use strict;
use warnings;
use base "Math::BigInt";

use overload q{""} => \&human_readable;

sub from_bin {
    my $class   = shift;
    my $big_int = $class->SUPER::new( @_ );

    return bless $big_int, $class;
}

sub from_hex {
    my $class   = shift;
    my $big_int = $class->SUPER::new( @_ );

    return bless $big_int, $class;
}

sub from_v4 {
    my $class = shift;
    my $str   = shift;
    my $self  = $class->from_bin(
        join q{}, q{0b}, map { sprintf "%08b", $_ } split m{[.]}, $str,
    );
    $self->address_type( "host" );

    return $self;
}

sub from_v6 {
    my $class = shift;
    my $str   = shift;
    my $self  = $class->from_hex(
        join q{}, q{0x}, map { $_ } split m{[:]}, $str,
    );
    $self->address_type( "host" );

    return $self;
}

sub from_cidr {
    my $class              = shift;
    my( $prefix, $length ) = @{ { @_ } }{ qw( prefix length ) };
    my $self               = $class->from_bin(
        join q{}, q{0b}, ( "1" x $prefix ), ( "0" x ( $length - $prefix ) ),
    );
    $self->address_type( "network" );

    return $self;
}

sub from_v4_cidr { shift->from_cidr( prefix => shift, length => 32  ) }

sub from_v6_cidr { shift->from_cidr( prefix => shift, length => 128 ) }

sub version {
    my $self = shift;

    if ( @_ ) {
        $self->{version} = shift;
    }

    return $self->{version};
}

sub address_type {
    my $self = shift;

    if ( @_ ) {
        $self->{address_type} = shift;
    }

    return $self->{address_type};
}

sub is_host { shift->address_type eq "host" }

sub is_network { shift->address_type eq "network" }

sub as_v4 {
    my $self   = shift;
    my $format = shift || q{%03d};
    ( my $bin_str = $self->as_bin ) =~ s{\A 0b }{}msx;

    $bin_str = "0" x ( 8 * 4 - length $bin_str ) . $bin_str;

    return join q{.}, map { sprintf $format, eval "0b$_" } ( $bin_str =~ m{ (\d{8}) }gmsx );
}

sub as_v6 {
    my $self = shift;
    ( my $bin_str = $self->as_bin ) =~ s{\A 0b }{}msx;

    $bin_str = "0" x ( 16 * 8 - length $bin_str ) . $bin_str;

    return join q{:}, map { sprintf "%04x", eval "0b$_" } ( $bin_str =~ m{ (\d{16}) }gmsx );
}

sub as_cidr { length sprintf "%s", shift->as_bin =~ m{\A 0b (1+) }msx }

sub human_readable {
    my $self = shift;
    my $what = $self->is_host ? ( sprintf "as_v%d", $self->version || 4 ) : "as_cidr";

    return $self->$what;
}

1;
__END__

=head1 NAME

Net::TinyIp::Address - IP Address object

=head1 SYNOPSIS

  use Net::TinyIp::Address;
  my $ip = Net::TinyIp::Address->from_v4( "192.168.1.1" );
  say $ip;

=head1 DESCRIPTION

Blah blha blha.

=head1 AUTHOR

kuniyoshi E<lt>kuniyoshi@cpan.orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

