#!/usr/bin/env perl

use App::Daemon qw( daemonize );
daemonize();

use Capture::Tiny ':all';
use JSON;
use Module::Load;

my @queue = ();

while(1){

	if(scalar @queue == 0){
		my @news = `ls data/queue`;
		@news = sort @news;
		push(@queue, @news);
	}

	if(scalar @queue > 0){
		my $file = $queue[0];
		chomp($file);

		local $/=undef;
		open(my $fh, "<", "data/queue/".$file);
			my $code = <$fh>;
			my ($stdout, $stderr, @result) = capture { eval $code; };
			open (my $lh, ">", "data/logs/".$file.".log");
				print $lh $stdout;
				print $lh $stderr if($stderr);
			close($lh);
		close($fh);

		system("rm data/queue/".$file);
		shift @queue;
	}

}