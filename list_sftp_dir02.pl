#!/usr/bin/perl -w

use File::Find::Rule;
use XML::LibXML;
use DateTime::Format::Strptime;
use Digest::MD5 qw(md5_hex);
use File::Copy;

$Devel::Trace::TRACE = 1;

use warnings;
use strict;

my $localTZ = DateTime->now(time_zone => 'local');
my $timeStamp = DateTime::Format::Strptime->new( pattern => '%Y%m%d - %T' );

my $INC_DIR ='/sftpdata/batch_ln_prod/';
my $OUT_DIR ='/data/hpcc';


#Find XML files on sftp incoming dir
my $rule = File::Find::Rule->file->name("*.xml")->start( $INC_DIR );
  while ( defined ( my $fp_file = $rule->match ) ) {
    print "$fp_file\n";

    my $file = (split( /\//, $fp_file ))[5];
    
    my $file_prod = (split( /\_/, $file ))[0];

    if ($file_prod !~ //){
      open(my $fh, '>>', $logDir) or die "Could not open file $logDir";
      print $fh "\n$localTZ - File $file - Error on field product. Aborting the rest of the parsing.\n";
      close $fh;
      last;
    }

    my $file_cust = (split( /\_/, $file ))[1];

    if ($file_cust !~ //){
      open(my $fh, '>>', $logDir) or die "Could not open file $logDir";
      print $fh "\n$localTZ - File $file - Error on field customer. Aborting the rest of the parsing.\n";
      close $fh;
      last;
    }

    my $file_time = (split( /\_/, $file ))[2];
  
    if ($file_time !~ //){
      open(my $fh, '>>', $logDir) or die "Could not open file $logDir";
      print $fh "\n$localTZ - File $file - Error on field time stamp. Aborting the rest of the parsing.\n";
      close $fh;
      last;
    }else{
      #move file to destination directory
    }

    my $file_md5 =  (split( /\_/, $file ))[3];

    if ($file_md5 !~ //){
      open(my $fh, '>>', $logDir) or die "Could not open file $logDir";
      print $fh "\n$localTZ - File $file - Error on field Aborting the rest of the parsing.\n";
      close $fh;
      last;
    }else{
      #move file to destination directory
    }

    my $sftp_cust = (split( /\//, $file ))[2];

    my $log_file = 'incoming_errors.log';

    my $logDir = $OUT_DIR .  $sftp_cust . $log_file;

    if(! -d $logDir){
      mkdir $logDir or die "Failed to create log directory: $logDir";
    }

    my $file_customer = (split( /\_/, $file ))[1];

    if ($file_prod !~ /[1-9][0-9]{3}\-[0-1][0-9]\-[0-2][0-5]{2}[0-9]{2}\:[0-5][0-9]\:[0-5][0-9]/){
      open(my $fh, '>>', $logDir) or die "Could not open file $logDir";
      print $fh "\n$localTZ - File $file - Error on field Aborting the rest of the parsing.\n";
      close $fh;
    }else{
     #move file to destination directory
    }

    my $file_date = (split( /\_/, $file ))[2];

    my $file_hash = (split( /\_/, $file ))[4]; 
} 
