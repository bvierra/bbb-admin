package WebService::BigBlueButton::API;

use strict;
use Carp ();
use Digest::SHA qw( sha1_hex );
use LWP::UserAgent ();
use XML::Simple    ();
use vars qw( $VERSION );

$VERSION = '0.01';

=head1 NAME

WebService::BigBlueButton::API - An API to interact with BigBlueButton

=head1 SYNOPSIS

    use WebService::BigBlueButton::API;

    my $api = WebService::BigBlueButton::API->new(
    	server => 'http://localhost/bigbluebutton/api',
    	secret => 'myveryspecialsecret',
    );
    my %OPTS = ( random => '1234');
    my $ret = $api->call('getMeetings',%OPTS); 

=head1 DESCRIPTION

Allows you to easily interact with BigBlueButton's API.

BigBlueButton is an opensource web conferencing system with integrated voice, 
text chat, video, presentation, and desktop sharing. More information is 
available at: http://bigbluebutton.org

=head1 METHODS

=head2 new($method,%OPTS)

The C<new()> contructor method instantiates a new WebService::BigBlueButton::API object. 
The following parameters are supported:

=over

=item * server - The full url for the api of your BigBlueButton Server B<required>

=item * salt - The salt for the BigBlueServer B<required>

=item * debug - 1 to turn debugging on (Defaults to 0)

=item * user-agent - The user agent to make the request with (Defaults to WebServices::BigBlueButton::API/$VERSION)

=item * error_log - Where you would like the errors and debug messages printed to (Defaults to STDERR)

=back

=cut

sub new {
	my ( $class, %OPTS ) = @_;
	my $self = {};
	bless $self, $class;

	$self->{'debug'} = $OPTS{'debug'} || 0;
	$self->{'user-agent'} = $OPTS{'user-agent'}
		|| 'WebServices::BigBlueButton::API/' . $VERSION;

	if ( exists $OPTS{'error_log'} && $OPTS{'error_log'} ne 'STDERR' ) {
		if ( !open( $self->{'error_fh'}, '>>', $OPTS{'error_log'} ) ) {
			print STDERR
				"Unable to open $OPTS{'error_log'} for writing, defaulting to STDERR for error logging: $@\n";
			$self->{'error_fh'} = \*STDERR;
		}
	}
	else {
		$self->{'error_fh'} = \*STDERR;
	}

	if ( $OPTS{'salt'} ) {
		$self->{'salt'} = $OPTS{'salt'};
	}
	else {
		Carp::confess('salt is a required parameter');
	}

	if ( $OPTS{'server'} ) {
		$self->{'server'} = $OPTS{'server'};
	}
	else {
		Carp::confess('server is a required parameter');
	}

	return $self;
}

=head2 call($method,%OPTS)

The C<call()> method is used for making the actual call to the API server. This will take the method along
with the options needed for the call and will create the needed checksum along with making the call.

This method does not know what methods are valid nor what options they need, so please make sure to check the
documentation L<http://code.google.com/p/bigbluebutton/wiki/API> to make sure you are supplying required values.

This method will process the XML and return a hash of what was returned from the API.
If there was an error connecting to the server, it will return a string starting with "ERROR: " and followed
by the error returned from LWP.

Both $method and %OPTS are B<required>

=cut

sub call {
	my ( $self, $method, %OPTS ) = @_;
	Carp::confess('[call] You must pass both a method and options') if !%OPTS;
	my $params;
	$self->debug("Parameters passed to call:") if $self->{'debug'};
	while ( my ( $param, $val ) = each(%OPTS) ) {
		$params .= "&" if $params;
		$params .= "$param=$val";
		$self->debug(" $param: $val") if $self->{'debug'};
	}
	my $checksum = create_checksum( $self, $method, $params );
	$params .= '&checksum=' . $checksum;
	$self->debug("Checksum: $checksum") if $self->{'debug'};

	my $url = $self->{'server'} . '/' . $method . '?' . $params;

	my $ua = LWP::UserAgent->new;
	$ua->agent( $self->{'user-agent'} );
	my $req = HTTP::Request->new( GET => $url );
	$self->debug( 'Connecting to: ' . $url ) if $self->{'debug'};
	my $res = $ua->request($req);
	if ( !$res->is_success ) {
		return ( 'Error connecting to server: ' . $res->status_line );
	}
	else {
		my $ref = XML::Simple->new();
		return ( $ref->XMLin( $res->content ) );
	}
}

=head2 Internal Methods

=head3 create_checksum

B<Used Internally>
Creates the checksum needed for the API call. 

=cut

sub create_checksum {
	my ( $self, $method, $params ) = @_;
	Carp::confess('[create_checksum] Missing method') if !$method;
	Carp::confess('[create_checksum] Missing params') if !$params;
	return ( sha1_hex( $method . $params . $self->{'salt'} ) );
}

=head3 debug

B<Used Internally>
Used for printing debugging messages

=cut

sub debug {
	my ( $self, $msg ) = @_;
	print { $self->{'error_fh'} } "debug: " . $msg . "\n";
}

=head1 AUTHOR

"Billy Vierra", C<< <"bvierra at cpan.org"> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-webservice-bigbluebutton-api at rt.cpan.org>, 
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-BigBlueButton-API>.  
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::BigBlueButton::API


You can also look for information at:

=over 4

=item * GitHub

L<https://github.com/bvierra/bbb-admin>

=item * Big Blue Button Website

L<http://bigbluebutton.org/>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-BigBlueButton-API>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-BigBlueButton-API>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-BigBlueButton-API>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-BigBlueButton-API/>

=back


=head1 ACKNOWLEDGEMENTS

The Big Blue Button team for making sure a great website

=head1 LICENSE AND COPYRIGHT

Copyright 2011 "Billy Vierra".

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of WebService::BigBlueButton::API
