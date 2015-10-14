# API REST for Natural Language Processing services

SplineAPI is a platform that can provide natural language processing services based on a simple REST API using NLP tools already installed on the server. The only restriction it has, is that these tools must be acessible via an interface for Perl programming language or via command line (at least for now).

The objective of the platform is to centralize all the NLP services in a single API and to make users' life easier avoiding the installation, configuration and learning processes. Usually, NLP tools are way too difficult to install and configure and they have a lot of dependencies that can be even more difficult to get or are OS-dependent. Besides that, learning some of those tools can be a slow and/or tough adventure. 


## Installation in UNIX environment

1. Get Perl
2. Configure CPAN
3. sudo apt-get install libxml2-dev
4. sudo cpan Dancer2 Class::Unload Class::Factory::Util Dancer2::Plugin::Emailesque Dancer2::Plugin::Database DBD::SQLite Encode XML::LibXML XML::DT experimental Switch String::Util 


## Start service

1. perl $HOME/daemon.pl
2. Add an entry on crontab to execute $HOME/coin_updater.pl daily
3. perl $HOME/bin/app.pl


## Load some examples

1. sudo apt-get install cpanminus
2. Install Freeling tool
3. Install nat-create
4. sudo apt-get install Lingua::FreeLing3 Lingua::Jspell
5. sh module_installer.sh


## Usage

### Usage for admins

Admins have the responsibility to add or edit the services provided by the platform and to install the tools on the server.

To add a new service on the platform the admin have to:
1. Create an XML file describing the desired service. The XML file has to be created based on the XML Schema ( $HOME/xml_schema.xsd ) validator. The repo has some example on the $HOME folder. [optional]
2. Create a Perl Module:
    1. If you created the XML file, it is as easy as running the module generated ( perl $HOME/generate_module.pl file.xml ) and the module will be generated automatically.
    2. Create an empty Perl Module on $HOME/modules/intermediate with Spline::ToolName as the module name and create other Perl module with Spline::ToolName::ServiceName and fill it with all the required elements needed. The platform already includes some tools as an example (perl $HOME/generate_module.pl file.xml -d).
3. Restart Dancer.

Edit a service is possible by changing the Perl Module directly or using the XML generator to erase the module and generate a new one.

### Usage for users

The usage for clients is as easy as a simple REST API service. Users just have to send a POST request to the desired service with all the necessary arguments. To consult all the services and their restrictions, SplineAPI provides an webpage (root) with that information. That webpage also allows the users to register, test the services directly via a web form, consult their history and daily remaining coins, etc.


## To-do

1. Develop a better way to generate tests on the Perl modules. Maybe change the TAP language to a more efficient one, like JsonPath or JSONiq;
2. Create a graphical user interface that generates the XML file automatically and then the Perl module too. It is only to make the module generation easier;
3. Change the database type (currently SQLite) to a more robust one like PostgreSQL or MySQL; 
4. Improve the error handling system to a more robust one;


## History

The platform was designed and developed as part of a dissertation that explores methods to easy all the problems related to the usage of NLP tools.

## Credits

Nuno Vieira
Alberto Simões
Nuno Carvalho
