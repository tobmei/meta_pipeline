require_relative 'preprocess'
require_relative 'modules/helper'
require_relative 'modules/preprocess_summary'
require_relative 'modules/downstream'
require_relative 'modules/profiling'
require_relative 'modules/fastqc_analysis'
require 'optparse'

options = {}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: main.rb (-p|--no-preprocessing) (-c|--no-classification) (-d|--no-downstream) -o <path to options.tsv and vents_meta.tsv> <input_directory> ..."
  opts.on("-p", "--[no-]preprocessing", "Perform preprocessing steps") do |p|
    options[:preprocessing] = p
  end
  opts.on("-c", "--[no-]classification", "Perform functional annotation") do |c|
    options[:classification] = c
  end
  opts.on("-d", "--[no-]downstream", "Perform downstream analysis") do |d|
    options[:downstream] = d
  end
  opts.on("-o", "--statout out", "Output and path to options.tsv and vents_meta.tsv.") do |out|
    options[:output] = out
  end
  opts.on('-h', '--help', 'Displays Help') do
    puts opts
    exit 0
  end
end
parser.parse!

if ARGV.size == 0
  puts parser.banner
  exit 0
end

if options[:output] == nil 
  raise OptionParser::MissingArgument, '-o'
  exit 1
end

if !File.exist?("#{options[:output]}/options.tsv") || !File.exist?("#{options[:output]}/vents_meta.tsv") 
  STDERR.puts "ERROR: File #{options[:output]}/options.tsv or #{options[:output]}/vents_meta.tsv does not exist."
  exit 1
end


#parse options file
init_file = Helper.parse_init_file("#{options[:output]}/options.tsv")

#check for each vent in <input_dir> if it exists in options file
#print init_file
ARGV.each do |vent|
  if !Dir.exists?(vent)
    STDERR.puts "ERROR: Directory #{vent} does not exist."
    exit 1
  end
  if !init_file.has_key?(File.basename(vent))
    STDERR.puts "ERROR: vent #{vent} not found in init_file"
    exit 1
  end
  if !Dir.exists?("#{vent}/raw_reads")
    STDERR.puts "Directory #{vent}/raw_reads not found"
    exit 1
  end
end
 
 
 
###################
###preprocessing###
###################

if options[:preprocessing]
  
  puts "-------------"
  puts "preprocessing"
  puts "-------------"

  ARGV.each do |vent|
    fastqc_summary = Hash.new
    raw_reads = "#{vent}/raw_reads"
    prepro_reads = "#{vent}/preprocessed_reads"
    
    `mkdir #{prepro_reads}` if !File.directory?(prepro_reads)
    puts "\n\nvent: #{File.basename(vent)}"
    #perform preprocessing steps on raw reads
    Dir.glob("#{raw_reads}/*fastq.gz") do |run|  
      run_nr = File.basename(run.sub('.fastq.gz',''))
      next if run_nr =~ /_2\z/
      pe = run_nr =~ /_1\z/ ? true : false
      Preprocess.process(run, raw_reads, prepro_reads, pe, init_file[File.basename(vent)])
    end
    
    #run fastqc on raw reads
    Dir.glob("#{raw_reads}/*fastq.gz") do |run|  
      run_nr = File.basename(run.sub('.fastq.gz',''))
      puts "fastqc on raw reads for #{run_nr}"
      fastqc_summary = Fastqc_analysis.run(run)
    end
    
    #run fastqc on preprocessed reads
    Dir.glob("#{prepro_reads}/*fastq.gz") do |run|  
      run_nr = File.basename(run.sub('.fastq.gz',''))
      puts "fastqc on preprocessed reads for #{run_nr}"
      fastqc_summary = Fastqc_analysis.run(run)
    end
  end
  
#   create preprocessing summary
  Preprocess_summary.summary(ARGV,options[:output])
  
end



####################
###classification###
####################

