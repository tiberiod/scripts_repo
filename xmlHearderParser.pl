#!/usr/bin/perl

use XML::LibXML;
use DateTime::Format::Strptime;

$Devel::Trace::TRACE = 1;

use warnings;
use strict;

my $xmlFile = $ARGV[0];

sub checkFile {

    
    print "$xmlFile";
    
    if (not defined $xmlFile){

       die "\nFirst argument represents the name of the file to be parsed\n";
    }

    return;
}

# Fields that need to be validated against
#
# DataHoraTransmissao
# CodigoAplicacao
# CodigoFonteTransmissao
# LinhaDeNegocio
# Contribuinte
# IdentificadorContribuinte
# DataInicioPeriodo
# DataFimPeriodo
# TTotalDeArquivos
# OrdemDeProcessamento
# QuantidadeDeRegistros    

sub validateFields { 

       my $file = XML::LibXML->load_xml(location => $xmlFile);

       if ($file->findvalue('//DataHoraTransmissao') !~ /[1-9][0-9]{3}\-[0-1][0-9]\-[0-2][0-5]{2}[0-9]{2}\:[0-5][0-9]\:[0-5][0-9]/){
           print "\nError on tag DataHoraTransmissao.\n";
       }
   
       if ($file->findvalue('//CodigoAplicacao') !~ /[A-Z]{4}/){
           print "\nError on tag CodigoAplicacao.\n";
       }

       if ($file->findvalue('//CodigoFonteTransmissao') !~ /[A-Z]{2}\d{9}/){
           print "\nError on tag CodigoFonteTransmissao.\n";     
       }
       
       if ($file->findvalue('//LinhaDeNegocio') !~ /[0-9]{2}/) {
           print "\nError on tag LinhaDeNegocio.\n";
        
       }
   
       if ($file->findvalue('//Contribuinte') !~ /^[0-9]{6}/){
           print "\nError on tag Contribuinte.\n";
           
       }

       if ($file->findvalue('//IdentificadorContribuinte') !~ /[a-z][0-9]\.[0-9]/){
           print "\nError on tag IdentificadorContribuinte.\n";
           
       }
   
      my $strp = DateTime::Format::Strptime->new(pattern => '$dateFormat',);

      #eval {
      #   $date = DateTime::Format::DateManip->parse_datetime($file->findvalue('//DataInicioPeriodo'));
      #};
      #if ($@) { print "ERROR: date not valid" };

      if ($file->findvalue('//DataInicioPeriodo') !~ /[1-9][0-9]{3}[0-1][0-9][0-2][0-9]/) {
           print "\nError on tag DataInicioPeriodo.\n";
           
       }
   
       if ($file->findvalue('//DataFimPeriodo') !~ /[1-9][0-9][0-9][0-9][0-1][0-9][0-2][0-9]/){
           print "\nError on tag DataFimPeriodo.\n";
         
       }

       if ($file->findvalue('//TotalDeArquivos') !~ /\d{3}/){
           print "\nError on tag TotalDeArquivos.\n";
           
       }

      if ($file->findvalue('//OrdemDeProcessamento') !~ /[0-9]{3}/){
           print "\nError on tag OrdemDeProcessamento.\n";
           
       }

      if ($file->findvalue('//QuantidadeDeRegistros') !~ '[0-9]{9}'){
           print "\nError on tag QuantidadeDeRegistros.\n";
           
       }

}    

&validateFields;




