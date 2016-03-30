require 'csv'
require 'net/http'

base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils'
search = 'esearch.fcgi?tool=ruby&email=tobias.meier@studium.uni-hamburg.de&db=taxonomy&term='
fetch = 'efetch.fcgi?tool=ruby&email=tobias.meier@studium.uni-hamburg.de&db=taxonomy&id='


ARGV.each do |vent|
  taxy_dir = "#{vent}/profiles"
  next if !Dir.exists?("#{vent}/profiles/")
  Dir.glob("#{vent}/profiles/*_Taxy/*ID.csv") do |profile|
    next if profile.match(/superkingdom/) != nil 
    puts "processing #{vent} - #{profile}"
    euk_hash = Hash.new
    bact_hash = Hash.new
    arch_hash = Hash.new
    vir_hash = Hash.new
    undef_hash = Hash.new
    File.open(profile).each_line do |line|
      line = line.split(',')
      next if line[0] == 'taxon'
      taxon = line[0].gsub(' ', '+')
      freq = line[1].to_f
      
      uri = URI("#{base}/#{search}#{taxon}")
      ncbi_search = Net::HTTP.get(uri) 
      id = ncbi_search[/<Id>(\d+)<\/Id>/, 1]
      
      uri = URI("#{base}/#{fetch}#{id}")
      ncbi_fetch = Net::HTTP.get(uri)
      superkingdom = ncbi_fetch[/<LineageEx>.*<ScientificName>(.*)<\/ScientificName>.*<Rank>superkingdom<\/Rank>/m, 1]
      taxon = taxon.gsub('+', ' ')
      sleep 0.5 #sleep for 0.5 seconds to comply with the ncbi usage guidelines (no more than 3 url requests per second
      if superkingdom == 'Bacteria'
	bact_hash[taxon] = freq
      elsif superkingdom == 'Archaea'
	arch_hash[taxon] = freq
      elsif superkingdom == 'Viruses'
	vir_hash[taxon] = freq
      elsif superkingdom == 'Eukaryota'
	euk_hash[taxon] = freq
      else
	undef_hash[taxon] = freq
      end
    end
    
    
    File.open("#{profile.sub('.csv', '')}_bacteria.csv", 'wb') do |file|
      file.puts "taxon,frequency"
      bact_hash.each do |t,f|
      file.puts "#{t},#{f}"
      end
    end
    File.open("#{profile.sub('.csv', '')}_archaea.csv", 'wb') do |file|
      file.puts "taxon,frequency"
      arch_hash.each do |t,f|
      file.puts "#{t},#{f}"
      end
    end
    File.open("#{profile.sub('.csv', '')}_viruses.csv", 'wb') do |file|
      file.puts "taxon,frequency"
      vir_hash.each do |t,f|
      file.puts "#{t},#{f}"
      end
    end
    File.open("#{profile.sub('.csv', '')}_eukaryota.csv", 'wb') do |file|
      file.puts "taxon,frequency"
      euk_hash.each do |t,f|
      file.puts "#{t},#{f}"
      end
    end
    File.open("#{profile.sub('.csv', '')}_undefined.csv", 'wb') do |file|
      file.puts "taxon,frequency"
      undef_hash.each do |t,f|
      file.puts "#{t},#{f}"
      end
    end
    
  end
end
           