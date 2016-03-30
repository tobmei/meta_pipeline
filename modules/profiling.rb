require 'zlib'


module Profiling
  
  def Profiling.func_prof_uproc(run,length,profiles_dir)
       run_nr = File.basename(run.sub('.fastq.gz',''))
#     `uproc-dna -f -P 2 -c #{length} data/pfam27_uproc data/model #{run} > #{profiles_dir}/#{run_nr}_uproc_lessrestricitve.txt`
#     `uproc-dna -p #{length} #{Paths.pfam27_uproc} #{Paths.model_uproc} #{run} > #{profiles_dir}/#{run_nr}_uproc_all.txt`
      `uproc-dna -fc #{length} data/pfam27_uproc data/model #{run} > #{profiles_dir}/#{run_nr}_uproc.txt`
  end
  
  def Profiling.func_prof_diamond(run,profiles_dir)
     run_nr = File.basename(run.sub('.fastq.gz',''))
    `diamond blastx -d /scratch/gi/coop/perner/metameta/pfam27 -q #{run} -a #{profiles_dir}/#{run_nr}_matches`# -t #{prepro_reads}/temp`
    `diamond view -a #{vent}/profiles/functional/diamond/#{run_nr}_matches -o #{profiles_dir}/#{run_nr}_matches.tab --compress 1 -f tab`
    `rm -f #{vent}/profiles/functional/diamond/*.daa`
  
    Dir.glob("#{profiles_dir}/*.tab.gz") do |matches|  
      run_nr = File.basename(matches.sub('_matches.tab.gz',''))
      puts run_nr
      infile = open(matches)
      gz = Zlib::GzipReader.new(infile)
      class_count = 0 
      pfam_hash = Hash.new
      old_id = ''
      gz.each_line do |line|
	l = line.split("\t")
	curr_id = l[0]
	  if old_id != curr_id
	  class_count += 1 
	  pfam = l[1].scan(/(PF\d\d\d\d\d)/)[0][0]
	  pfam_hash[pfam] = pfam_hash[pfam] == nil ? 1 : pfam_hash[pfam]+1
	end
	old_id = curr_id
      end
      
      puts "classified: #{class_count}"
      pfam_sorted = pfam_hash.sort_by {|key, value| -value}

      CSV.open("#{profiles_dir}/#{run_nr}_diamond.txt", 'w') do |csv| 
        pfam_sorted.each do |i|
          csv << [i[0],i[1]]
        end
      end
    
      infile.close
   end
   
   def Profiling.tax_prof_taxypro(profiles_dir,length)
     `octave /work/gi/software/taxy-pro/taxy_script.m #{profiles_dir}/uproc.txt #{length}`
   end
   
   def Profiling.write_classification_summary(summary)
     if !File.exists?("stats/classification_summary.csv")
       CSV.open("stats/classification_summary.csv", 'w') do |csv|
	 csv << ['vent','classified','unclassified','total']
       end
     end
  
     CSV.open("stats/classification_summary.csv", 'a') do |csv|
       summary.each do |vent,s|
         csv << [File.basename(vent),s[:classified],s[:unclassified],s[:total]]
       end
     end
   end
	       
