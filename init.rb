require 'csv'
require 'mkmf'


vents_folder = ARGV[0]
stats_folder = ARGV[1]
accessions = ARGV[2] != nil ? ARGV[2] : nil

if accessions != nil
   require 'nokogiri'
   require 'net/http'
end


if ARGV.size < 2 
  puts "Usage: ruby init.rb <vents_folder> <output_folder> [accession_file]"
  exit 0
end

`mkdir #{stats_folder}` if !Dir.exists?(stats_folder)

def check_new_vents(vents_folder,stats_folder,accessions)
  vents_arr = []
  optvents_arr = nil
  metavents_arr = nil
  Dir.glob("#{vents_folder}/*").each do |vent|
    vb = File.basename(vent)
    if !Dir.exists?("#{vent}/raw_reads")
      STDERR.puts "Directory #{vent}/raw_reads not found. Please see README file for required directory structure."
      exit 1
    end
    Dir.entries("#{vent}/raw_reads").each do |entry|
      if !File.directory?(entry) 
        if (entry =~ /fastq.gz$/) == nil
          STDERR.puts "Invalid format for #{entry}. See README for details."
          exit 1
        end
      end
    end
    vents_arr.push(vb)
  end
  if vents_arr.size == 0
    STDERR.puts "No vents found in #{vents_folder}."
    exit 1
  end

  new_vents = []
  if File.exists?("#{stats_folder}/options.tsv")
    optvents_arr = []
    CSV.foreach("#{stats_folder}/options.tsv", :col_sep=>"\t") do |line|
      vent = line[0]
      next if vent == 'vent'
      optvents_arr.push(vent) if vent != nil
    end
    vents_arr.each do |vent|
      new_vents.push(vent) if !optvents_arr.include?(vent)
    end
    if new_vents.size > 0
      write_options(new_vents,'a',stats_folder) 
    else
      puts "No new vents found. Nothing added to options.tsv"
    end
  else
    write_options(vents_arr,'w',stats_folder)
    puts "options.tsv successfully created at #{stats_folder}"
  end

  new_vents = []
  if File.exists?("#{stats_folder}/vents_meta.tsv")
    metavents_arr = []
    CSV.foreach("#{stats_folder}/vents_meta.tsv", :col_sep=>"\t") do |line|
      vent = line[0]
      next if vent == 'vent'
      metavents_arr.push(vent)
    end
    vents_arr.each do |vent|
      new_vents.push(vent) if !metavents_arr.include?(vent)
    end
    if new_vents.size > 0
      write_meta(new_vents,'a',stats_folder,accessions) 
    else
      puts "No new vents found. Nothing added to vents_meta.tsv"
    end
  else
    write_meta(vents_arr,'w',stats_folder,accessions)
    puts "vents_meta.tsv successfully created at #{stats_folder}"
  end
  return new_vents,vents_arr
end

def write_options(vents,mode,stats_folder)
  CSV.open("#{stats_folder}/options.tsv", mode, :col_sep=>"\t") do |csv|
    csv << ['vent','platform','fosmid_based(y/n)','adapter/tag_seq','pfam2go'] if mode == 'w'
    vents.each do |vent|
      csv << [vent]
    end
  end
end

def write_meta(vents,mode,stats_folder,accessions)
  metadata = accessions != nil ? get_metadata(accessions) : nil
  CSV.open("#{stats_folder}/vents_meta.tsv", mode, :col_sep=>"\t") do |csv|
    csv << ['vent','name_to_plot','collection_date','env_biome','env_feature','env_material','geo_loc_name','host','lat_lon','depth','temp'] if mode == 'w'
    if metadata != nil 
      metadata.each do |vent,data|
        csv << [vent,' ', data['collection_date'], data['env_biome'], data['env_feature'], data['env_material'], data['geo_loc_name'], data['host'], data['lat_lon'], data['depth'], data['temp']]
      end
    else
      vents.each do |vent|
        csv << [vent]
      end
    end
  end
end
      
def check_requirements()
  executables = ['fastqc','seqtk','cln2qual','gt','bwa','samtools','bedtools','uproc-dna','sra-dump','diamond']
  check = true
  puts 'Looking for required executables...'
  executables.each do |exec|
    path = find_executable("#{exec}")
    check = false if !path
  end
  #delete log file
  `rm mkmf.log` if File.exists?('mkmf.log')

  if !check
    puts "One or more executables couldn't be found. Install the missing ones or make sure that they are in your $PATH"
  else
    puts 'Success!'
  end
end 
     
def get_metadata(accessions)
  base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils'
  search_biosample = 'esearch.fcgi?tool=ruby&email=tobias.meier@studium.uni-hamburg.de&db=biosample&term'
  search_sra = 'esearch.fcgi?tool=ruby&email=tobias.meier@studium.uni-hamburg.de&db=sra&usehistory=y&term'
  fetch_biosample = 'efetch.fcgi?tool=ruby&email=tobias.meier@studium.uni-hamburg.de&db=biosample'
  metadata_all = Hash.new

  File.open(accessions).each do |line|
    vent = line.split(',').first
    accs_number = line.split(',').last.chomp
    # search for biosample_id
    uri = URI("#{base}/#{search_biosample}=#{accs_number}&usehistory=y")
    xml_result = Net::HTTP.get(uri) 
    web_env = xml_result.scan(/<WebEnv>(\S+)<\/WebEnv>/)
    query_key = xml_result.scan(/<QueryKey>(\d+)<\/QueryKey>/)
    if(web_env.empty?)
      puts "No biosamples found for #{accs_number}"
      next
    end
    
    # fetch metadata for biosample
    uri = URI("#{base}/#{fetch_biosample}&query_key=#{query_key[0][0]}&WebEnv=#{web_env[0][0]}") 
    xml_result = Net::HTTP.get(uri) 
    xml = Nokogiri::XML(xml_result)
    tags = xml.xpath("//Attribute")
    metadata = Hash.new
    metadata['vent'] = vent
    tags.each do |node|
      metadata[node['harmonized_name']] = node.content
    end
    metadata_all[vent] = metadata
    
    # search sra ids with accession number
    #uri = URI("#{base}/#{search_sra}=#{accs_number}")
    #xml_result = Net::HTTP.get(uri)
    #web_env = xml_result.scan(/<WebEnv>(\S+)<\/WebEnv>/)
    #query_key = xml_result.scan(/<QueryKey>(\d+)<\/QueryKey>/)
    # fetch run ids to download .sra files
    #xml_result = client.get_content("#{base}/efetch.fcgi?db=sra&query_key=#{query_key[0][0]}&WebEnv=#{web_env[0][0]}")
    #runs = xml_result.scan(/<PRIMARY_ID>(D|E|SRR\d+)<\/PRIMARY_ID>/)
    
    #sleep for 1 second to comply with the ncbi usage guidelines (no more than 3 url requests per second)
    #see http://www.ncbi.nlm.nih.gov/books/NBK25497/ for details
    sleep 1
  end
  metadata_all
end


check_requirements()
new_vents,old_vents = check_new_vents(vents_folder,stats_folder,accessions)

if new_vents.size == 0
  puts "Existing vents:"
  puts old_vents
else
  puts "New vents found:"
  puts new_vents
  puts "Vents added to options.tsv and vents_meta.tsv"
end





