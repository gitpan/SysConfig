package SysConfig;

require 5.005;
use strict;
use warnings;

our $VERSION = '0.1';
our $AUTOLOAD;

#####################################################################
# Config.pm
# by Patrick Devine
#
# WARNING:
#
# This software is no where near finished and lots of stuff will
# probably change before it is officially released.  In particular
# the actual Class will probably be renamed and have seperate
# Classes which will inherit the base structures in order to do
# new and interesting things.
#

#####################################################################
# method:	new
# function:	constructor method for creating an object

sub new {
  my $proto	= shift;
  my $class	= ref( $proto ) || $proto;
  my $self	= {};

  bless( $self, $class );

  $self;

}


#####################################################################
# method:	DESTROY
# function:	destructor method for object cleanup

sub DESTROY { };


#####################################################################
# method:	AUTOLOAD
# function:	autoload function for creating undefined methods

sub AUTOLOAD {
  my $self	= shift;
  my $params	= shift;

  my $name	= $AUTOLOAD;
  
  $name =~ s/ .* : //x;

  if( ref( $params ) eq 'HASH' ) {
    for( keys %{ $params } ) {

      my $prefix = substr( $_, 0, 1 );
      my $param = substr( $_, 1 );

      if( $prefix eq '-' ) {
        delete $self->{settings}->{$name}->{$param};
      } elsif( $prefix eq '+' ) {
        $self->{settings}->{$name}->{$param} = $$params{$_};
      } else {
        $self->{settings}->{$name}->{$_} = $$params{$_};
      }

    }
  } else {
    $self->{settings}->{$name} = { $name => $params };  
  }

}


#####################################################################
# method:	package|service
# function:	adds or removes packages or services

sub package {
  my $self	= shift;
  my $params	= shift;

  _set_hashofhash( $self, 'package', $params );

}

#sub service {
#  my $self	= shift;
#  my $params	= shift;
#
#  _set_hashofhash( $self, 'service', $params );
#
#}


#####################################################################
# method:	_set_hashofhash
# function:	turn settings inside of our hash on or off

sub _set_hashofhash {
  my $self	= shift;
  my $type	= shift;
  my $params	= shift;

  if( ref( $params ) eq 'ARRAY' ) {
    for( @{ $params } ) {

      my $prefix = substr( $_, 0, 1 );
      my $param = substr( $_, 1 );

      if( $prefix eq '-' ) {
	$self->{settings}->{$type}->{$param} = 'off';
      } elsif( $prefix eq '+' ) {
	$self->{settings}->{$type}->{$param} = 'on';
      } else {
	$self->{settings}->{$type}->{$_} = 'on';
      }

    }
  } else {
    my $prefix = substr( $params, 0, 1 );
    my $param = substr( $params, 1 );

    if( $prefix eq '-' ) {
      $self->{settings}->{$type}->{$param} = 'off';
    } elsif( $prefix eq '+' ) {
      $self->{settings}->{$type}->{$param} = 'on';
    } else {
      $self->{settings}->{$type}->{$params} = 'on';
    }
  } 

}


#####################################################################
# method:	partition
# function:	adds or removes partitions from the partition list

sub part {
  my $self	= shift;
  my $params	= shift;

  _set_listofhash( $self, 'dir', 'partition', $params );

}

sub partition {
  my $self	= shift;
  my $params	= shift;

  _set_listofhash( $self, 'dir', 'partition', $params );

}

sub raid {
  my $self	= shift;
  my $params	= shift;

  _set_listofhash( $self, 'device', 'raid', $params );

}

sub service {
  my $self	= shift;
  my $params	= shift;

  _set_listofhash( $self, 'name', 'service', $params );

}

sub device {
  my $self	= shift;
  my $params	= shift;

  _set_listofhash( $self, 'module', 'device', $params );

}

sub _set_listofhash {
  my $self	= shift;
  my $key	= shift;
  my $type	= shift;
  my $params	= shift;

  if( ref( $params ) eq 'HASH' ) {

    return unless exists $$params{$key};

    my $prefix = substr( $$params{$key}, 0, 1 );
    my $param = substr( $$params{$key}, 1 );

    if( $prefix eq '-' ) {
      my @list;
      for( @{ $self->{settings}->{$type} } ) {
        push( @list, $_ )
	  unless $_->{$key} eq $param;
      }
      @{ $self->{settings}->{$type} } = @list;
    } elsif( $prefix eq '+' ) {
      $$params{$key} = $param;
      push @{ $self->{settings}->{$type} }, $params;
    } else {
      push @{ $self->{settings}->{$type} }, $params;
    }
  }

}


1;

__END__

=pod
=head1 NAME

SysConfig - A base module for describing how to install a computer.

=head1 SYNOPSIS

This module is intended only as a base class.  You must use it in conjunction
with other classes such as SysConfig::Kickstart or SysConfig::XML in order to
make it do anything very useful.

=head1 DESCRIPTION


=head1 AUTHOR

Written by Patrick Devine (patrick@bubblehockey.org), (c) 2001.

=cut

