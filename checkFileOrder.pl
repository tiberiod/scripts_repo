#!/usr/bin/perl

use XML::LibXML;
use DateTime::Format::Strptime;
use Digest::MD5 qw(md5_hex);
#use Number::Range;
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

#my @numbers = do {
#    open my $fh, '<', 'document.txt' or die $!;
#    local $/;
#    <$fh> =~ /\d+/g;
#};
#my $range = Number::Range->new($TotalDeArquivos);
#my @sections = $range->rangeList;
#my $all = Number::Range->new("$sections[0][0]..$sections[-1][-1]");
#$all->delrange($range->range);
#say scalar $all->range;

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
print $fh "$product|$beginDate|$ARGV[0]|$filesTotal|$procOrder|$amountReg|$product$filesTotalSTZ$procOrderSTZ";
close $fh;

my @lines;
open (FILEHERE, $logDir . $arrFiles);
while(<FILEHERE>) {
    push @lines, [split /\|/];
}

my @sorted = sort { $b->[6] cmp $a->[6] } @lines;

dump(@sorted);

#print join(,@sorted),"\n";

#foreach (@sorted) {
#    print $_; 
#}


#my @arr = $logDir . $arrFiles;

#my @sorted = sort {
#    my ($aa, $bb) = map { (split /\|/)[6] } $a, $b;
#    $aa <=> $bb;
#}@arr;

#say for @sorted;



#CLMEIM502860001_2018061417373000_572e3e554596e5f6b8c5ca673867e0e8_tclm.txt



