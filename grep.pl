#!/usr/bin/perl

use XML::LibXML;

$Devel::Trace::TRACE = 1;

use warnings;
use strict;

my $xmlFile = $ARGV[0];

sub checkFile {

    #my $xmlFile = $ARGV[0];

    print "$xmlFile";
    
    if (not defined $xmlFile){

       die "\nFirst argument represents the name of the file to be parsed\n";
    }

    return;
}

# Fields that need to be validated against
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

       if ($file->findvalue('//DataHoraTransmissao') ne '2018-06-12001:00:00') {
          
           print "\nError on tag DataHoraTransmissao.\n";
           
       }
   
       if ($file->findvalue('//CodigoAplicacao') ne '6.0'){
           print "\nError on tag CodigoAplicacao.\n";
        
       }

       if ($file->findvalue('//CodigoFonteTransmissao') ne '6.0'){
           print "\nError on tag CodigoFonteTransmissao.\n";
        
       }
       
       if ($file->findvalue('//LinhaDeNegocio') ne 'TIFF') {
           print "\nError on tag LinhaDeNegocio.\n";
        
       }
   
       if ($file->findvalue('//Contribuinte') ne '6.0'){
           print "\nError on tag Contribuinte.\n";
           
       }

       if ($file->findvalue('//IdentificadorContribuinte') ne '6.0'){
           print "\nError on tag IdentificadorContribuinte.\n";
           
       }
   
      if ($file->findvalue('//DataInicioPeriodo') ne 'TIFF') {
           print "\nError on tag DataInicioPeriodo.\n";
           
       }
   
       if ($file->findvalue('//DataFimPeriodo') ne '6.0'){
           print "\nError on tag DataFimPeriodo.\n";
         
       }

       if ($file->findvalue('//TotalDeArquivos') ne '6.0'){
           print "\nError on tag TotalDeArquivos.\n";
           
       }

      if ($file->findvalue('//OrdemDeProcessamento') ne '6.0'){
           print "\nError on tag OrdemDeProcessamento.\n";
           
       }

      if ($file->findvalue('//QuantidadeDeRegistros') ne '6.0'){
           print "\nError on tag QuantidadeDeRegistros.\n";
           
       }

}    

&validateFields;




