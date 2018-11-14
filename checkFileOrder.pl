#!/usr/bin/perl

use XML::LibXML;
use DateTime::Format::Strptime;
use Digest::MD5 qw(md5_hex);
use Data::Dump qw(dump);

$Devel::Trace::TRACE = 1;

use warnings;
use strict;

# Fields that need to be validated against

# TTotalDeArquivos
# OrdemDeProcessamento
# QuantidadeDeRegistros  

# Example of values

#<TotalDeArquivos>001</TotalDeArquivos>  
#<OrdemDeProcessamento>001</OrdemDeProcessamento>
#<QuantidadeDeRegistros>000000001</QuantidadeDeRegistros>

#prv = Provider
#plc = Policy
#clm = Claims

# Queue file format fields

# [prv|plc|clm] | [start date] | [total amount of files] | [processing order] | [file name]

## Variable below need to be changed to match real case
my $incomingDir = '/home/hpccdemo/';
##
my $logFile = 'checkFileOrder.out';
my $logDir = $incomingDir . 'log/';
my $arrFiles = 'arrFiles.txt';
my $files2BProc = 'files2BProc.txt';

my $productOrig = (split( /_/, $ARGV[0] ))[3];
my $product = (split( /\./, $productOrig ))[0];


my $xmlFile = $ARGV[0];

my $file = XML::LibXML->load_xml(location => $xmlFile);


my $beginDate = $file->findvalue('//DataInicioPeriodo'); 

my $filesTotal = $file->findvalue('//TotalDeArquivos'); 

my $procOrder = $file->findvalue('//OrdemDeProcessamento');

my $amountReg = $file->findvalue('//QuantidadeDeRegistros');

# Remove leading 0s 
my $filesTotalSTZ = sprintf "%d" , "$filesTotal";
my $procOrderSTZ  = sprintf "%d" , "$procOrder"; 

open(my $fh, '>>', $logDir . $arrFiles) or die "Could not open queue file";
print $fh "\n$product|$beginDate|$ARGV[0]|$filesTotal|$procOrder|$amountReg|$product$filesTotalSTZ$procOrderSTZ\n";
close $fh;

my @lines;
open (FILEHERE, $logDir . $arrFiles);
while(<FILEHERE>) {
  push @lines, [split /\|/];
}

my @sorted = sort { $b->[6] cmp $a->[6] } @lines;

print dump(\@sorted);
