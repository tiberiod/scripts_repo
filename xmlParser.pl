#!/usr/bin/perl

use XML::Simple;
use Data::Dumper;

use warnings;

$xml = new XML::Simple;

$data=$xml->XMLin("exemplo_diops_2016_administradora.xml");

my @foo = grep(/2016/, Dumper($data)); 

print(@foo);

#Dumper($data);


