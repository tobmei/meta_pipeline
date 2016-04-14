require 'csv'


ARGV.each do |vent|

  ['kingdom','phylum','class','order','family','genus','species'].each do |tax|
    file_metapipe = nil
    Dir.glob("#{vent}/profiles/taxonomic/Taxy/*ID.csv") do |file|
      file_metapipe = file if file =~ /#{tax}/
    end

    hash = Hash.new{0.0}
    File.open(file_metapipe).each do |line|
      line = line.split(',')
      next if line[0] == 'taxon'
      taxon = line[0]
      if taxon =~ /Unknown/
	taxon = "Unknown #{taxon.match(/(?![ Unknown ]).*/)}"
      end
      freq = line[1].chomp.to_f
      hash[taxon] = freq
    end 
    
    CSV.open(file_metapipe, "w") do |csv|
      csv << ['taxon','frequency']
      hash.each do |taxon,freq|
	csv << [taxon,freq]                                                     
      end                                                       
    end
    
    
  end
end
