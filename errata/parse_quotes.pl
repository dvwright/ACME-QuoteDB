# TODO: create an 'easy load' method, for getting quotes content into the DB
#       If the quotes are in a text file, each quote delimited by newline 
#       in the form of:  "this is the quote " - this is the author\n
#       an 'easy load' method here will just load them into the db
#
# Description: create a local Db from some quote content
#
# 1. download site: (be nice to servers, while you get the 
#                    data extraction parsing correct ;)
#    i.e. % wget -w 1 -m http://example.com/quotes (whatever)
#         # for example: createtive commons - share alike
#         http://www.amk.ca/quotations/python-quotes/
#         http://www.amk.ca/quotations/python-quotes/page-2
#
#     % wget -w 1 -m  http://www.amk.ca/quotations/python-quotes/
#
# 2. run this script, point it too the necessary directories.
#
# Note: this is a 'throwaway' script, season to taste

#use base 'ACME::QuoteDB::DB::DBI';
use HTML::TokeParser;
use Data::Dumper;

use aliased 'ACME::QuoteDB::DB::Attribution' => 'Attr';
use aliased 'ACME::QuoteDB::DB::Quote'     => 'Quote';

use File::Glob qw(:globally :nocase);
use File::Basename qw/dirname basename/;
use Carp qw/croak/;

my $d =  dirname(__FILE__).'/../t/data/www.amk.ca/quotations/python-quotes/';

#[DB]% sqlite3 quotes.db < ../../../../errata/db_create.sql
#[DB]% cd ../../../../
#[ACME-QuoteDB]% perl -Ilib parse_quotes.pl   

my $WRITE_DB = 1;
my %attribution_id;

#print "processing: $d\n";

#foreach my $f ( <$d*.html> ) {
foreach my $f ( <$d*> ) {
  croak unless -e $f and not -z $f;
  next unless( basename($f) eq 'index');
  print "processing: $f\n";
  parse_file($f); 
}

sub parse_file {
  my ($file) = @_;
  my $p = HTML::TokeParser->new($file) || croak $!;
  _get_quotes($p);
}

sub _get_quotes {
  my ($p) = @_;

  my $record = {};
  while (my $token = $p->get_tag("p")) {
      my $idn = $token->[1]{class} || q{};
      #last if $idn eq 'quotation';
      next unless $idn and ( $idn eq 'quotation' || $idn eq 'source');

      my $data = $p->get_trimmed_text("/p");
      #$data =~ s/Quote Rating:(.*?)\s-.*\z//ms;
      #my $rating = $1 || '';
      my $rating = q{};
      #$rating =~ s/\s//xmsg if $rating;
      $record->{ 
           quote       => q{},
           attribution => q{},
           rating      => q{},
      };
      if ($idn eq 'quotation') {
          $record->{quote} = $data;
      }
      elsif ($idn eq 'source'){
          $record->{attribution} = $data;
      }

      if ($record->{quote} and $record->{attribution}) {
          print "Quote: $record->{quote}\n";
          print "Rating: $record->{rating}\n";
          my $attr_id = q{};
          $attr_id = 
              Quote->insert({
                  #attr_id -> auto increment
                  quote        => $record->{quote},
                  rating       => $rating
                   }) if $WRITE_DB;
          print "Attribution Name: $record->{attribution}\n";
          Attr->insert({
                     attr_id => $attr_id,
                     name    => $record->{attribution}
                     }) if $WRITE_DB;
          $record = {};
      }
  }
}