if options[:classification]

  puts "--------------"
  puts "classification"
  puts "--------------"
  
  if !File.exists?("stats/preprocess_summary.csv")
    STDERR.puts 'No preprocess summary file created after preprocessing. This is not good.'
    exit 1
  end

  summary_file = Helper.parse_summary_file("#{options[:output]}/preprocess_summary.csv")
  
  pfam_desc_hash = Hash.new
  File.open('data/Pfam-A.clans.tsv').each do |line|
    line = line.split("\t")
    desc = line[4].chomp
    desc = desc.length > 25 ? "#{desc[0..22]}..." : desc
    pfam_id = line[0]
    pfam_desc_hash[pfam_id] = desc
  end
  
  classification_summary = Hash.new  
  ARGV.each do |vent|
    `mkdir #{vent}/profiles` if !Dir.exists?("#{vent}/profiles")
    `mkdir #{vent}/profiles/functional` if !Dir.exists?("#{vent}/profiles/functional")
    `mkdir #{vent}/profiles/taxonomic` if !Dir.exists?("#{vent}/profiles/taxonomic")
    prepro_reads = "#{vent}/preprocessed_reads"
    profiles_dir = "#{vent}/profiles/functional/uproc"
    taxy_dir = "#{vent}/profiles/taxonomic/"
    `mkdir #{profiles_dir}` if !Dir.exists?(profiles_dir)
    `mkdir #{taxy_dir}`if !Dir.exists?(taxy_dir)

    #run uproc
    puts "run uproc for #{File.basename(vent)}"
    Dir.glob("#{prepro_reads}/*fastq.gz") do |run|
      run_nr = File.basename(run.sub('.fastq.gz',''))
      length = summary_file[File.basename(vent)].to_i <= 200 ? '-s' : '-l'
      puts "#{run_nr} - length option: #{length}"
      Profiling.func_prof_uproc(run,length,profiles_dir)
    end
    summary = Profiling.combine(profiles_dir,'uproc',pfam_desc_hash)
    classification_summary[vent] = summary  
    classification_summary[vent] = Profiling.func_prof_diamond(vent)
  end
  
  #write classification summary to file
  Profiling.write_classification_summary(classification_summary,'uproc',options[:output])

  #run taxy-pro
  ARGV.each do |vent|
    puts "run taxy-pro for #{File.basename(vent)}"
    profiles_dir = "#{vent}/profiles/functional/uproc"
    if !File.exists?("#{profiles_dir}/uproc.txt")
      puts "Functional profile #{profiles_dir}/uproc.txt not found. Skipping data #{vent}"
      next
    end
    length = summary_file[File.basename(vent)].to_i <= 200 ? 'S' : 'L'
    puts "length option: #{length}"
    Profiling.tax_prof_taxypro(profiles_dir,length)
    `mv #{profiles_dir}/uproc_Taxy/ #{vent}/profiles/taxonomic/`
    `rm -rf #{vent}/profiles/taxonomic/Taxy` if Dir.exists?("#{vent}/profiles/taxonomic/Taxy")
    `mv #{vent}/profiles/taxonomic/uproc_Taxy/ #{vent}/profiles/taxonomic/Taxy`
  end
  Downstream.fix_taxprof(ARGV)
  
end


#########################
###downstream analysis###
#########################

