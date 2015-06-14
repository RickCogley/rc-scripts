#!/usr/bin/perl -w

# Version v1.0.1
# Date: 2007-02-27
# Copyright (c) 2007 by Stephan Jaeger

# use strict;

use lib "/usr/bin/lib/";

use File::Basename;
use File::Copy;
use File::Find;
use File::Glob;
use File::Spec;

use Getopt::Std;

use Image::ExifTool;

getopts('s:t:');

my @dates = ();
my @projectImages = ();
my @files = ();

###
### Begin Variables, can be changed
###

my $sourceDir = "~/Pictures/01_AutomatorIngest/"; # Can be ignored, since it is defined in the "Run AppleScript" action
my $targetDirRoot = "~/Pictures/Ingest/";
my $newFileNamePrefix = "dcni01_";
my $newFileNameSuffix = "_v000";

###
### End Variables
###

if ($opt_s) {
   $sourceDir = $opt_s;
}

if ($opt_t) {
   $targetDirRoot = $opt_t;
}

find sub {
   my $file = $File::Find::name;
   my $type = Image::ExifTool::GetFileType($file);
   if ($type) {
      push(@files, $file);
   }
}, $sourceDir;


my @imageDates = &s_getImageDates(@files);
my @uniqueDirectories = &s_getUniqueElementsFromList(@imageDates);
my @newDirectories = &s_createDirectories($targetDirRoot, @uniqueDirectories);
&s_copyFilesToNewLocation(\@files, \@newDirectories);
&s_listFilesForApertureImport(@projectImages);

sub s_getImageDates {
   my @files = @_;
   my $file = "";

   foreach $file (@files) {
      my $exifTool = new Image::ExifTool;
      $exifTool->Options(DateFormat => '%Y%m%d');

      my $info = $exifTool->ImageInfo($file, CreateDate);
      my $getDate = $exifTool->GetValue('CreateDate');
      push(@dates, $getDate);
   }
   return @dates;
}

sub s_createDirectories {
   ($targetDirRoot, @uniq) = @_;
   my $item;

   foreach $item (@uniq) {
      $newDirectory = File::Spec->catfile($targetDirRoot, $item);
      mkdir $newDirectory;
      push(@newDirectories, $newDirectory);
   }
   return @newDirectories;
}

sub s_copyFilesToNewLocation {
   my ($sourceFiles, $targetDirectories) = @_;

   for my $targetDirectory (0..$#$targetDirectories) {
      my $targetDir = $targetDirectories->[$targetDirectory];

      my @directoryParts = File::Spec->splitdir($targetDir);
      my $dateFull = $directoryParts[-1];
      my $fileCounter = 0;

      for my $sourceFile (0..$#$sourceFiles) {
         my $sourceFileValue = $sourceFiles->[$sourceFile];
         my $exifTool = new Image::ExifTool;
         $exifTool->Options(DateFormat => '%Y%m%d');

         my $info = $exifTool->ImageInfo($sourceFileValue, CreateDate);
         my $getDate = $exifTool->GetValue('CreateDate');

         if ($getDate == $dateFull) {
            $fileCounter = $fileCounter + 1;
            $fileCounterString = sprintf "%003d", $fileCounter;
            my ($sourceFileNameDir, $sourceFileName, $sourceFileExtension) = fileparse($sourceFileValue, '\..*');

            $newFileName = lc($newFileNamePrefix . $getDate . $fileCounterString . $newFileNameSuffix . $sourceFileExtension);
            $newFileNameValue = File::Spec->catdir($targetDir, $newFileName);

            copy($sourceFileValue, $newFileNameValue);
            push(@projectImages, $newFileNameValue);
         }
      }
   }
}

sub s_listFilesForApertureImport {
   my @apertureFiles = @_;

   foreach $apertureFile (@apertureFiles) {
      print "$apertureFile\n";
   }
}

sub s_getUniqueElementsFromList {
   my @list = @_;
   %seen = ();
   @uniq = ();

   foreach $item (@list) {
      unless ($seen{$item}) {
         # if we get here, we have not seen it before
         $seen{$item} = 1;
         push(@uniq, $item);
      }
   }
   return @uniq;
}

sub s_printListItems {
   my @list = @_;
   my $uniqitem = ();

   foreach $uniqitem (@list) {
      print "$uniqitem\n";
   }
}