require_relative 'fastqc_analysis'
require_relative 'preprocess'
require_relative 'modules/helper'
require_relative 'modules/preprocess_summary'
require_relative 'modules/downstream_helper'
require_relative 'modules/stamp'
require_relative 'modules/profiling'
require_relative 'combine_functional_profiles'
require 'optparse'

options = {}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options] <input_directory> ..."
  opts.on('-i', '--init init', 'Init file') do |init|
    options[:init] = init
  end
  opts.on("-p", "--[no-]preprocessing", "Perform preprocessing steps") do |p|
    options[:preprocessing] = p
  end
  opts.on("-c", "--[no-]classification", "Perform protein sequence classification") do |c|
    options[:classification] = c
  end
  opts.on("-o", "--statout", "Output folder for accumulated profiles, plots, etc.") do |o|
    options[:output] = o
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

if options[:init] == nil 
  raise OptionParser::MissingArgument, '-i init_file'
  exit 1
end

if options[:init] != nil && !File.exist?(options[:init]) 
  STDERR.puts "ERROR: File #{options[:init]} does not exist."
  exit 1
end


#parse init file
init_file = Helper.parse_init_file(options[:init])

#check for each vent in init file if it exists in <input_dir> and if raw reads are in FASTQ format
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
#TODO FastQ validator  
end
 
 
if options[:preprocessing]

  ARGV.each do |vent|
    fastqc_summary = Hash.new
    raw_reads = "#{vent}/raw_reads"
    prepro_reads = "#{vent}/preprocessed_reads"
    
    `mkdir #{prepro_reads}` if !File.directory?(prepro_reads)
  
    #run fastqc on raw reads
    Dir.glob("#{raw_reads}/*fastq.gz") do |run|  
      run_nr = File.basename(run.sub('.fastq.gz',''))
      puts "processing #{run_nr}: fastqc"
     fastqc_summary = Fastqc_analysis.run(run)
    end

    #perform preprocessing steps on raw reads
    Dir.glob("#{raw_reads}/*fastq.gz") do |run|  
      run_nr = File.basename(run.sub('.fastq.gz',''))
      next if run_nr =~ /_2\z/
      pe = run_nr =~ /_1\z/ ? true : false
      Preprocess.process(run, raw_reads, prepro_reads, pe, init_file[File.basename(vent)])
    end
    
    #run fastqc on preprocessed reads
    Dir.glob("#{prepro_reads}/*fastq.gz") do |run|  
      run_nr = File.basename(run.sub('.fastq.gz',''))
      puts "processing #{run_nr}: fastqc"
      fastqc_summary = Fastqc_analysis.run(run)
    end
  end
  
#   create preprocessing summary
  Preprocess_summary.summary(ARGV)
  
end


if options[:classification]

  if !File.exists?("stats/preprocess_summary.csv")
    STDERR.puts 'No preprocess summary file found'
    exit 1
  end

  summary_file = Helper.parse_summary_file("stats/preprocess_summary.csv")
  
  classification_summary = Hash.new  
  ARGV.each do |vent|
    `mkdir #{vent}/profiles` if !Dir.exists?("#{vent}/profiles")
    #`mkdir #{vent}/profiles/functional`
    #`mkdir #{vent}/profiles/taxonomic`
    prepro_reads = "#{vent}/preprocessed_reads"
    profiles_dir = "#{vent}/profiles/functional/uproc"
    taxy_dir = "#{vent}/profiles/taxonomic/Taxy"
    `mkdir #{profiles_dir}` if !Dir.exists?(profiles_dir)
    `mkdir #{taxy_dir}`if !Dir.exists?(taxy_dir)

    #run uproc
    Dir.glob("#{prepro_reads}/*fastq.gz") do |run| 
      run_nr = File.basename(run.sub('.fastq.gz',''))
      puts "processing #{run_nr}: uproc"
      length = summary_file[File.basename(vent)].to_i <= 200 ? '-s' : '-l'
      puts "Uproc length option: #{length}"
      #Profiling.func_prof_uproc(run,length,profiles_dir)
    end
    summary = Profiling.combine(profiles_dir,'uproc')
    classification_summary[vent] = summary  
    #classification_summary[vent] = Profiling.func_prof_diamond(vent)
  end
  
  #write classification summary to file
  Profiling.write_classification_summary(classification_summary,'uproc','/scratch/gi/coop/perner/metameta/stats')

  #run taxy-pro
  ARGV.each do |vent|
    profiles_dir = "#{vent}/profiles/functional/uproc"
    if !File.exists?("#{profiles_dir}/uproc.txt")
      puts "Functional profile #{profiles_dir}/uproc.txt not found. Skipping data #{vent}"
      next
    end
    puts "processing taxy-pro for #{vent}"
    length = summary_file[File.basename(vent)].to_i <= 200 ? 'S' : 'L'
    puts "Taxy-pro length option: #{length}"