if options[:downstream]

  puts "------------------"
  puts "downstream analyis"
  puts "------------------"

  #uproc vs diamond
  puts "uproc vs diamond ..."
  Downstream.funcprof_vs_funcprof(ARGV)

  #pfam2go and bar plots for taxonomy and function
  ARGV.each do |vent|
  v = File.basename(vent)
  init_file[v][:pfam2go].split(',').each do |go|
    puts "pfam2go for #{v} with #{go}..."
    Downstream.pfam2go(vent,go,options[:output],"#{vent}/profiles/#{v}_pfam2go_#{go}.pdf")
  end
  tax_file = "#{vent}/profiles/taxonomic/Taxy/uproc_complete.csv"
  func_file = "#{vent}/profiles/functional/uproc/uproc.txt"
  if !File.exists?(tax_file) || !File.exists?(func_file)
    puts "Profile file not found for vent #{vent}. Skipping this one."
    next
  end
  puts "functional and taxonomic abundances for #{vent} ..."
  `Rscript R/abundance.r #{tax_file} #{func_file} #{vent}/profiles/taxonomic/Taxy/#{v} #{vent}/profiles/functional/uproc/#{v} `
  end

  out = options[:output] == nil ? '.' : options[:output] 
  `mkdir #{options[:output]}/ordination` if !Dir.exists?("#{out}/ordination")
  `mkdir #{options[:output]}/profiles` if !Dir.exists?("#{out}/profiles")
  vents_path = File.dirname(ARGV[0])
                                                      
  #accumulate profiles of all metagenomes
  puts "generate complete functional profile ..."
  Downstream.generate_functional_profile_matrix(Dir["#{vents_path}/*"],"#{out}/profiles")
  puts "generate complete taxonomic profile ..."
  Downstream.generate_taxonomic_profile_matrix(Dir["#{vents_path}/*"],"#{out}/profiles")
  cats = Downstream.get_anosim_categories("#{out}/vents_meta.tsv")

  #plots, anosim, etc for all datasets
  funcprof_file = "#{out}/profiles/functional_profile.csv"
  taxprof_file = "#{out}/profiles/taxonomic_profile_species_level.csv"
  funcprof_file_stamp = "#{out}/profiles/functional_profile_stamp_compatible.csv"
  taxprof_file_stamp = "#{out}/profiles/taxonomic_profile_species_level_stamp.csv"
  [funcprof_file,taxprof_file,funcprof_file_stamp,taxprof_file_stamp].each do |file|
    if !File.exists?(file)
      STDERR.puts "File #{file} not found. There was propably an error while generating it. This is not good."
      exit 1
    end
  end
  puts "pcoa and nmds ordination for functional profile ..."
  `Rscript R/ordination.r #{funcprof_file} #{out}/vents_meta.tsv #{out}/ordination/functional_profile_`
  puts "pcoa and nmds ordination for taxonomic profile ..."
  `Rscript R/ordination.r #{taxprof_file} #{out}/vents_meta.tsv #{out}/ordination/taxonomic_profile_`

  anosim_arr1 = []
  anosim_arr2 = []
  if cats.size == 0
    puts "Could not find any ANOSIM categories with >=5 entries"
  else
    `mkdir #{options[:output]}/anosim` if !Dir.exists?("#{out}/anosim")
    cats.each do |cat|
      puts "ANOSIM functional profile for category #{cat} ..."
      result1 = `Rscript R/anosim.r #{taxprof_file} /scratch/gi/coop/perner/metameta/stats/vents_meta.tsv #{cat}`
      puts "ANOSIM taxonomic profile for category #{cat} ..."
      result2 = `Rscript R/anosim.r #{funcprof_file} /scratch/gi/coop/perner/metameta/stats/vents_meta.tsv #{cat}`
      anosim_arr1.push(result1)
      anosim_arr2.push(result2)
    end
    Downstream.write_anosim_results(anosim_arr1,"#{out}/anosim/taxonomic_profile_")
    Downstream.write_anosim_results(anosim_arr2,"#{out}/anosim/functional_profile_")

    #stamp
    `mkdir #{options[:output]}/stamp` if !Dir.exists?("#{out}/stamp")
    cats.each do |cat|
      puts "STAMP analysis for functional profile with #{cat} ..."
      Downstream.stamp_run(funcprof_file_stamp,"#{out}/vents_meta_stamp.tsv",cat,"#{out}/stamp/stamp_funcprof_#{cat}.pdf")
      puts "STAMP analysis for taxonomic profile with #{cat} ..."
      Downstream.stamp_run(taxprof_file_stamp,"#{out}/vents_meta_stamp.tsv",cat,"#{out}/stamp/stamp_taxprof_#{cat}.pdf")
    end
  end

end

















