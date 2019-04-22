#!/usr/bin/perl
#
# Daniel Tiberio - daniel.tiberio@lexisnexisrisk.com
# 
#
use File::Find::Rule;
use DateTime::Format::Strptime;
use File::Copy;
use Email::Sender::Simple qw(sendmail);
use Email::MIME;
use XML::LibXML;
use Digest::MD5::File qw(file_md5 file_md5_hex file_md5_base64);
$Digest::MD5::File::BINMODE = 0;
#
#Use it for debugging purposes
#$Devel::Trace::TRACE = 1;
#
use warnings;
use strict;
use utf8;

my $localTZ         = DateTime->now(time_zone => 'local');
my $timeStamp       = DateTime::Format::Strptime->new( pattern => '%Y%m%d - %T' );

our $INC_DIR        = '/sftpdata/batch_ln_prod/';
our $OUT_DIR        = '/data/hpcc/';
my $LOG_FILE        = 'incoming_xml.log';
my $EMAIL_CONTACT   = '/dataApp/DataOps/EMAIL_CONTACT.info';
my $CUSTOMER_CONFIG = '/dataApp/DataOps/customer_config.conf';

my $i;
my $sftp_inc; 
my $sftp_inc_uc;
my $sourceID; 
my $file_prod;
my $file_cust;
my $sftp_cust;
my $sftp_cust_uc;
my $dir_rej;
my $dir_dest;
my $logDir;
my $sourceid_ans;
my $contributor;
my $file_md5;
my $file;
my @CUST_FILES;
#
#require "xmlHeaderParser.pl";
#
# Example of file name: 
# BHCL_IM502860001_20121002172010_4d738e9ce4cc9cea262c319cdd016a88.xml.gz
# That is:
# <Application ID>_<Source ID>_<timestamp>_<MD5checksum>_
# Source of information: https://confluence.rsi.lexisnexis.com/display/LIBTG/Brazil+Contribution+Data+Workflow

