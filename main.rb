require_relative 'fastqc_analysis'
require_relative 'preprocess'
require_relative 'modules/helper'
require_relative 'modules/preprocess_summary'
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
    `mkdir #{vent}/profiles/functional`
    `mkdir #{vent}/profiles/taxonomic`
    prepro_reads = "#{vent}/preprocessed_reads"
    profiles_dir = "#{vent}/profiles/functional/uproc"
    taxy_dir = "#{vent}/profiles/taxonomic/Taxy"
   # next if !File.exists?("#{profiles_dir}/diamond.txt") 
    `mkdir #{profiles_dir}` if !Dir.exists?(profiles_dir)
    `mkdir #{taxy_dir}`if !Dir.exists?(taxy_dir)

    #run uproc
    Dir.glob("#{prepro_reads}/*fastq.gz") do |run|  
      run_nr = File.basename(run.sub('.fastq.gz',''))
      puts "processing #{run_nr}: uproc"
      length = summary_file[File.basename(vent)].to_i <= 200 ? '-s' : '-l'
      puts length
#     `uproc-dna -f -P 2 -c #{length} data/pfam27_uproc data/model #{run} > #{profiles_dir}/#{run_nr}_uproc_lessrestricitve.txt`
#     `uproc-dna -p #{length} #{Paths.pfam27_uproc} #{Paths.model_uproc} #{run} > #{profiles_dir}/#{run_nr}_uproc_all.txt`
      `uproc-dna -fc #{length} data/pfam27_uproc data/model #{run} > #{profiles_dir}/#{run_nr}_uproc.txt` 
    end
    summary = combine(profiles_dir,'uproc')
    classification_summary[vent] = summary  
  end
  
  #write classification summary to file
  if !File.exists?("stats/classification_summary.csv")
    File.open("stats/classification_summary.csv", 'w') { |f|
      f.puts "vent,classified,unclassified,total"
    }
  end
  
  File.open("stats/classification_summary.csv", 'a') { |f|
    classification_summary.each do |vent,s|
      f.print "#{File.basename(vent)},"
      f.print "#{s[:classified]},"
      f.print "#{s[:unclassified]},"
      f.puts "#{s[:total]}"
    end
  }
  #end

  #run taxy-pro
  ARGV.each do |vent|
    profiles_dir = "#{vent}/profiles/functional/uproc"
    next if !File.exists?("#{profiles_dir}/uproc.txt")
    puts "processing taxy-pro for #{vent}"
    length = summary_file[File.basename(vent)].to_i <= 200 ? 'S' : 'L'
    puts length
    `octave /work/gi/software/taxy-pro/taxy_script.m #{profiles_dir}/uproc.txt #{length}`
  end
  
  
  #downstream analysis
  
  
  
  
end


