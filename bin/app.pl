#!/usr/bin/env perl
use Dancer2;
use FindBin;
use lib "$FindBin::Bin/../lib";
use ws;

#system("sh module_installer.sh");

set port         => 8080;
dance;