sub validateHeader { 
 
       my @array_for_headers = @_;  

       foreach my $k ( @array_for_headers ) {

	   print "O valor de k dentro do validateHeader eh: $k.\n";
  
       }

       OUTER: foreach my $j ( @array_for_headers ){

       #my $logDir = '/home/hpccdemo/log/';

       if(! -d $logDir){
         mkdir $logDir or die "Failed to create log directory: $logDir";
       }

       my $headerParserLogFile = 'xmlHeaderParserError.log';

       print "Antes de load xml. $@ \n";       

       #my $xmlFile = $_[0];

       my $xmlFile = $j;
       
       #Catch exception from malformed XML
       my $file = eval {
        XML::LibXML->load_xml(location => $xmlFile);
       };
       if($@) {

	 my $error_msg = $@;
         #Log failure and exit
         
         print "Error parsing $xmlFile:\n $error_msg";
       
         my $dest_email;       

	 email('hpccdemo@localhost', $dest_email, $error_msg);
 
         exit 0;
       }
     
       #TransmissionDateTime
       if ($file->findvalue('//DataHoraTransmissao') !~ /^(19|[2-9][0-9])\d{2}\-(1[0-2]|0?[1-9])\-(3[01]|[12][0-9]|0?[1-9])T(2[0-3]|[01]?[0-9]):([0-5]?[0-9]):([0-5]?[0-9])$/){

         open(my $fh, '>>', $logDir.$headerParserLogFile) or die "Could not open file $headerParserLogFile";       

         my $tdt_err = "\n$localTZ - File $xmlFile - Error on tag DataHoraTransmissao. Aborting the rest of the parsing.";
     
         print $fh $tdt_err;

         close $fh;

         my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

         print "O valor de dir_rej eh: $dir_rej.\n";

         move("$xmlFile","$dir_rej") or die "Could not move file\n.";
              
         foreach my $file ($EMAIL_CONTACT) {
          open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $tdt_err);
            }
          }
        }
	 next OUTER;
       }
   
       #ApplicationID

       print "Valor de file_prod eh: $file_prod.\n";

       if ($file->findvalue('//CodigoAplicacao') ne $file_prod){
         open(my $fh, '>>', $logDir.$headerParserLogFile) or die "Could not open file $headerParserLogFile";
         
         my $codapp_err = "\n$localTZ - File $xmlFile - Error on tag CodigoAplicacao. Aborting the rest of the parsing.";     

         print $fh $codapp_err;

         close $fh;

         my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

         print "O valor de dir_rej eh: $dir_rej.\n";

         move("$xmlFile","$dir_rej") or die "Could not move file\n.";
              
         foreach my $file ($EMAIL_CONTACT) {
          open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $codapp_err);
            }
          }
        }
	 next OUTER;
       }
       
       #SourceID   
       if ($file->findvalue('//CodigoFonteTransmissao') ne $file_cust){
         open(my $fh, '>>', $logDir.$headerParserLogFile) or die "Could not open file $headerParserLogFile";

         my $si_err = "\n$localTZ - File $xmlFile - Error on tag CodigoFonteTransmissao. Aborting the rest of the parsing.";     

         print $fh $si_err;

         close $fh;

         my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

         move("$xmlFile","$dir_rej") or die "Could not move file\n.";
              
         foreach my $file ($EMAIL_CONTACT) {
          open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $si_err);
            }
          }
        }
        next OUTER;    
       }
       
       #LineOfBusiness
       if ($file->findvalue('//LinhaDeNegocio') !~ /[0-9]{2}/) {
         
         open(my $fh, '>>', $logDir.$headerParserLogFile) or die "Could not open file $headerParserLogFile";  
         
         my $lob_err =  "\n$localTZ - File $xmlFile - Error on tag LinhaDeNegocio. Aborting the rest of the parsing.";
         
         print $fh $lob_err;

         close $fh;

         my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

         move("$xmlFile","$dir_rej") or die "Could not move file\n.";
              
         foreach my $file ($EMAIL_CONTACT) {
          open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $lob_err);
            }
          }
        }
        next OUTER; 
      }
       # Contributor
  
       $sftp_cust_uc = uc $sftp_cust;

       print "O valor de sourceid eh: $sourceID.\n";

       #IM502870001(my $newstring = $oldstring)

       $sourceid_ans = $sourceID =~ s/([0-9]{4}$)|(^[A-Z]{2})//gr;

       #$sourceid_ans = $sourceID =~ s/[^0-9]//gr;

       #my $newstring = $oldstring =~ s/foo/bar/g;

       print "o valor de sourceid_ans: $sourceid_ans.\n";

       print "O valor de sftp_cust_uc eh: $sftp_cust_uc. \n"; 

       $contributor = $sourceid_ans.$sftp_cust_uc;

       print "O valor de contributor eh: $contributor\n";

       if ($file->findvalue('//Contribuinte') ne $contributor){
      
          open(my $fh, '>>', $logDir.$headerParserLogFile) or die "Could not open file $headerParserLogFile"; 
          
          my $contrib_err =  "\n$localTZ - File $xmlFile - Error on tag Contribuinte. Aborting the rest of the parsing.";
          
          print $fh $contrib_err;

          close $fh;

          $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

          print "O valor de dir rej em Contributor eh: $dir_rej.\n";

          print "O valor de xmlFile em Contributor eh: $xmlFile.\n";

          move("$xmlFile","$dir_rej") or die "Could not move file\n.";
              
          foreach my $file ($EMAIL_CONTACT) {
            open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $contrib_err);
            }
          }
        }
        next OUTER;      
       }

       #ContributionIdentity
       if ($file->findvalue('//IdentificadorContribuinte') !~ /[a-z][0-9]\.[0-9]/){

         open(my $fh, '>>', $logDir.$headerParserLogFile) or die "Could not open file $headerParserLogFile";  
  
         my $ci_err = "$localTZ - File $xmlFile - Error on tag IdentificadorContribuinte. Aborting the rest of the parsing.";
     
         print $fh $ci_err;

         close $fh;

         my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

         move("$xmlFile","$dir_rej") or die "Could not move file\n.";
              
         foreach my $file ($EMAIL_CONTACT) {
          open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $ci_err);
            }
          }
        }  
       next OUTER;  
       }
   
      my $strp = DateTime::Format::Strptime->new(pattern => '$dateFormat',);

      #ReportingBeginDate
      if ($file->findvalue('//DataInicioPeriodo') !~ /^(19|[2-9][0-9])\d{2}(1[0-2]|0?[1-9])(3[01]|[12][0-9]|0?[1-9])$/) {
         
         open(my $fh, '>>', $logDir.$headerParserLogFile) or die "Could not open file $headerParserLogFile";   
        
         my $rbd_err = "\n$localTZ - File $xmlFile -  Error on tag DataInicioPeriodo. Aborting the rest of the parsing.";
        
         print $fh $rbd_err;

         close $fh;

         my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

         move("$xmlFile","$dir_rej") or die "Could not move file\n.";
              
         foreach my $file ($EMAIL_CONTACT) {
          open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $rbd_err);
            }
          }
        }
	 next OUTER;
       }
   
       #ReportingEndDate
       if ($file->findvalue('//DataFimPeriodo') !~ /^(19|[2-9][0-9])\d{2}(1[0-2]|0?[1-9])(3[01]|[12][0-9]|0?[1-9])$/){

         open(my $fh, '>>', $logDir.$headerParserLogFile) or die "Could not open file $headerParserLogFile";
         
         my $red_err = "\n$localTZ - File $xmlFile - Error on tag DataFimPeriodo. Aborting the rest of the parsing.";
	          
         print $fh $red_err;

         close $fh;

         my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

         move("$xmlFile","$dir_rej") or die "Could not move file\n.";
              
         foreach my $file ($EMAIL_CONTACT) {
          open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $red_err);
            }
          }  
        }
        next OUTER;     
       }

       #TotalFile
       if ($file->findvalue('//TotalDeArquivos') !~ /\d{3}/){

         open(my $fh, '>>', $logDir.$headerParserLogFile) or die "Could not open file $headerParserLogFile";  

         my $tf_err =  "\n$localTZ - File $xmlFile - Error on tag TotalDeArquivos.Aborting the rest of the parsing.";
         
         print $fh $tf_err;

         close $fh;

         my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

         move("$xmlFile","$dir_rej") or die "Could not move file\n.";
              
         foreach my $file ($EMAIL_CONTACT) {
          open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $tf_err);
            }
          }
        }
      next OUTER;  
      }

       #UniqFileSeq
       if ($file->findvalue('//OrdemDeProcessamento') !~ /[0-9]{3}/){

         open(my $fh, '>>', $logDir.$headerParserLogFile) or die "Could not open file $headerParserLogFile";

         my $ufs_err = "\n$localTZ - File $xmlFile - Error on tag OrdemDeProcessamento. Aborting the rest of the parsing.";

         print $fh $ufs_err;

         close $fh;

         my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

         move("$xmlFile","$dir_rej") or die "Could not move file\n."; 
              
         foreach my $file ($EMAIL_CONTACT) {
          open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $ufs_err);
            }
          }
        }
       next OUTER;    
       }

      #FileRecordCount
      if ($file->findvalue('//QuantidadeDeRegistros') !~ '[0-9]{9}'){

        open(my $fh, '>>', $logDir.$headerParserLogFile) or die "Could not open file $headerParserLogFile";

        my $frc_err = "\n$localTZ - File $xmlFile - Error on tag QuantidadeDeRegistros. Aborting the rest of the parsing.";

        print $fh $frc_err;

        close $fh;

         my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

         move("$xmlFile","$dir_rej") or die "Could not move file\n.";
              
         foreach my $file ($EMAIL_CONTACT) {
          open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $frc_err);
            }
          }
        } 
       next OUTER;           
       }

       #my $checksum_orig = (split( /_/, $file ))[3];

       #print "o valor de checksum_orig eh: $checksum_orig.\n";

       #my $checksum = (split( /\./, $checksum_orig ))[0];   

       #print "o valor de checksum eh: $checksum.\n";

       print "o valor de file_md5 antes de md5_hex eh: $file_md5.\n";


       #my $xmlFiletest = '/sftpdata/batch_ln_prod/intermedica_sftp/incoming/BHPR_IM502870001_20121002172010_8e85e64d69699e56f316d112e5e4fca2.xml';

       my $digest = file_md5_hex($xmlFile);

       print "O valor de digest eh: $digest";

       if($digest ne $file_md5){

         open(my $fh, '>>', $logDir.$headerParserLogFile) or die "Could not open file $headerParserLogFile";  

         my $md5_err = "\n$localTZ - File $xmlFile - Error on checksum. Aborting the rest of the parsing.";

         print $fh $md5_err;

         close $fh;

         my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

         move("$xmlFile","$dir_rej") or die "Could not move file\n.";
              
         foreach my $file ($EMAIL_CONTACT) {
          open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $md5_err);
            }
          }
        }  
        next OUTER;       
       }else{
        #Once all fields are validated and ok, move file to destination directory

        #print "$OUT_DIR.$sftp_cust./.incoming";   

        my $dir_dest =  $OUT_DIR . $sftp_cust . "/" . "incoming";   

        move("$xmlFile", "$dir_dest") or die "Could not move file";
       }
}    
}    

