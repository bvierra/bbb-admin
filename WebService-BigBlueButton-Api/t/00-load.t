#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'WebService::BigBlueButton::API' ) || print "Bail out!
";
}

diag( "Testing WebService::BigBlueButton::API $WebService::BigBlueButton::API::VERSION, Perl $], $^X" );
