require_relative 'fastqc_analysis'
require_relative 'preprocess'
require_relative 'prot_seq_classification'
require_relative 'modules/helper'
require 'optparse'

options = {}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options] <input_directory> ..."
  opts.on('-i', '--init init', 'Init file') do |meta|
    options[:meta] = meta
  end
  opts.on("-p", "--[no-]preprocessing", "Perform preprocessing steps") do |p|
    options[:preprocessing] = p
  end
  opts.on("-c", "--[no-]classification", "Perform protein sequence classification") do |c|
    options[:classification] = c
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

ARGV.each do |dir| 
  if !Dir.exists?(dir)
    STDERR.puts "ERROR: Directory #{dir} does not exist."
    exit 1
  end
end

#parse init file
init_file = Helper.parse_init_file(options[:init])

ARGV.each do |vent|
  fastqc_summary = Hash.new
  
  raw_reads = "#{vent}/raw_reads"
  prepro_reads = "#{vent}/preprocessed_reads"
  
  if options[:preprocessing]
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
      #next if File.exists?("#{prepro_reads}/#{run_nr}.fastq.gz")
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
  
  if options[:classification]
    profiles_dir = "#{vent}/profiles/functional/uproc"
    `mkdir #{profiles_dir}` if !File.directory?(profiles_dir)
    
    #run uproc
    Dir.glob("#{prepro_reads}/*fastq.gz") do |run|  
      run_nr = File.basename(run.sub('.fastq.gz',''))
#       next if File.exists?("#{profiles_dir}/#{run_nr}_uproc.txt")
      puts "processing #{run_nr}: uproc"
      Prot_seq_classification.classify(run, profiles_dir, init_file[File.basename(vent)])
    end
    profile_files_count = `ls #{profiles_dir}/*.txt | wc -l`.to_i
    if profile_files_count > 1
      `ruby combine_profiles.rb #{profiles_dir}/*.txt > #{profiles_dir}/uproc_combined.txt` if profile_files_count > 1
      `grep -E '.*,.*,.*' #{profiles_dir}/uproc_combined.txt > #{profiles_dir}/classification_count.txt`
      `grep -vE '.*,.*,.*' #{profiles_dir}/uproc_combined.txt > #{profiles_dir}/uproc_combined_new.txt`
      `rm -f #{profiles_dir}/uproc_combined.txt`
      `mv #{profiles_dir}/uproc_combined_new.txt #{profiles_dir}/uproc_combined.txt`
    else
      `grep -E '.*,.*,.*' #{profiles_dir}/*_uproc.txt > #{profiles_dir}/classification_count.txt`
      `grep -vE '.*,.*,.*' #{profiles_dir}/*_uproc.txt > #{profiles_dir}/new`
      `rm -f #{profiles_dir}/*_uproc.txt`
      `mv #{profiles_dir}/new #{profiles_dir}/uproc.txt`
    end
    run taxy-pro
    puts "processing taxy-pro for #{vent}"
    length = init_file[File.basename(vent)][:avg_length].to_i < 200 ? 'S' : 'L'
    puts length
    if File.exists?("#{profiles_dir}/uproc_combined.txt") 
      `octave #{Paths.taxy_pro}/taxy_script.m #{profiles_dir}/uproc_combined.txt #{length}`
    else
      `octave #{Paths.taxy_pro}/taxy_script.m #{profiles_dir}/uproc.txt #{length}`
    end
  end
  
  
end
