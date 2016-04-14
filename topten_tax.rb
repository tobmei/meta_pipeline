require 'csv'

# tax = 'genus'

['kingdom','phylum','class','order','family','genus','species'].each do |tax|
  vhash = Hash.new
  phash = Hash.new
  ahash = Hash.new
  
  ARGV.each do |vent|
    ve = File.basename(vent)
    next if ve =~ /TARA/
    profile_file = ''
    Dir.glob("#{vent}/profiles/taxonomic/Taxy/*ID.csv") do |file|
      profile_file = file if file =~ /#{tax}/
    end
    if !File.exists?(profile_file)
      STDERR.puts "Profile file #{profile_file} not found"
      #exit 1
      next
    end
    vhash[ve] = Hash.new
    CSV.open(profile_file, 'r').each do |line|
      next if line[0] == 'taxon'
      pfam = line[0]
      count = line[1].chomp.to_f
      vhash[ve][pfam] = count
    end
  end

  vhash.each do |v,h|
    h.each do |p,rp|
      phash[p] = Hash.new if !phash.has_key?(p)
      phash[p][v] = rp
    end
  end

  phash.each do |p,h|
    min = 1.0
    max = 0.0
    min_vent = nil
    max_vent = nil
    prop_sum = 0.0
    avg = 0.0
    h.each do |v,rp|
      if rp < min
	min = rp
	min_vent = v
      end
      if rp > max
	max = rp
	max_vent = v
      end
      prop_sum += rp
    end
    ahash[p] = Hash.new if !ahash.has_key?(p)
    ahash[p][:avg_prop] = (prop_sum / h.size).to_f
    ahash[p][:min] = [min,min_vent]
    ahash[p][:max] = [max,max_vent]
  end

  topten_pfam = []
  ahash.sort_by{|p,h| -h[:avg_prop]}.each_with_index do |k,idx|
    if idx < 10
      topten_pfam.push(k[0])
    end
  end

  # write data for boxplot
  # pfam1    prop
  # pfam1    prop
  # pfam2    prop
  # pfam2    prop
  #...
  CSV.open("/scratch/gi/coop/perner/metameta/stats/abundance/boxplot_temp_#{tax}.csv", 'w') do |csv|
    csv << ['tax','freq']
    topten_pfam.each do |pfam|
      phash[pfam].each do |v,p|
	pfam = pfam.length > 30 ? "#{pfam[0..30]}..." : pfam
      csv << [pfam,p]
      end
    end
  end

  #write min max list
  CSV.open("/scratch/gi/coop/perner/metameta/stats/abundance/minmax_#{tax}.csv", 'w') do |csv|
    csv << ['pfam','min','min_vent','max','max_vent']
    topten_pfam.each do |pfam|
      csv << [pfam,ahash[pfam][:min][0],ahash[pfam][:min][1],ahash[pfam][:max][0],ahash[pfam][:max][1]]
    end
  end
  
  `Rscript R/boxplot.r /scratch/gi/coop/perner/metameta/stats/abundance/boxplot_temp_#{tax}.csv #{tax} /scratch/gi/coop/perner/metameta/stats/abundance/abundance_#{tax}.pdf`
  `rm /scratch/gi/coop/perner/metameta/stats/abundance/boxplot_temp_#{tax}.csv`
  
end
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
  
  
  
    
 
