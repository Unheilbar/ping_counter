#!/usr/bin/perl -w
#
# see http://search.cpan.org/~atrak/NetPacket-0.04/

use strict;
use Data::Dumper;
use Storable;

BEGIN {
    push @INC,"perl";
    push @INC,"build/perl";
    push @INC,"NetPacket-0.04";
};

use nfqueue;

use NetPacket::IP qw(IP_PROTO_ICMP);
use NetPacket::ICMP;
#use Socket qw(AF_INET AF_INET6);
use Socket qw(AF_INET);

my $q;
my %h;
$h{start}=time();
$h{st}=undef;
#my $i=0;
sub cleanup()
{
    print "unbind\n";
    $q->unbind(AF_INET);
    print "close\n";
    $q->close();
}

sub cb()
{
    my ($dummy,$payload) = @_;
    if ($payload) {
	if (my $ip_obj = NetPacket::IP->decode($payload->get_data())) {
	    if ($ip_obj->{proto} == IP_PROTO_ICMP) {
		if (my $icmp_obj = NetPacket::ICMP->decode($ip_obj->{data})) {
#		    print("$ip_obj->{src_ip}\n");
		    if ($icmp_obj->{type}==0) {
			if ($ip_obj->{src_ip} eq $ip_obj->{dest_ip}) {
#			    print Data::Dumper->Dump([\%h], ['*main']);
			    store(\%h,"testping.st");
			    print "save\n";
			    $h{st}=undef;
			} else {
#		    print("$ip_obj->{src_ip}\n");
			    if (!defined($h{st}{$ip_obj->{src_ip}})) {
				$h{st}{$ip_obj->{src_ip}}=1;
#=1
			    } else {
#$h{st}{$ip_obj->{src_ip}}=6;
				$h{st}{$ip_obj->{src_ip}}++;
			    }
			}
		    }
		}
	    }
	}
    }
    $payload->set_verdict($nfqueue::NF_ACCEPT);
}


$q = new nfqueue::queue();



$SIG{INT} = "cleanup";

$SIG{PIPE} = sub { print "Aborting on SIGPIPE\n" };

#print "setting callback\n";
$q->set_callback(\&cb);

my $now = `date "+%Y%m%d%H%M%S" | tr -d "\n"`;
print $now." open\n";
$q->fast_open(0, AF_INET);

$q->set_queue_maxlen(30);

print "trying to run\n";
$q->try_run();

#print "one more\n"; $q->try_run();