#
# Subroutine to send email to customer in case of error found on first level processing
#
sub email{


my $message = Email::MIME->create(
  header_str => [
    From    => $_[0],
    To      => $_[1],
    Subject => 'Problem found during file parsing - Lexis Nexis',
  ],
  body_str   => $_[2],
  attributes => {
    encoding => 'quoted-printable',
    charset  => 'ISO-8859-1',
  }
);
sendmail($message);
}
#
#
# Subroutine to:  
# - find XML files on sftp incoming dir
# - check if no files need to be processed
# - send e-mail
# - write to log in case of errors
#
#

sub validateFile{ 

@CUST_FILES = File::Find::Rule->file()
                             ->name( qr/\.xml/ )
                            ->in( $INC_DIR );

#my @CUST_FILES = find( file => grep => qr/incoming/, in => \$INC_DIR, ); 

#last if (@CUST_FILES =~ /rejected/);

#unless (@CUST_FILES) or die "No files to be processed";


#my $exclude_dir = qw(rejected);
#my $rule = File::Find::Rule->new; 
#$rule->or($rule->new
#               ->directory
#               ->name($exclude_dir)
#               ->prune
#               ->discard,
#          $rule->new);
#my @CUST_FILES = $rule->in($INC_DIR);


#print "Valor de cust files eh: @CUST_FILES.\n";

print("No files to be processed this time.\n") unless(@CUST_FILES);

OUTER: foreach $i ( @CUST_FILES ){

     print "Dentro do for each.\n";

     print "Logo depois do last.\n"; 

     print "o valor de i eh: $i.\n";

      my $fp; 

      print "Entrou comeco do foreach.\n";

      my $STRING_ERROR  = 'Aborting the rest of the parsing. Moving file to rejected directory';

      $file          = (split( /\//, $i ))[5];

      $sftp_inc      = (split( /\//, $i ))[3];

      $sftp_cust     = (split( /\_/, $sftp_inc ))[0];

      $logDir        = $OUT_DIR .  $sftp_cust . "/" . "incoming" . "/";

      $sourceID      = (split( /\_/, $file ))[1];

    
      if(! -d $logDir){
        mkdir $logDir or die "Failed to create log directory: $logDir";
      }    

     $file_prod = (split( /\_/, $file ))[0];

     print "o valor de file_prod eh: $file_prod.\n";

      if($file_prod !~ m/BHCL|BHPR|BHPL/){

        open(my $fh, '>>', $logDir.$LOG_FILE) or die "Could not open file $logDir";

        my $appid_err = "\n$localTZ - File $file - Error on application ID field. Aborting the rest of the parsing. Moving file to rejected directory.";

        print $fh $appid_err;

        close $fh;

        my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

        print "O valor de dir_rej eh: $dir_rej.\n";

        move("$i","$dir_rej") or die "Could not move file\n.";

        @CUST_FILES = grep {!/^$i$/} @CUST_FILES;
              
        foreach my $file ($EMAIL_CONTACT) {
          open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $appid_err);
            }
          }
        }
	next OUTER;
      }else{
         print "Entrou no else, antes do next.\n"; 
        
         $file_cust = (split( /\_/, $file ))[1];

         if ($file_cust !~ /[A-Z]{1}[A-Z]{1}[0-9]{5}[0]{3}[0-9]{1}/){

         open(my $fh, '>>', $logDir.$LOG_FILE) or die "Could not open file $logDir";

         my $filecust_err = "\n$localTZ - File $file - Error on Source ID field. Aborting the rest of the parsing. Moving file to rejected directory.";

         print $fh $filecust_err;

         close $fh;

         my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

        move("$i","$dir_rej") or die "Could not move file\n.";
              
        @CUST_FILES = grep {!/^$i$/} @CUST_FILES;

        foreach my $file ($EMAIL_CONTACT) {
          open my $fh, '<:encoding(UTF-8)', $file or die;
          while (my $line = <$fh>) {
            if ($line =~ /$sourceID/) {
		my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $filecust_err);
            }
          }
        }
        next OUTER;                     
        }else{
           print "Entrou no else do time stamp.\n";
        
           my $time_stamp = (split( /\_/, $file ))[2];
  
           print "Valor de time stamp eh: $time_stamp.\n";

           #my $ts_regex = '^(19|[2-9][0-9])\d{2}(1[0-2]|0?[1-9])(3[01]|[12][0-9]|0?[1-9])(2[0-3]|[01]?[0-9])([0-5]?[0-9])([0-5]?[0-9])$';

           #print "Valor de ts_regex eh: $ts_regex.\n";

           if ($time_stamp !~ m/^(19|[2-9][0-9])\d{2}(1[0-2]|0?[1-9])(3[01]|[12][0-9]|0?[1-9])(2[0-3]|[01]?[0-9])([0-5]?[0-9])([0-5]?[0-9])$/){
     
           open(my $fh, '>>', $logDir.$LOG_FILE) or die "Could not open file $logDir";

            my $timestamp_err = "\n$localTZ - File $file - Error on field time stamp. Aborting the rest of the parsing. Moving file to rejected directory.";

           print $fh $timestamp_err;

           close $fh;

           my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

           move("$i","$dir_rej") or die "Could not move file\n.";

           @CUST_FILES = grep {!/^$i$/} @CUST_FILES;

           foreach my $file ($EMAIL_CONTACT) {
             open my $fh, '<:encoding(UTF-8)', $file or die;
             while (my $line = <$fh>) {
              if ($line =~ /$sourceID/) {
	        my $dest_email = (split( / /, $line ))[1];
                email('hpccdemo@localhost', $dest_email, $timestamp_err);
              }
             }
            }
	   next OUTER;
	   }else{

             $file_md5 = (split( /[\_\.]/, $file ))[3];
                           
             print "O valor de file_md5 eh: $file_md5.\n";
 
             if ($file_md5 !~ /[a-f0-9]{32}/){
        
             open(my $fh, '>>', $logDir.$LOG_FILE) or die "Could not open file $logDir";
        
             my $md5_err = "\n$localTZ - File $file - Error on field MD5. Aborting the rest of the parsing. Moving file to rejected directory.";
   
             print $fh $md5_err;     
   
             close $fh;
       
             my $dir_rej = $INC_DIR . $sftp_inc . "/" . "rejected";

             print "move do md5 header. \n"; 

             move("$i","$dir_rej") or die "Could not move file\n.";

             @CUST_FILES = grep {!/^$i$/} @CUST_FILES;

              foreach my $file ($EMAIL_CONTACT) {
                open my $fh, '<:encoding(UTF-8)', $file or die;
                while (my $line = <$fh>) {
                  if ($line =~ /$sourceID/) {
	          my $dest_email = (split( / /, $line ))[1];
                  email('hpccdemo@localhost', $dest_email, $md5_err);
                  }
                }
              }
              next OUTER;
              }else{
                  #print @CUST_FILES;
		  #print "Chamando a funcao validateHeader.\n";
                 #validateHeader(@CUST_FILES);
              }
	  }
	}
      }
  }
validateHeader(@CUST_FILES);
}
print "chamando a funcao validateFile.\n";
validateFile;
