require 'zlib'
require 'csv'

module Profiling
  
  def Profiling.func_prof_uproc(run,length,profiles_dir)
   run_nr = File.basename(run.sub('.fastq.gz',''))
   #`uproc-dna -f -P 2 -c #{length} data/pfam27_uproc data/model #{run} > #{profiles_dir}/#{run_nr}_uproc_lessrestricitve.txt`
   #`uproc-dna -p #{length} #{Paths.pfam27_uproc} #{Paths.model_uproc} #{run} > #{profiles_dir}/#{run_nr}_uproc_all.txt`
  `uproc-dna -fc #{length} data/pfam27_uproc data/model #{run} > #{profiles_dir}/#{run_nr}_uproc.txt`
  end
  
  def Profiling.func_prof_diamond(vent)
    summary = nil
    raw_reads = "#{vent}/raw_reads"
    prepro_reads = "#{vent}/preprocessed_reads"
    profiles_dir = "#{vent}/profiles/functional/diamond"
    #   `mkdir #{prepro_reads}/temp`
    `mkdir #{profiles_dir}` if !File.directory?(profiles_dir)
    Dir.glob("#{prepro_reads}/*fastq.gz") do |run|  
      run_nr = File.basename(run.sub('.fastq.gz',''))
      #next if File.exists?("#{profiles_dir}/#{run_nr}_matches.tab")
      `diamond blastx -d /scratch/gi/coop/perner/metameta/pfam27 -q #{run} -a #{profiles_dir}/#{run_nr}_matches`# -t #{prepro_reads}/temp`
      `diamond view -a #{vent}/profiles/functional/diamond/#{run_nr}_matches -o #{profiles_dir}/#{run_nr}_matches.tab --compress 1 -f tab`
      `rm -f #{profiles_dir}/*.daa`
    end

    class_count = 0 
    pfam_hash = Hash.new(0)
    Dir.glob("#{profiles_dir}/*.tab.gz") do |matches|  
      run_nr = File.basename(matches.sub('_matches.tab.gz',''))
      puts run_nr
      infile = open(matches)
      gz = Zlib::GzipReader.new(infile)
      old_id = ''
      gz.each_line do |line|
	      l = line.split("\t")
	      curr_id = l[0]
	      if old_id != curr_id
	        class_count += 1 
	        pfam = l[1].scan(/(PF\d\d\d\d\d)/)[0][0]
	        pfam_hash[pfam] += 1
	      end
	      old_id = curr_id
      end
      infile.close
    end
      
    puts "classified: #{class_count}"
    pfam_sorted = pfam_hash.sort_by {|key, value| -value}

    CSV.open("#{profiles_dir}/diamond.txt", 'w') do |csv| 
      csv << [class_count,0,0]
      pfam_sorted.each do |i|
        csv << [i[0],i[1]]
      end
    end
    
    summary = self.combine(profiles_dir,'diamond')
    #`rm -f #{profiles_dir}/*.tab.gz`

    summary
  end
   
  def Profiling.tax_prof_taxypro(profiles_dir,length)
    `octave /work/gi/software/taxy-pro/taxy_script.m #{profiles_dir}/uproc.txt #{length}`
  end
  
  def Profiling.write_classification_summary(summary,method,output)
    if !File.exists?("#{output}/classification_summary_#{method}.csv")
      CSV.open("stats/classification_summary.csv", 'w') do |csv|
	      csv << ['vent','classified','unclassified','total']
      end
    end

    CSV.open("#{output}/classification_summary_#{method}.csv", 'a') do |csv|
      summary.each do |vent,s|
	      csv << [File.basename(vent),s[:classified],s[:unclassified],s[:total]]
      end
    end
  end
   
  def Profiling.combine(profiles_dir,out)
    profile = Hash.new
    classification_summary = Hash.new
    classification_summary[:classified] = 0 
    classification_summary[:unclassified] = 0 
    classification_summary[:total] = 0 
    Dir.glob("#{profiles_dir}/*_#{out}.txt") do |file| 
      File.open(file).each_line do |line|
	      l = line.split(',')
	      if l.size == 3
	        classification_summary[:classified] += l[0].chomp.to_i
	        classification_summary[:unclassified] += l[1].chomp.to_i
	        classification_summary[:total] += l[2].chomp.to_i
	      else
	        fam = l[0]
	        freq = l[1].chomp.to_i
	        profile[fam] = 0 if profile[fam] == nil
	        profile[fam] += freq
	      end
      end    
    end
    
    profile = profile.sort_by{|k, v| v}.reverse
    
    #TODO load pfamaclans into memory (hash) instead of grepping
    CSV.open("#{profiles_dir}/#{out}.txt", 'w') do |csv|
      csv << ['pfam','count']
      profile.each do |fam,freq|
        #pfam_desc = `grep #{fam} data/Pfam-A.clans.tsv | cut -f 5`.chomp
        #pfam_desc = pfam_desc.length > 30 ? "#{pfam_desc[0..30]}..." : pfam_desc
        #f.puts "#{pfam_desc.gsub(',',' ')}(#{fam}),#{freq}"
	      csv << [fam,freq]
      end
    end
    
    return classification_summary
  end
	  
end
