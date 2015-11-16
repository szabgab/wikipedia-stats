use 5.010;
use strict;
use warnings;
use Data::Dumper qw(Dumper);
use LWP::UserAgent ();
use JSON::MaybeXS qw(decode_json);
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

# URL of the page:   https://en.wikipedia.org/wiki/Perl
# Title of the page: Perl
# Language: en
my $ua = LWP::UserAgent->new(
	agent => 'wikipedia-stats/perl (https://github.com/szabgab/wikipedia-stats)'
);

main(@ARGV);

sub main {
	my ($file, $url) = @_;

	my $time = time;

	die "Usage: $0 FILE URL\n" if not $url;

	my ($lang, $title) = $url =~ m{^https?://(\w+)\.wikipedia\.org/wiki/(.*)$};
	die "Could not find the language in URL '$url'\n" if not $lang;
	die "Could not find the page title in URL '$url'\n" if not $title;

	#my $content = get_page($lang, $title);
	#say "$lang " . length($content) . "\n";
	#return;

	my $q_number = get_q_number($title);
	#say $q_number;
	my %results;
	my $languages = translations($q_number);
	foreach my $lang (sort keys %$languages) {
		say "$lang  $languages->{$lang}";
		if ($lang !~ /^.+wiki$/) {
			say "Skipping $lang";
			next;
		}
        my $code = substr($lang, 0, -4);
        $code =~ s/_/-/g;
		my $content = get_page($code, $languages->{$lang});
		$results{$lang}{chars} = length $content;
	}
	open my $fh, '>>', $file or die "Could not open '$file' for writing\n";
	foreach my $lang (sort keys %results) {
		print $fh "$time;$lang;wiki;$results{$lang}{chars}\n";
	}
	close $fh;
}

sub get_q_number {
	my ($title) = @_;

	my $props_url = 'https://en.wikipedia.org/w/api.php?action=query&prop=pageprops&format=json&titles=' . $title;
	# wikibase_item has the Q value of the page
	# {"batchcomplete":"","query":{"pages":{"23939":{"pageid":23939,"ns":0,"title":"Perl","pageprops":{"page_image":"Perl-camel-small.png","wikibase-badge-Q17437798":"1","wikibase_item":"Q42478"}}}}}
	my $response = $ua->get($props_url);
	if ($response->is_success) {
	    my $data = decode_json $response->decoded_content;
	#die Dumper $data;
		my ($page_id) = keys %{ $data->{query}{pages} };
		#say $page_id;
		return $data->{query}{pages}{$page_id}{pageprops}{wikibase_item};
	} else {
	    die $response->status_line;
	}
}

# list of translations
sub translations {
	my ($q_number) = @_;
	my $languages_url = 'https://www.wikidata.org/w/api.php?action=wbgetentities&format=json&props=sitelinks&ids=' . $q_number;
	# {"entities":{"Q42478":{"type":"item","id":"Q42478","sitelinks":{"zhwiki":{"site":"zhwiki","title":"Perl","badges":[]},"zhwikibooks":{"site":"zhwikibooks","title":"Perl","badges":[]}}}},"success":1}
	my $response = $ua->get($languages_url);
	if ($response->is_success) {
	    #say $response->decoded_content;
	    my $data = decode_json $response->decoded_content;
		#die Dumper $data->{entities}{$q_number}{sitelinks};
		
		my %languages;
		foreach my $lang (sort keys %{ $data->{entities}{$q_number}{sitelinks} } ) {
			#say "$lang  $data->{entities}{$q_number}{sitelinks}{$lang}{title}";
			$languages{$lang} = $data->{entities}{$q_number}{sitelinks}{$lang}{title};
		}
		return \%languages;
	} else {
	    die $response->status_line;
	}
}

sub get_page {
	my ($lang, $title) = @_;
	#my $url = "https://$lang.wikipedia.org/w/api.php?action=query&prop=info&format=json&titles=$title";  # has a length field
	# {"batchcomplete":"","query":{"pages":{"23939":{"pageid":23939,"ns":0,"title":"Perl","contentmodel":"wikitext","pagelanguage":"en","pagelanguagehtmlcode":"en","pagelanguagedir":"ltr","touched":"2015-11-13T21:30:55Z","lastrevid":689059994,"length":77426}}}}
	my $url = "https://$lang.wikipedia.org/w/api.php?action=query&prop=revisions&rvprop=content&format=json&titles=$title";
	my $response = $ua->get($url);

	if ($response->is_success) {
	    #say $response->decoded_content;
			#"query":{"pages":{"23939"
	    my $data = decode_json $response->decoded_content;
		my ($page_id) = keys %{ $data->{query}{pages} };
		#say $page_id;
		#print map {"$_\n" } keys %{ $data->{query}{pages}{$page_id} };
		if ($title ne $data->{query}{pages}{$page_id}{title}) {
			warn "Fetching from $lang we got the title: '$data->{query}{pages}{$page_id}{title}' and expected '$title'\n";
		}
		if (@{ $data->{query}{pages}{$page_id}{revisions} } != 1) {
			warn "Fetching from $lang we got " . scalar(@{ $data->{query}{pages}{$page_id}{revisions} }) . " entries instead of 1\n";
		}
		#say '---';
		#print map {"$_\n" } keys %{ $data->{query}{pages}{$page_id}{revisions}[0] };   # contentformat, contentmodel, *
		my $content = $data->{query}{pages}{$page_id}{revisions}[0]{'*'};   # contentformat, contentmodel, *
		return $content;
	} else {
	    die $response->status_line;
	}
}