#     Profiling.tax_prof_taxypro(profiles_dir,length)
  end
  
end


#########################
###downstream analysis###
#########################


#bar plots for taxonomy and function
# ARGV.each do |vent|
#   v = File.basename(vent)
#   tax_file = "#{vent}/profiles/taxonomic/Taxy/complete.csv"
#   func_file = "#{vent}/profiles/functional/uproc/uproc.txt"
#   if !File.exists?(tax_file) || !File.exists?(func_file)
#     puts "Profile file not found. Skipping this one."
#     next
#   end
#   `Rscript R/taxonomy.r #{tax_file} #{func_file} #{vent}/profiles/taxonomic/Taxy/#{v} #{vent}/profiles/functional/uproc/#{v} `
# end
# 
# out = options[:output] == nil ? '.' : options[:output] 
# `mkdir #{options[:output]}/plots` if !Dir.exists?("#{out}/plots")
# `mkdir #{options[:output]}/profiles` if !Dir.exists?("#{out}/profiles")
# `mkdir #{options[:output]}/stamp` if !Dir.exists?("#{out}/stamp")
# vents_path = File.dirname(ARGV[0])
#                                                      
# #accumulate profiles of all metagenomes
# Downstream_helper.generate_functional_profile_matrix(Dir["#{vents_path}/*"],"#{out}/profiles")
# Downstream_helper.generate_taxonomic_profile_matrix(Dir["#{vents_path}/*"],"#{out}/profiles")
# cats = Downstream_helper.get_anosim_categories("#{out}/vents_meta.tsv")
# 
# #plots, anosim, etc for all datasets
# funcprof_file = "#{out}/profiles/functional_profile.csv"
# taxprof_file = "#{out}/profiles/taxonomic_profile_species_level.csv"
# funcprof_file_stamp = "#{out}/profiles/functional_profile_stamp_compatible.csv"
# taxprof_file_stamp = "#{out}/profiles/taxonomic_profile_species_level_stamp.csv"
# [funcprof_file,taxprof_file,funcprof_file_stamp,taxprof_file_stamp].each do |file|
#   if !File.exists?(file)
#     STDERR.puts "File #{file} not found. There was propably an error while generating it. This is not good."
#     exit 1
#   end
# end
# 
# `Rscript R/ordination.r #{funcprof_file} #{out}/vents_meta.tsv #{out}/plots/functional_profile_`
# `Rscript R/ordination.r #{taxprof_file} #{out}/vents_meta.tsv #{out}/plots/taxonomic_profile_`
# 
# anosim_arr1 = []
# anosim_arr2 = []
# cats.each do |cat|
#   result1 = `Rscript R/anosim.r #{taxprof_file} /scratch/gi/coop/perner/metameta/stats/vents_meta.tsv #{cat}`
#   result2 = `Rscript R/anosim.r #{funcprof_file} /scratch/gi/coop/perner/metameta/stats/vents_meta.tsv #{cat}`
#   anosim_arr1.push(result1)
#   anosim_arr2.push(result2)
# end
# Downstream_helper.write_anosim_results(anosim_arr1,"#{out}/taxonomic_profile_")
# Downstream_helper.write_anosim_results(anosim_arr2,"#{out}/functional_profile_")
# 
# 
# #stamp
# cats.each do |cat|
#   Stamp.run(funcprof_file_stamp,"#{out}/vents_meta.tsv",cat,"#{out}/stamp/stamp_funcprof_#{cat}.pdf")
#   Stamp.run(taxprof_file_stamp,"#{out}/vents_meta.tsv",cat,"#{out}/stamp/stamp_taxprof_#{cat}.pdf")
# end



















