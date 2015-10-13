# API REST for Natural Language Processing services

Descrição

## Installation in UNIX environment

1. Perl
2. Configure CPAN
3. sudo cpan Dancer2 Class::Unload Class::Factory::Util Dancer2::Plugin::Emailesque Dancer2::Plugin::Database DBD::SQLite Encode


## Start service

1. perl $HOME/daemon.pl
2. Add an entry on crontab to execute $HOME/coin_updater.pl daily
3. perl $HOME/bin/app.pl


## Load some examples

1. sudo apt-get install cpanminus
2. Install Freeling tool
3. Install nat-create
4. sudo apt-get install Lingua::FreeLing3 Lingua::Jspell
2. sh module_installer.sh