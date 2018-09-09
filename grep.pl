#!/usr/bin/perl

use XML::Simple;

$Devel::Trace::TRACE = 1;

use warnings;
use strict;


sub checkFile {

    my $xmlFile = $ARGV[0];

    print "$xmlFile";
    
    if (not defined $xmlFile){

       die "\nFirst argument represents the name of the file to be parsed\n";
    }

    return;
}

q# Fields that need to be validated against
 <identificacao>
  <registro>99999</registro>
  <cnpj>12345678000100</cnpj>
  <ano>2016</ano>
  <trimestre>1</trimestre>
 </identificacao>
#;    

sub validateFields {


       my $xml = XML::Simple->new;
    
       #my ($filename, $directories, $suffix) = fileparse($fileName);

       my $file = $xml->XMLin($fileName) or die "Failed for $fileName: $!+\n";
      
       if ($file->{registro} ne 'TIFF') {
           output($filename, 'Identity Format Error');
           next;
       }
   
       if ($file->{toolOutput}{version} ne '6.0'){
           output($filename, 'Version Error');
           next;
       }

}    

&validateFields;




