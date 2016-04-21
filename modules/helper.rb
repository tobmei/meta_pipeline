require 'mkmf'

module Helper
  
  def Helper.check_vents(path)
    new_vents = []
    Dir.foreach(path) do |vent|
      next if vent == '.' or vent == '..'
      new_vents.push(vent) if !Dir.exists?("#{path}/#{vent}/preprocessed_reads")
    end
    return new_vents
  end
  
  def Helper.check_requirements
    executables = ['fastqc','seqtk','prinseq-lite.pl','cln2qual','seqtk','gt','bwa','samtools',
                   'tagcleaner.pl','bedtools','uproc-dna','sra-dump','diamond','taxy_script.m']#,'trimmomatic-0.33.jar']
    check = true
    puts 'Looking for required executables...'
    executables.each do |exec|
      path = find_executable("#{exec}")
      check = false if !path
    end
    #delete log file
    `rm mkmf.log` if File.exists?('mkmf.log')
  
    if !check
      STDERR.puts "One or more executables couldn't be found. Aborting"
      exit 1
    else
      puts 'Success!'
    end
  end
  
  def Helper.parse_init_file(file)
    init = Hash.new
    File.open(file).each_line do |line|
      line = line.split("\t")
      next if line[0] == 'vent'
      vent = line[0].chomp
      platform = line[1].chomp
      fosmid_based = line[2].chomp
      adapter_seq = line[3].chomp
      if vent == nil || vent == '' || platform == nil || fosmid_based == nil || fosmid_based == ''
	      STDERR.puts "Error while parsing init file. Empty field detected"
	      exit 1
      end
      if adapter_seq != nil && adapter_seq != '' && (adapter_seq =~ /^[actgACTG]+$/) == nil
	      STDERR.puts "Error in init file. Nonvalid nucleotide sequence: #{adapter_seq}"
	      exit 1
      end
      init[vent] = Hash.new
      init[vent][:platform] = platform
      init[vent][:fosmid_based] = fosmid_based 
      init[vent][:adapter_seq] = adapter_seq
    end
    return init
  end
  
  def Helper.parse_summary_file(file)
    summary = Hash.new
    File.open(file).each_line do |line|
      line = line.split(",")
      next if line[0] == 'vent'
      vent = line[0].chomp
      avg_length = line[4].chomp
      if vent == nil || avg_length == nil || avg_length == ''
	      STDERR.puts "Error while parsing summary file. Empty field detected"
	      exit 1
      end
      summary[vent] = avg_length
    end
    return summary
  end
  
end

