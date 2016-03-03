require 'open-uri'
require 'json'
require 'csv'

base_egg = "http://eggnogapi.embl.de/nog_data/json/domains"
base_up = "http://www.uniprot.org/uniprot"
cog_id = ''
tara = ARGV[0].gsub(/_\d\d$/,'')
profile_hash = Hash.new

#parse pfam-clansruby
clans_hash = Hash.new
File.open('data/Pfam-A.clans.tsv').each do |line|
  line = line.split("\t")
  clan = line[3]
  pfam_id = line[0]
  clans_hash[clan] = pfam_id
end

#parse nog2uniprot
nog2uniprot = Hash.new
File.open('data/UniProtAC2eggNOG.3.0.tsv').each do |line|
  line = line.split("\t")
  if line[1].chomp =~ /^NOG/
    nog = line[1].chomp
    uniprot = line[0]
    if !nog2uniprot.has_key?(nog)
      nog2uniprot[nog] = []
    end
    nog2uniprot[nog] = nog2uniprot[nog].push(uniprot)
  end
end

#parse cog profile
i = 0
index = 0
CSV.foreach('data/TARA243.OG.profile.release.csv', :col_sep=> "\t") do |row|
  if row[0] == 'cog'
    row.each do |t|
      if tara == t
	index = i
      end
      i += 1
    end
    next
  end
  next if row[0] == 'sum_not_annotated'
  count = row[index].chomp.to_f.round
  
  if row[0] =~ /^COG/
    cog_id = row[0]
#     puts cog_id
    json = JSON.parse(open("#{base_egg}/#{cog_id}") { |io| io.read })
    if json['domains'] != nil && json['domains']['PFAM'] != nil && json['domains']['PFAM'][0] != nil && json['domains']['PFAM'][0][0] != nil
      json['domains']['PFAM'].each do |pfams| #take pfams with frequency >= 50% ??
	if pfams[2].to_f >= 50.0
	  pfam_clan =  pfams[0]
	  if clans_hash.has_key?(pfam_clan)
	    pfam_id = clans_hash[pfam_clan]
	    profile_hash[pfam_id] = 0 if profile_hash[pfam_id] == nil 
	    profile_hash[pfam_id] += count   
	  end
	end
      end
    end
  elsif row[0] =~/^NOG/
    nog_id = row[0]
    if nog2uniprot.has_key?(nog_id)
      nog2uniprot[nog_id].each do |uprot_acc|
#         puts uprot_acc
        begin
          xml = open("#{base_up}/#{uprot_acc}.xml") { |io| io.read }
        rescue OpenURI::HTTPError
	  xml = open("#{base_up}/?query=replaces:#{uprot_acc}&format=xml") { |io| io.read }
        end
        pfams = xml.scan(/type="Pfam" id="(PF\d\d\d\d\d)"/)
        if pfams != nil
	  pfams.each do |pfam_id|
	    profile_hash[pfam_id[0]] = 0 if profile_hash[pfam_id[0]] == nil 
	    profile_hash[pfam_id[0]] += count
	  end
        end
      end
    end    
  end
  
end

puts 'pfam,count'
profile_hash.each do |pfam,count|
  puts "#{pfam},#{count}"
end



 

