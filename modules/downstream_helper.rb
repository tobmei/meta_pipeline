require 'csv'


module Downstream_helper
  
  def Downstream_helper.generate_functional_profile_matrix(vents,output)
    pfam_arr = []
    vents_arr = ['Category']
    hash = Hash.new
    stamp_hash = Hash.new
    vents.each do |vent|
      vent_base = File.basename(vent)
      profiles_dir = "#{vent}/profiles/functional/uproc"
      uproc_file = "#{profiles_dir}/uproc.txt"
      vents_arr.push(vent_base) 
      File.open(uproc_file).each do |line|
	l = line.split(',')
	if l[0] == nil || l[1] == nil
	  STDERR.puts "Something went wrong while reading the file #{tax_file}. Could not split the line with ','. Maybe the file has a different separator?"
	  exit 1
	end
	next if l[0] == 'pfam'
	pfam_id = l[0]
	counts = l[1].chomp

	stamp_hash[pfam_id] = Hash.new(0) if !stamp_hash.has_key?(pfam_id)
	stamp_hash[pfam_id][vent_base] = counts

	pfam_arr.push(pfam_id) if !pfam_arr.include?(pfam_id)
	hash[vent_base] = Hash.new(0) if hash[vent_base] == nil
	hash[vent_base][pfam_id] = counts.chomp

      end
    end
    self.write_csv(hash,pfam_arr,"#{output}/functional_profile.csv",',')  
    self.write_csv(stamp_hash,vents_arr,"#{output}/functional_profile_stamp_compatible.csv","\t")  
  end
  
  def Downstream_helper.generate_taxonomic_profile_matrix(vents,output)
    tax_arr = []
    vf_hash = Hash.new
    vents.each do |vent|
      ve = File.basename(vent)
      ['kingdom','phylum','class','order','family','genus','species'].each do |tax|
        tax_file = nil
	Dir.glob("#{vent}/profiles/taxonomic/Taxy/*ID.csv") do |file|
	  tax_file = file if file =~ /#{tax}/
	end
	if tax_file == nil
	  STDERR.puts "No taxonomic file found for #{vent}. You should check the folder."
	  exit 1
	end
	File.open(tax_file).each_line do |line|
	  l = line.split(',')
	  if l[0] == nil || l[1] == nil
	    STDERR.puts "Something went wrong while reading the file #{tax_file}. Could not split the line with ','. Maybe the file has a different separator?"
	    exit 1
	  end
	  next if l[0] == 'taxon'
	  freq = l[1].chomp.to_f
	  t = l[0]
# 	  next if t =~ /Unknown/
# 	  t = 'Unknown' if t =~ /Unknown/

	  tax_arr.push(t) if !tax_arr.include?(t)
	  vf_hash[ve] = Hash.new(0.0) if vf_hash[ve] == nil
	  vf_hash[ve][t] += freq
	end
        self.write_csv(vf_hash,tax_arr,"#{output}/taxonomic_profile_#{tax}_level.csv")
	tax_arr = []
      end
    end
  end
  
  def Downstream_helper.generate_taxonomic_profile_matrix_stamp(vents,output)
    vents_arr = ['Category']
    hash = Hash.new
    vents.each do |vent|
      tax_file = nil
      Dir.glob("#{vent}/profiles/taxonomic/Taxy/*ID.csv") do |file|
	tax_file = file if file =~ /species/
      end
      if tax_file == nil
	STDERR.puts "No taxonomic file found for #{vent}. You should check the folder."
	exit 1
      end
      ve = File.basename(vent)
      vents_arr.push(ve) 
      File.open(tax_file).each_line do |line|
	l = line.split(",")
# 	next if l[0] == '#frequency' || l[0] == 'frequency'
	next if l[0] == 'taxon'
	freq = l[1].chomp
    #     superkingdom = l[1].chomp
    #     phylum = l[2].chomp
    #     clas = l[3].chomp
    #     order = l[4].chomp
    #     family = l[5].chomp
    #     genus = l[6].chomp
	species = l[0].chomp
# 	species = 'Unknown' if species =~ /Unknown/
	hash[species] = Hash.new(0.0) if !hash.has_key?(species)
	hash[species][ve] = freq
      end
    end
    self.write_csv(hash,vents_arr,"#{output}/taxonomic_profile_species_level_stamp.csv","\t")
  end
  
  def Downstream_helper.get_anosim_categories(meta_file)
    cat_hash = Hash.new
    File.open(meta_file).each do |line|
      line = line.split("\t")
      line.each do |cat|
        next if cat == 'vent' || cat == 'name_to_plot'
        cat_hash[cat.chomp] = []
      end
      break
    end
    CSV.foreach(meta_file,:col_sep=>"\t") {|row| 
      i = 2
      cat_hash.each do |cat,arr|                                   
        cat_hash[cat] << row[i]
        i += 1
      end
    }
    cats = []
    count = 0
    cat_hash.each do |cat,vals|
      vals.each do |val|
	count += 1 if val != nil && val != 'unclassified'
      end
      cats.push(cat) if count > 5
      count = 0
    end
    return cats
  end
  
  def Downstream_helper.write_anosim_results(result,out)
    if !File.exists?("#{out}anosim.csv")
      CSV.open("#{out}anosim.csv", 'w') do |csv|
        csv << ['grouping','R','p-value']
	result.each do |r|
	  r = r.split("\n")
	  next if r[0] == nil || r[1] == nil || r[2] == nil
	  group = r[0].split(' ')[1] != nil ? r[0].split(' ')[1] : 'n.a.'
	  stat = r[1].split(' ')[1] != nil ? r[1].split(' ')[1] : 'n.a.'
	  pvalue = r[2].split(' ')[1] != nil ? r[2].split(' ')[1] : 'n.a.'
	  csv << [group,stat,pvalue]
	end
      end
    end 
  end

  
  def Downstream_helper.write_csv(hash,arr,name,sep)
    CSV.open(name, "w",:col_sep=>sep) do |csv|
      row_arr = []
      csv << arr
      hash.each do |k,v|
	row_arr.push(k)
	arr.each do |t|
	  next if t == 'Category'
	  row_arr.push(v[t])
	end
        csv << row_arr
	row_arr = []
      end
    end
  end

  
  
end



