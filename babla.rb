require 'net/http'
# tested on ruby -v = 2.4.1 
# for older versions should require also net/https (afaik)

class BablaTranslator
    attr_reader :last_request_word_not_found
    attr_writer :verbosity_on

    def initialize        
        @BABLA_URL_EN = "https://pl.bab.la/slownik/angielski-polski/"
        @BABLA_URL_PL = "https://pl.bab.la/slownik/polski-angielski/"
        @verbosity_on = false
        @last_request_word_not_found = false
    end

    def perform_get_request(word)
        @last_request_word_not_found = false        
        res = Net::HTTP.get_response(URI(@BABLA_URL_EN + URI.escape(word)))
        if res.is_a? Net::HTTPMovedPermanently
            res = Net::HTTP.get_response(URI(@BABLA_URL_PL + URI.escape(word)))            
        end
        res.body
    end
    
    def naive_grep(needle, haystack)
        output_lines = []
        haystack.each_line do |line|
            output_lines.push(line) if line.include? needle
        end
        output_lines
    end
    
    def extract_interesting_html_part(page_html)
        output_html = ''
        trimming_stopped = false
        page_html.each_line do |line|
            break if line.include? "scroll-link" # we are too far into html, we already got stuff needed.
            
            if line.include? "poinformowany o braku"
                @last_request_word_not_found = true
            end
    
            if line.include? "quick-results"
                trimming_stopped = true
            end
            
            if trimming_stopped
                output_html += line
            end
        end
        output_html
    end
    
    def extract_translations(lines_of_html)
        lines_of_html.collect do |line|
            md = /.*>(.+)<\/a>/.match(line)
            md[1]
        end
    end
    
    def get_translations(word)
        puts "Performing request to bab.la..." if @verbosity_on    
        page = perform_get_request(word)
        puts "Processing response..." if @verbosity_on    
        html = extract_interesting_html_part(page)
        lines = naive_grep("&quot;", html)
        translations = extract_translations(lines)
        puts "Done!" if @verbosity_on
        translations
    end
end

if ARGV.empty?
    puts "Please provide a word to translate."
    exit
end


babla = BablaTranslator.new

word = ''
while (!ARGV.empty?) do
    arg = ARGV.shift
    if arg == '--verbose'
        babla.verbosity_on = true
        next
    end
    word = arg
end 

translations = babla.get_translations(word)

if babla.last_request_word_not_found
    puts "Sorry, this word does not exist in bab.la dictionary"
else
    puts "#{word} = " + translations.join(", ")
end
