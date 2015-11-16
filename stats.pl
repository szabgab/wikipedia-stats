use strict;
use warnings;
use LWP::UserAgent;

# URL of the page:   https://en.wikipedia.org/wiki/Perl
# Title of the page: Perl
# Language: en

my $url = shift or die "Usage: $0 URL\n";

my ($lang, $title) = $url =~ m{^https?://(\w+)\.wikipedia\.org/wiki/(.*)$};
die "Could not find the language in URL '$url'\n" if not $lang;
die "Could not find the page title in URL '$url'\n" if not $title;

my $ua = LWP::UserAgent->new(
	agent => 'wikipedia-stats/perl (https://github.com/szabgab/wikipedia-stats)'
);

# https://www.mediawiki.org/wiki/Wikibase/API
# https://www.mediawiki.org/wiki/API:Properties
#my $url = "https://en.wikipedia.org/w/api.php?action=query&titles=$page&prop=revisions&rvprop=content&format=json";
#my $url = "https://en.wikipedia.org/w/api.php?action=query&titles=$page&prop=info&format=json";  # has a length field
#my $url = "https://en.wikipedia.org/w/api.php?action=query&titles=$page&prop=iwlinks&format=json";  # does not seem to be useful

#my $url = "https://en.wikipedia.org/w/api.php?action=query&titles=$page&prop=pageprops&format=json";  # wikibase_item has the Q value of the page
#my $url = "https://en.wikipedia.org/w/api.php?action=query&titles=$page&prop=pageprops&rvprop=content&format=json";  # wikibase_item has the Q value of the page
#$url .= '&lang=hu';

# list of translations
# $url = 'https://www.wikidata.org/w/api.php?action=wbgetentities&format=json&props=sitelinks&ids=Q156537';

#print get $url;

