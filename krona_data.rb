require 'csv'
require 'net/http'

base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils'
search = 'esearch.fcgi?tool=ruby&email=tobias.meier@studium.uni-hamburg.de&db=taxonomy&term='
fetch = 'efetch.fcgi?tool=ruby&email=tobias.meier@studium.uni-hamburg.de&db=taxonomy&id='


ARGV.each do |vent|
  taxy_dir = "#{vent}/profiles"
  next if !Dir.exists?("#{vent}/profiles/")
  puts vent
  Dir.glob("#{vent}/profiles/*_Taxy/*ID.csv") do |profile|
    next if profile.match(/species/) == nil 
    hash = Hash.new
    File.open(profile).each_line do |line|
      line = line.split(',')
      next if line[0] == 'taxon'
      species = line[0].gsub(' ', '+')
      freq = line[1].to_f
      
      uri = URI("#{base}/#{search}#{species}")
      ncbi_search = Net::HTTP.get(uri) 
      id = ncbi_search[/<Id>(\d+)<\/Id>/, 1]
      
      uri = URI("#{base}/#{fetch}#{id}")
      ncbi_fetch = Net::HTTP.get(uri)
      superkingdom = ncbi_fetch[/<LineageEx>.*<ScientificName>(.*)<\/ScientificName>.*<Rank>superkingdom<\/Rank>/m, 1]
      phylum = ncbi_fetch[/<LineageEx>.*<ScientificName>(.*)<\/ScientificName>.*<Rank>phylum<\/Rank>/m, 1]
      clas = ncbi_fetch[/<LineageEx>.*<ScientificName>(.*)<\/ScientificName>.*<Rank>class<\/Rank>/m, 1]
      order = ncbi_fetch[/<LineageEx>.*<ScientificName>(.*)<\/ScientificName>.*<Rank>order<\/Rank>/m, 1]
      family = ncbi_fetch[/<LineageEx>.*<ScientificName>(.*)<\/ScientificName>.*<Rank>family<\/Rank>/m, 1]
      genus = ncbi_fetch[/<LineageEx>.*<ScientificName>(.*)<\/ScientificName>.*<Rank>genus<\/Rank>/m, 1]
      species = species.gsub('+', ' ')
      sleep 0.5 #sleep for 0.5 seconds to comply with the ncbi usage guidelines (no more than 3 url requests per second)
      
      hash[species] = []
      hash[species].push(freq,superkingdom,phylum,clas,order,family,genus,species)
      
    end
        
    File.open("#{vent}/profiles/krona.txt", 'w') do |file|
      hash.each do |k,v|
	v.each do |val|
	  file.print val == v[-1] ? "#{val}" : "#{val}\t"
	end
	file.puts "\n"
      end
    end
    
  end
end
           