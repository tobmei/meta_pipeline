require 'httpclient'
require 'nokogiri'
require 'csv'


#accession number for sra or biosample given
#search number in biosample db -> get biosample id -> get metadata for biosample via fetch
#search number in sra db -> get sra ids -> fetch sra -> get run ids und download with wget

client = HTTPClient.new

base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils'
search_biosample = '/esearch.fcgi?db=biosample&term='
search_sra = '/esearch.fcgi?db=sra&usehistory=y&term='
fetch_biosample = '/efetch.fcgi?db=biosample&id='
metadata_all = []

File.open('accessions.txt').each do |line|
  vent_name = line.split(',').first
  accs_number = line.split(',').last
  # search for biosample_id
  xml_result = client.get_content(base + search_biosample + accs_number) 
  biosample_id = xml_result.scan(/<Id>(\d+)<\/Id>/)
  if(biosample_id.empty?)
    puts 'No biosamples found for ' + accs_number
    next
  end
  puts biosample_id[0][0]
  
  # fetch metadata for biosample
  xml_result = client.get_content(base + fetch_biosample + biosample_id[0][0]) 
  xml = Nokogiri::XML(xml_result)
  tags = xml.xpath("//Attribute")
  metadata = Hash.new
  metadata['vent_name'] = vent_name
  tags.each do |node|
    metadata[node['harmonized_name']] = node.content
  end
  metadata_all.push(metadata)
  sleep 1
  
  # search sra ids with accession number
  xml_result = client.get_content("#{base}#{search_sra}#{accs_number}")
  web_env = xml_result.scan(/<WebEnv>(\S+)<\/WebEnv>/)
  query_key = xml_result.scan(/<QueryKey>(\d+)<\/QueryKey>/)
  # fetch run ids to download .sra files
  xml_result = client.get_content("#{base}/efetch.fcgi?db=sra&query_key=#{query_key[0][0]}&WebEnv=#{web_env[0][0]}")
  runs = xml_result.scan(/<PRIMARY_ID>(D|E|SRR\d+)<\/PRIMARY_ID>/)

  puts runs
  sleep 1
end

# CSV.open('project_meta.csv', 'wb') do |csv|
#   csv << ['vent_name', 'collection_date', 'env_biome', 'env_feature', 'env_material', 'geo_loc_name', 'host', 'lat_lon', 'depth', 'temp']
#   metadata_all.each do |data|
#     csv << [data['vent_name'], data['collection_date'], data['env_biome'], data['env_feature'], data['env_material'], data['geo_loc_name'], data['host'], data['lat_lon'], data['depth'], data['temp']]
#   end
# end


