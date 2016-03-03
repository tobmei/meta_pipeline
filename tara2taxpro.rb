require 'csv'

vent = ARGV[0]

tara = File.basename(vent).gsub(/_\d\d$/,'')


tax_hash = Hash.new
tax_hash['kingdom'] = Hash.new{0}
tax_hash['phylum'] = Hash.new{0}
tax_hash['class'] = Hash.new{0}
tax_hash['order'] = Hash.new{0}
tax_hash['family'] = Hash.new{0}
tax_hash['genus'] = Hash.new{0}
krona_arr = []
i = 0
index = 0
total_count = 0.0
count = 0.0
CSV.foreach('data/miTAG.taxonomic.profiles.release.tsv', :col_sep=> "\t") do |row|
  if row[0] == 'Domain'
    row.each do |t|
      if tara == t
	index = i
      end
      i += 1
    end
  next
  end
  kingdom = row[0]
  phylum = row[1] == nil ? 'Unknown' : row[1]
  clas = row[2]== nil ? 'Unknown' : row[2]
  order = row[3]== nil ? 'Unknown' : row[3]
  family = row[4]== nil ? 'Unknown' : row[4]
  genus = row[5]== nil ? 'Unknown' : row[5]
  count = row[index].to_i
  
#   krona_arr.push([count,kingdom,phylum,clas,order,family,genus]) if count != 0.0
  
  tax_hash['kingdom'][kingdom] += count
  
  if phylum == nil
    tax_hash['phylum']['Unknown'] += count
  else
    tax_hash['phylum'][phylum] += count 
  end
  if clas == nil
    tax_hash['class']['Unknown'] += count
  else
    tax_hash['class'][clas] += count 
  end
  if order == nil
    tax_hash['order']['Unknown'] += count
  else
    tax_hash['order'][order] += count 
  end
  if family == nil
    tax_hash['family']['Unknown'] += count
  else
    tax_hash['family'][family] += count 
  end
  if genus == nil
    tax_hash['genus']['Unknown'] += count
  else
    tax_hash['genus'][genus] += count 
  end

  total_count += count
end

# krona_arr.each do |row|
#   row[0] = row[0] / total_count
# end


# puts "#frequency\tsuperkingdom\tphylum\tclass\torder\tfamily\tgenus"
# krona_arr.each do |row|
#   row.each do |item|
#     print "#{item}\t"
#   end
#   puts "\t"
# end

tax_hash.each do |tax,count_hash|
  count_hash.each do |taxon,c|
    tax_hash[tax][taxon] = c / total_count
  end
end


['kingdom','phylum','class','order','family','genus'].each do |tax|
  
  CSV.open("#{vent}/profiles/taxonomic/#{tax}.csv", "w") do |csv|
    csv << ['taxon','frequency']
    tax_hash[tax].each do |taxon,freq|
      csv << [taxon,freq]                                                     
    end                                                       
  end
  
end

['kingdom','phylum','class','order','family','genus'].each do |tax|
  file_tara = nil
  file_metapipe = nil
  Dir.glob("#{vent}/profiles/taxonomic/*.csv") do |file|
    file_tara = file if file =~ /#{tax}/
  end
  Dir.glob("#{vent}/profiles/taxonomic/Taxy/*.csv") do |file|
    file_metapipe = file if file =~ /#{tax}/
  end
  
  metapipe_hash = Hash.new
  File.open(file_metapipe).each do |line|
    line = line.split(',')
    next if line[0] == 'taxon'
    taxon = line[0]
    taxon = 'Unknown' if taxon =~ /Unknown/
    freq = line[1].chomp.to_f
    metapipe_hash[taxon] = freq if freq != 0.0
  end
  
  tara_hash = Hash.new
  File.open(file_tara).each do |line|
    line = line.split(',')
    next if line[0] == 'taxon'
    taxon = line[0]
    freq = line[1].chomp.to_f
    tara_hash[taxon] = freq if freq != 0.0
  end
  
  
  puts "#{tax}: #{metapipe_hash.size}"
  puts "#{tax}: #{tara_hash.size}"
  identical = 0
  metapipe_hash.each do |tax,f|
    identical += 1 if tara_hash.has_key?(tax) && f > 0
  end
  puts "identical #{tax}: #{identical}"
  
  
  pairs_hash = Hash.new
  metapipe_hash.each do |tax,f|
    tara_freq = tara_hash.has_key?(tax) ? tara_hash[tax] : 0.0
    pairs_hash[tax] = [f,tara_freq]
  end
  tara_hash.each do |tax,f|
    metapipe_freq = metapipe_hash.has_key?(tax) ? metapipe_hash[tax] : 0.0
    pairs_hash[tax] = [metapipe_freq,f]
  end

  CSV.open("#{vent}/profiles/taxonomic/#{tax}_pairs.csv", "w") do |csv|
    csv << ['metapipe','tara']
    pairs_hash.each do |taxon,freq_arr|
      if !(freq_arr[0] == 0 || freq_arr[1] == 0)
        csv << [freq_arr[0],freq_arr[1]]                                                     
      end
    end                                                       
  end
  
end
 














