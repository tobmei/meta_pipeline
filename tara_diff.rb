require 'open-uri'
require 'json'

base = "http://eggnogapi.embl.de/nog_data/json/domains"
cog_id = ''


#parse cog profile
File.open('data/cog_profile.tsv').each do |line|
  line = line.split("\t")
  

#parse pfam-clansruby get url content
clans_hash = Hash.new
File.open('data/Pfam-A.clans.tsv').each do |line|
  line = line.split("\t")
  clan = line[3]
  pfam_id = line[0]
  clans_hash[clan] = pfam_id
end

profile_hash = Hash.new

json = JSON.parse(open("#{base}/#{cog_id}") { |io| io.read })
if json['domains']['PFAM'][0][0] != nil

  pfam_clan =  json['domains']['PFAM'][0][0]
  pfam = clans_hash[pfam_clan]
  profile_hash[pfam] = cog_count 
  
end
 

