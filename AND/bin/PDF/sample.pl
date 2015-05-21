#!/usr/bin/perl -w

BEGIN { unshift @INC, "lib", "../lib" }
use strict;

    use PDF::Create;

    my $pdf = new PDF::Create('filename' => 'mypdf.pdf',
			      'Version'  => 1.2,
			      'PageMode' => 'UseOutlines',
			      'Author'   => 'Fabien Tassin',
			      'Title'    => 'My title',
			 );
    my $root = $pdf->new_page('MediaBox'  => [ 0, 0, 612, 792 ]);

    # Add a page which inherits its attributes from $root
    my $page = $root->new_page;

    # Prepare 2 fonts
    my $f1 = $pdf->font('Subtype'  => 'Type1',
 	   	        'Encoding' => 'WinAnsiEncoding',
 		        'BaseFont' => 'Helvetica');
    my $f2 = $pdf->font('Subtype'  => 'Type1',
 		        'Encoding' => 'WinAnsiEncoding',
 		        'BaseFont' => 'Helvetica-Bold');

    # Prepare a Table of Content
    my $toc = $pdf->new_outline('Title' => 'Document',
                                'Destination' => $page);
    $toc->new_outline('Title' => 'Section 1');
    my $s2 = $toc->new_outline('Title' => 'Section 2', 'Status' => 'closed');
    $s2->new_outline('Title' => 'Subsection 1');

    $page->stringc($f2, 40, 306, 426, "PDF::Create");
    $page->stringc($f1, 20, 306, 396, "version $PDF::Create::VERSION");

    # Add another page
    my $page2 = $root->new_page;
    $page2->line(0, 0, 612, 792);
    $page2->line(0, 792, 612, 0);

    $toc->new_outline('Title' => 'Section 3');
    $pdf->new_outline('Title' => 'Summary');

    # Add something to the first page
    $page->stringc($f1, 20, 306, 300, 'by Fabien Tassin <fta@oleane.net>');

    # Add the missing PDF objects and a the footer then close the file
    $pdf->close;
