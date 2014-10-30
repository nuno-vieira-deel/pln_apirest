#!/usr/bin/env perl
use Dancer2;
use FindBin;
use lib "$FindBin::Bin/../lib";
use ws;

set port         => 8080;
dance;
