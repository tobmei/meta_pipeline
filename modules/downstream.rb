require 'csv'


module Downstream
  
  def Downstream.generate_functional_profile_matrix(vents,output)
    pfam_arr = []
    vents_arr = ['Category']
    hash = Hash.new
    stamp_hash = Hash.new
    vents.each do |vent|
      next if vent =~ /TARA/
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
      hash = Hash[hash.sort]
    end
    self.write_csv(hash,pfam_arr,"#{output}/functional_profile.csv",',')  
    self.write_csv(stamp_hash,vents_arr,"#{output}/functional_profile_stamp_compatible.csv","\t")  
  end
  
  def Downstream.generate_taxonomic_profile_matrix(vents,output)
    tax_arr = []
    vf_hash = Hash.new
    vents.each do |vent|
      ve = File.basename(vent)
      next if vent =~ /TARA/
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
          #next if t =~ /Unknown/
          #t = 'Unknown' if t =~ /Unknown/
          tax_arr.push(t) if !tax_arr.include?(t)
          vf_hash[ve] = Hash.new(0.0) if vf_hash[ve] == nil
          vf_hash[ve][t] += freq
        end
        vf_hash = Hash[vf_hash.sort]
        self.write_csv(vf_hash,tax_arr,"#{output}/taxonomic_profile_#{tax}_level.csv",",")
        tax_arr = []
      end
    end
  end
  
  def Downstream.generate_taxonomic_profile_matrix_stamp(vents,output)
    vents_arr = ['Category']
    hash = Hash.new
    vents.each do |vent|
      next if vent =~ /TARA/
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
        next if l[0] == 'taxon'
        freq = l[1].chomp
        #superkingdom = l[1].chomp
        #phylum = l[2].chomp
        #clas = l[3].chomp
        #order = l[4].chomp
        #family = l[5].chomp
        #genus = l[6].chomp
        species = l[0].chomp
        #species = 'Unknown' if species =~ /Unknown/
        hash[species] = Hash.new(0.0) if !hash.has_key?(species)
        hash[species][ve] = freq
      end
    end
    self.write_csv(hash,vents_arr,"#{output}/taxonomic_profile_species_level_stamp.csv","\t")
  end
  
  def Downstream.get_anosim_categories(meta_file)
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
  
  def Downstream.write_anosim_results(result,out)
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

  
  def Downstream.write_csv(hash,arr,name,sep)
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
  
  def Downstream.stamp_run(profile,metadata,field,out)
    out_dir = File.dirname(out)
    self.stamp_call(profile,metadata,field,out_dir)
    if !File.exists?("#{out_dir}/stamp_result_temp.tsv")
      STDERR.puts "Error. Stamp result file not created."
      exit 1
    end
    line_count = `wc -l #{out_dir}/stamp_result_temp.tsv`.strip.split(' ')[0].to_i
    if line_count < 2
      puts "Stamp could not find any active features for group #{field}"
    else
      self.stamp_parser("#{out_dir}/stamp_result_temp.tsv",metadata,field,out,profile)
    end
  end
      
  def Downstream.stamp_call(profile,metadata,field,out_dir)
    output = `python /work/gi/software/stamp-2.0.1/commandLine.py --typeOfTest 'Multiple groups' --profile #{profile} --metadata #{metadata} --field #{field} --statTest 'ANOVA' --outputTable #{out_dir}/stamp_result_temp.tsv`
    puts output
    if $?.exitstatus != 0
      STDERR.puts 'Error while running stamp'
      exit 1
    end
  end
  
  def Downstream.stamp_parser(stamp_file,metadata,group,out,profile)
    group_hash = Hash.new
    out_dir = File.dirname(out)

    #barplot and boxplot data

    #parse group_file
    i = 0
    idx = 0
    name_to_plot = Hash.new
    File.open(metadata).each do |line|
      line = line.split("\t")
      if line[0] == 'vent'
        line.each do |v|
        if group == v.chomp
          idx = i
        end
        i += 1
      end
      next
    end
    vent = line[0]
    to_plot = line[1]
    g = line[idx]
    group_hash[vent] = g
    name_to_plot[vent] = to_plot
    end

    if idx == 0
      STDERR.puts "Error: Group #{group} not found in meta_file"
      exit 1
    end


    max_effect = 0.0
    effect_index = 0
    header = nil
    File.open(stamp_file).each_with_index do |row, index|
      row = row.split("\t")
      if row[0] =~ /Category/
        header = row
        next
      end
      pvalue = row[2].to_f
      effect = row[3].to_f
      if effect > max_effect
        effect_index = index
        max_effect = effect
      end
    end
    if header == nil
      STDERR.puts "Error. Something is wrong with #{stamp_file}."
      exit 1
    end
    
    file = CSV.read(stamp_file, :col_sep => "\t")

    h = Hash[header.zip(file[effect_index])]

    pvalue = (h["p-values (corrected)"]).to_f.round(6)
    feature = h["Category"].gsub(' ','_')
    effect = max_effect.to_f.round(3)

    plot_hash = Hash.new
    h.each do |k,v|
      if k =~ /: rel. freq./
        vent = k.scan(/^[^\:]*/)[0]
        plot_hash[vent] = [group_hash[vent],v]
      end
    end

    CSV.open("#{out_dir}/stamp_bar_temp.tsv", "w", :col_sep => "\t") do |csv|
      csv << ['vent','value','Gruppe']
      plot_hash.each do |vent,v|
        csv << [name_to_plot[vent],v[1],v[0]]
      end
    end

    #heatmap
    heat_hash = Hash.new

    max_effects = []
    CSV.foreach(stamp_file, :col_sep => "\t") {|row| max_effects << row[3]}
    max_effects.shift
    max_effects = max_effects.sort.pop(20)

    start_index = 0
    header.each_with_index do |v,i|
      if v =~ /: rel. freq./
	      start_index = i
	      break
      end
    end

    File.open(stamp_file).each do |row|
      row = row.split("\t")
      next if row[0] == 'Species'
      next if !max_effects.include?(row[3])
      label = "#{row[0]}(#{row[3].to_f.round(3)},#{row[2].to_f.round(4)})"
      heat_hash[label] = Hash.new
      (start_index..row.length).step(3) do |n|
	      heat_hash[label][header[n].scan(/^[^\:]*/)[0]] = row[n]
      end
    end

    CSV.open("#{out_dir}/stamp_heat_temp.tsv", "w", :col_sep => "\t") do |csv|
      csv << ['feature','vent','Frequenz']
      heat_hash.each do |feat,vent_value_hash|
	      vent_value_hash.each do |vent,value|
	        csv << [feat,name_to_plot[vent],value]
	      end
      end
    end
    
  `Rscript R/stamp.r #{out_dir}/stamp_bar_temp.tsv #{out_dir}/stamp_heat_temp.tsv #{stamp_file} #{effect} #{pvalue} #{feature} #{out}`
  `rm #{out_dir}/stamp_bar_temp.tsv`
  `rm #{out_dir}/stamp_heat_temp.tsv`
  `rm #{out_dir}/stamp_result_temp.tsv`
  
  
    if File.exists?(out)
      puts "Output file successfully created for group #{group} in #{out_dir}"
    else
      STDERR.puts "Error. No output file created"
      exit 1
    end

  end
  
  def Downstream.topten_func(vents)
    vhash = Hash.new
    phash = Hash.new
    ahash = Hash.new
    method = 'uproc'

    'vhash = {vent => {pfam=>count, pfam=>count, ...}, vent => {...}, ...}'
    'phash = {pfam => {vent=>proportion, vent=>proportion, ..}, pfam => {...}, ...}'
    'ahash = {pfam => {avg_prop=>prop, min=>[prop,vent], max=>[prop,vent]}, pfam => {...}, ...}'

    vents.each do |vent|
      ve = File.basename(vent)
      next if ve =~ /TARA/
      profile_file = "#{vent}/profiles/functional/#{method}/#{method}.txt"
      if !File.exists?(profile_file)
        STDERR.puts "Profile file #{profile_file} not found"
        #exit 1
        next
      end
      vhash[ve] = Hash.new
      count_sum = 0.0
      CSV.open(profile_file, 'r').each do |line|
        next if line[0] == 'pfam'
        pfam = line[0]
        count = line[1].chomp.to_i
        vhash[ve][pfam] = count
        count_sum += count
      end
      vhash[ve].each do |p,c|
        vhash[ve][p] = (vhash[ve][p] / count_sum).to_f #relative proportion
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
    CSV.open('/scratch/gi/coop/perner/metameta/stats/abundance/boxplot_temp_pfam.csv', 'w') do |csv|
      csv << ['pfam','freq']#uproc vs diamond
      topten_pfam.each do |pfam|
        phash[pfam].each do |v,p|
         csv << [pfam,p]
        end
      end
    end

    #write min max list
    CSV.open('/scratch/gi/coop/perner/metameta/stats/abundance/minmax_func.csv', 'w') do |csv|
      csv << ['pfam','min','min_vent','max','max_vent']
      topten_pfam.each do |pfam|
        csv << [pfam,ahash[pfam][:min][0],ahash[pfam][:min][1],ahash[pfam][:max][0],ahash[pfam][:max][1]]
      end
    end
          
    `Rscript R/boxplot.r /scratch/gi/coop/perner/metameta/stats/abundance/boxplot_temp_pfam.csv pfam /scratch/gi/coop/perner/metameta/stats/abundance/abundance_func.pdf`
    `rm /scratch/gi/coop/perner/metameta/stats/abundance/boxplot_temp_pfam.csv`  
  end
      
  def Downstream.topten_tax(vents)
      ['kingdom','phylum','class','order','family','genus','species'].each do |tax|
      vhash = Hash.new
      phash = Hash.new
      ahash = Hash.new
      
      vents.each do |vent|
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
  end
  
  # replace 'unknown unknown unknown blabla' with 'unknown blabla'
  def Downstream.fix_taxprof(vents)
    vents.each do |vent|
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
      hash = Hash.new(0.0)
      i = 0
      next if !File.exists?("#{vent}/profiles/taxonomic/Taxy/uproc_complete.csv") 
      File.open("#{vent}/profiles/taxonomic/Taxy/uproc_complete.csv").each do |line|
        line = line.split("\t")
        next if line[0] == '#frequency' || line[0] == 'frequency'
        a = line[1] =~ /Unknown/ ? "Unknown #{line[1].match(/(?![ Unknown ]).*/)}".chomp : line[1].chomp 
        b = line[2] =~ /Unknown/ ? "Unknown #{line[2].match(/(?![ Unknown ]).*/)}".chomp : line[2].chomp 
        c = line[3] =~ /Unknown/ ? "Unknown #{line[3].match(/(?![ Unknown ]).*/)}".chomp : line[3].chomp 
        d = line[4] =~ /Unknown/ ? "Unknown #{line[4].match(/(?![ Unknown ]).*/)}".chomp : line[4].chomp 
        e = line[5] =~ /Unknown/ ? "Unknown #{line[5].match(/(?![ Unknown ]).*/)}".chomp : line[5].chomp 
        f = line[6] =~ /Unknown/ ? "Unknown #{line[6].match(/(?![ Unknown ]).*/)}".chomp : line[6].chomp 
        g = line[7] =~ /Unknown/ ? "Unknown #{line[7].match(/(?![ Unknown ]).*/)}".chomp : line[7].chomp 
        freq = line[0]
        hash[i] = [freq,a,b,c,d,e,f,g]
        i += 1
      end
      CSV.open("#{vent}/profiles/taxonomic/Taxy/uproc_complete.csv", "w", :col_sep=>"\t") do |csv|
          csv << ['frequency','superkingdom','phylum','class','order','family','genus','species']
          hash.each do |i,arr|
            csv << [arr[0],arr[1],arr[2],arr[3],arr[4],arr[5],arr[6],arr[7]]                                                     
          end                                                       
        end
      
    end
  end
     
     
  def Downstream.funcprof_vs_funcprof(vents)
    prf1_hash = Hash.new
    prf2_hash = Hash.new

    prof1 = 'uproc'
    prof2 = 'diamond'

    vents.each do |vent| 
      prf1_sum = 0
      prf2_sum = 0
      puts vent
      dir1 = "#{vent}/profiles/functional/#{prof1}"
      dir2 = "#{vent}/profiles/functional/#{prof2}"
      if !File.exists?("#{dir1}/#{prof1}.txt") ||  !File.exists?("#{dir2}/#{prof2}.txt")
        puts "#{prof1} or #{prof2} profile file not found. Skipping #{File.basename(vent)}."
        next
      end
      prf1_hash = Hash.new
      prf2_hash = Hash.new
      
      File.open("#{dir1}/#{prof1}.txt").each_line do |line|
        line = line.split(',')
        next if line[0] == 'pfam'
        pfam = line[0].scan(/(PF\d\d\d\d\d)/)[0][0]
        count = line[1].chomp.to_i
        prf1_hash[pfam] = prf1_hash[pfam] == nil ? count : prf1_hash[pfam]+count
        prf1_sum += count
      end
        
      File.open("#{dir2}/#{prof2}.txt").each_line do |line|
        line = line.split(',')
        next if line[0] == 'pfam'
        pfam = line[0].scan(/(PF\d\d\d\d\d)/)[0][0]
        count = line[1].chomp.to_i
        prf2_hash[pfam] = prf2_hash[pfam] == nil ? count : prf2_hash[pfam]+count
        prf2_sum += count
      end
     
      pairs_hash = Hash.new 
      prf1_hash.each do |pfam,count|
        prf2_count = prf2_hash.has_key?(pfam) ? prf2_hash[pfam] : 0
        pairs_hash[pfam] = [count,prf2_count]
      end
      prf2_hash.each do |pfam,count|
        prf1_count = prf1_hash.has_key?(pfam) ? prf1_hash[pfam] : 0
        pairs_hash[pfam] = [prf1_count,count]
      end
      
      CSV.open("#{vent}/profiles/functional/#{File.basename(vent)}_#{prof1}_vs_#{prof2}.csv", "w") do |csv|
        csv << [prof1,prof2]
        pairs_hash.each do |pfam,counts_arr|
          if counts_arr[0] != 0 && counts_arr[1] != 0 && counts_arr[0] != {} && counts_arr[1] != {} 
            csv << [counts_arr[0],counts_arr[1]]             
          end
        end                                                       
      end

      `Rscript R/corr.r "#{vent}/profiles/functional/#{File.basename(vent)}_#{prof1}_vs_#{prof2}.csv" "UProC vs Diamond" "#Klassifizierungen - #{prof1}" "#Klassifizierungen - #{prof2}" "#{vent}/profiles/functional/#{File.basename(vent)}_uproc_vs_diamond.pdf"`

    end
  end
  
  def Downstream.pfam2go(vent,go,summary,out)
    pfams = []
    File.open("data/pfam2go.txt").each_line do |line|
      next if line[0] == !
      l = line.split(">")
      if l[1] =~ /#{go}/ #GO:0004803 -> transposase activity
        pfams.push(l[0].split(" ")[0].split(":")[1])
      end
    end
    pfam_arr = []
    hash = Hash.new
    
    profiles_dir = "#{vent}/profiles/functional/uproc"
    ve = File.basename(vent)
    row_arr = [ve]
    uproc_file = "#{profiles_dir}/uproc_desc.txt"
    if !File.exists?(uproc_file)
      STDERR.puts "#{uproc_file} not found."
      exit 1
    end
    if !File.exists?("#{summary}/classification_summary_uproc.csv")
      STDERR.puts "#{summary}/classification_summary_uproc.csv not found."
      exit 1
    end
    total_classified = 0
    File.open("#{summary}/classification_summary_uproc.csv").each_line do |li|
      li = li.split(",")
      next if li[0] != ve
      total_classified = li[1]
      break
    end
    File.open(uproc_file).each_line do |line|
      l = line.split(',')
      next if l[0] == 'pfam'
      pfam_id = l[0]
      counts = l[1].chomp
      if pfams.include?(pfam_id.scan(/(PF\d\d\d\d\d)/)[0][0])
        perc = (counts.to_f*100/total_classified.to_f).to_f
        hash[pfam_id] = perc
      end
    end

    CSV.open("pfam2go_temp.csv", 'w') do |csv|
      csv << ['pfam','perc']
      hash.each do |pfam,perc|
        csv << [pfam,perc]
      end
    end
    
    `Rscript R/pfam2go.r pfam2go_temp.csv #{out} #{go}`
    `rm pfam2go_temp.csv`
    
  end
      
      
  
end



