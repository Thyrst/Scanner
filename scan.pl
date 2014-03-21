#!/usr/bin/perl  -w
# Simple TCP scanner by Thyrst'
#
# This script is licensed under a Do What the Fuck You Want to Public License
# (http://www.wtfpl.net/txt/copying/).
#
use strict;
use IO::Socket;
use Net::Ping;
use Time::HiRes qw(tv_interval gettimeofday);
$|++;

my $host = $ARGV[0] || die "Not target specified\n";
my $port = $ARGV[1] || die "Not port\n";
my $maxport = $ARGV[2] || $port;
if ($port =~ /\D/ || $maxport =~ /\D/) {
	die "Port is not number\n";
} elsif ($maxport<$port) {
	die "Bad arguments\n";
} elsif ($host =~ /^http:/) {
	$host =~ s/^http:\/\///;
	$host =~ s/\/$// if $host =~ /\/$/;
}
	
my @ports = ($port..$maxport);
my $ping = Net::Ping->new('icmp');
my @time;

foreach (0..6) {
	my $time = [gettimeofday()];
	if ($ping->ping($host, 3)) {
		my $respond = tv_interval($time, [gettimeofday()]);
		print "                                        \r";
		print "Response time: $respond s\r";
		push (@time, $respond);
	} else {
	print "Server isn't responding\r";
	}
	sleep(0.6);
}
my $timeout = (sort { $b <=> $a } @time)[0];
die "Server isn't responding\n" unless $timeout;
print "                                        \r";
print "Response time: $timeout s\r\n";

foreach (@ports) {
	my $p = $_;
	my $s = new IO::Socket::INET(
		Proto     => "tcp",
		PeerPort => $p,
		PeerAddr => $host,
		Timeout => $timeout,
	) and print ">> $p is open\n"
	or print ":: $p is close\n";
close($s) if $s;
}

exit;
