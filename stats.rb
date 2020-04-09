require 'open-uri'

# ruby stats.rb ruby.csv 'https://en.wikipedia.org/wiki/Ruby_%28programming_language%29'


def main(args)
    file, url = args
    if not url
        puts "Missing URL"
        return
    end

	lang, title = url =~ m{^https?://(\w+)\.wikipedia\.org/wiki/(.*)$};

end


main(ARGV)

#url = 'http://code-maven.com/'
#fh = open(url, 
#   "User-Agent" => "Code-Maven-Example (see: http://code-maven.com/download-a-page-using-ruby )"
#)
#html = fh.read
#puts html


