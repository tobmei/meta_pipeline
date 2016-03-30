require 'csv'
# python commandLine.py --typeOfTest 'Two samples' --profile /work/gi/coop/perner/metameta/meta_pipeline/funcprof.tsv --name1 anantharaman_abe_1_1 --name2 anantharaman_abe_2_2 --statTest "Fisher's exact test" --CI "DP: Newcombe-Wilson" --outputTable /work/gi/coop/perner/metameta/meta_pipeline/results_desc.tsv
# python commandLine.py --typeOfTest "Two groups" --profile /work/gi/coop/perner/metameta/meta_pipeline/funcprof.tsv --metadata /work/gi/coop/perner/metameta/meta_pipeline/stats/vents.csv --field platform --name1 454 --name2 illumina --statTest "t-test (equal variance)" --CI "DP: t-test inverted" --outputTable /work/gi/coop/perner/metameta/meta_pipeline/results_two.tsv
# python /work/gi/software/stamp-2.0.1/commandLine.py --typeOfTest 'Multiple groups' --profile /scratch/gi/coop/perner/metameta/stats/profiles/functional_profile.csv --metadata /scratch/gi/coop/perner/metameta/stats/vents_meta.tsv --field platform --statTest 'ANOVA' --outputTable ./stamp_result_temp.tsv

module Stamp
  
  def Stamp.run(profile,metadata,field,out)
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
      
  
  
  def Stamp.stamp_call(profile,metadata,field,out_dir)
    output = `python /work/gi/software/stamp-2.0.1/commandLine.py --typeOfTest 'Multiple groups' --profile #{profile} --metadata #{metadata} --field #{field} --statTest 'ANOVA' --outputTable #{out_dir}/stamp_result_temp.tsv`
    puts output
    if $?.exitstatus != 0
      STDERR.puts 'Error while running stamp'
      exit 1
    end
  end
  
  def Stamp.stamp_parser(stamp_file,metadata,group,out,profile)
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
  

  
end




