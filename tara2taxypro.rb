require 'csv'

#This script performs a correlation of taxonomic abundances
#calculated by taxy-pro and tara
#Usage: ruby tara2taxypro <tara_vent> ...

ARGV.each do |vent|

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
    phylum = row[1] == nil || row[1] == '' ? 'Unknown' : row[1]
    clas = row[2]== nil || row[2] == '' ? 'Unknown' : row[2]
    order = row[3]== nil || row[3] == '' ? 'Unknown' : row[3]
    family = row[4]== nil || row[4] == '' ? 'Unknown' : row[4]
    genus = row[5]== nil || row[5] == '' ? 'Unknown' : row[5]
    count = row[index].to_f
    
    tax_hash['kingdom'][kingdom] += count
    tax_hash['phylum'][phylum] += count 
    tax_hash['class'][clas] += count 
    tax_hash['order'][order] += count 
    tax_hash['family'][family] += count 
    tax_hash['genus'][genus] += count 
    total_count += count
    
  end

  tax_hash.each do |tax,count_hash|
    count_hash.each do |taxon,c|
      tax_hash[tax][taxon] = c / total_count
    end
  end


  ['kingdom','phylum','class','order','family','genus'].each do |tax|
    
    CSV.open("#{vent}/profiles/taxonomic/tara/#{tax}.csv", "w") do |csv|
      csv << ['taxon','frequency']
      tax_hash[tax].each do |taxon,freq|
	csv << [taxon,freq]                                                     
      end                                                       
    end
    
  end

  ['kingdom','phylum','class','order','family','genus'].each do |tax|
    file_tara = nil
    file_metapipe = nil
    Dir.glob("#{vent}/profiles/taxonomic/tara/*.csv") do |file|
      file_tara = file if file =~ /#{tax}/
    end
    Dir.glob("#{vent}/profiles/taxonomic/Taxy/*.csv") do |file|
      file_metapipe = file if file =~ /#{tax}/
    end
    
    metapipe_hash = Hash.new{0.0}
    File.open(file_metapipe).each do |line|
      line = line.split(',')
      next if line[0] == 'taxon'
      taxon = line[0]
      taxon = 'Unknown' if taxon =~ /Unknown/
      freq = line[1].chomp.to_f
      metapipe_hash[taxon] += freq if freq != 0.0
    end
    
    tara_hash = Hash.new{0.0}
    File.open(file_tara).each do |line|
      line = line.split(',')
      next if line[0] == 'taxon'
      taxon = line[0]
      freq = line[1].chomp.to_f
      tara_hash[taxon] += freq if freq != 0.0
    end
    
    puts "#{tax} metapipeline: #{metapipe_hash.size}"
    puts "#{tax} tara: #{tara_hash.size}"
    overlap = 0
    metapipe_hash.each do |tax,f|
      overlap += 1 if tara_hash.has_key?(tax) && f > 0.0
    end
    puts "overlap #{tax}: #{overlap}"
    
    diff_set_metapipe = []
    metapipe_hash.each do |tax,f|
      diff_set_metapipe.push([tax,f]) if !tara_hash.has_key?(tax)
    end
    diff_set_tara = []
    tara_hash.each do |tax,f|
      diff_set_tara.push([tax,f]) if !metapipe_hash.has_key?(tax)
    end
    
    diff_set_metapipe = diff_set_metapipe.sort_by{|a,b| -b}
    diff_set_tara = diff_set_tara.sort_by{|a,b| -b}
    
    CSV.open("#{vent}/profiles/taxonomic/#{tax}_diff_set", "w") do |csv|
      csv << ['metapipe','tara']
      l = diff_set_tara.length > diff_set_metapipe.length ? diff_set_tara.length : diff_set_metapipe.length
      for i in 0..l
        csv << [diff_set_metapipe[i] == nil ? '' : "#{diff_set_metapipe[i][0]},#{diff_set_metapipe[i][1]}" , diff_set_tara[i] == nil ? '' : "#{diff_set_tara[i][0]},#{diff_set_tara[i][1]}"]
      end
    end

    pairs_hash = Hash.new
    metapipe_hash.each do |tax,f|
      tara_freq = tara_hash.has_key?(tax) ? tara_hash[tax] : 0.0
      pairs_hash[tax] = [f,tara_freq]
    end
    tara_hash.each do |tax,f|
      metapipe_freq = metapipe_hash.has_key?(tax) ? metapipe_hash[tax] : 0.0
      pairs_hash[tax] = [metapipe_freq,f]
    end

    
    CSV.open("#{vent}/profiles/taxonomic/#{tax}_tara_vs_taxypro.csv", "w") do |csv|
      csv << ['metapipe','tara']
      pairs_hash.each do |taxon,freq_arr|
# 	if !(freq_arr[0] == 0 || freq_arr[1] == 0)
	if taxon != 'Unknown'
	  csv << [freq_arr[0],freq_arr[1]]                                                     
	end
      end                                                       
    end
    
  end
  
end
 
ARGV.each do |vent|
  dir = "#{vent}/profiles/taxonomic"
  ['kingdom','phylum','class','order','family','genus'].each do |tax|
    input = nil
    Dir.glob("#{dir}/*.csv") do |file|
      input = file if file =~ /#{tax}/
    end
    `Rscript R/corr.r #{input} #{tax} 'Metapipeline' 'Tara' #{dir}/#{tax}.pdf`
  end
  `pdftk #{dir}/kingdom.pdf #{dir}/phylum.pdf #{dir}/class.pdf #{dir}/order.pdf #{dir}/family.pdf #{dir}/genus.pdf cat output #{dir}/metapipe_vs_tara.pdf`
  `rm -f #{dir}/kingdom.pdf #{dir}/phylum.pdf #{dir}/class.pdf #{dir}/order.pdf #{dir}/family.pdf #{dir}/genus.pdf`
end











