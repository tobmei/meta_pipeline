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


# @vents = "/scratch/gi/coop/perner/metameta/vents"
# @scripts = "/work/gi/coop/perner/metameta/scripts"
# @fastqc = "/work/gi/software/fastqc-0.11.3/fastqc"
# @seqclean = "/work/gi/software/seqclean-x86_64/seqclean"
# @prinseq = "/work/gi/software/prinseq-lite-0.20.2/prinseq-lite.pl"
# @cln2qual = "/work/gi/software/seqclean-x86_64/cln2qual"
# @seqtk = "/work/gi/software/seqtk-git/seqtk"
# @genometools = "/work/gi/software/gt-1.5.3/bin/gt"
# @fasqual2fastq = "/work/gi/coop/perner/metameta/scripts/gg/fasqual2fastq"
# @fastq2fasqual = "/work/gi/coop/perner/metameta/scripts/gg/fastq2fasqual"
# @formatdb = "/work/gi/software/seqclean-x86_64/bin/formatdb"
# @host = "/work/gi/coop/perner/metameta/fosmids/Eco-DH10B.fna"
# @fosmid = "/work/gi/coop/perner/metameta/data/fosmids/pCC1FOS.fna"
# @bwa = "/work/gi/software/bwa-0.7.4/bwa"
# @vectordb = "/work/gi/coop/perner/metameta/data/univec/univec.fasta"
# @samtools ="/work/gi/software/samtools-1.2/samtools"
# @filter_seq_identity = "/work/gi/coop/perner/metameta/scripts/filter_seq_identity.rb"
# @tagcleaner = "/work/gi/software/tagcleaner-0.12/tagcleaner.pl"
# @trimmomatic = "/work/gi/software/trimmomatic-0.33/trimmomatic-0.33.jar"
# @run_tagclean = "/work/gi/coop/perner/metameta/scripts/run_tagclean.rb"
# @adapters = "/work/gi/coop/perner/metameta/data/adapters.fa"
# @bedtools = "/work/gi/software/bedtools-2.17.0/bin/bedtools"
# @delete_unpaired_reads = "/work/gi/coop/perner/metameta/scripts/delete_unpaired_reads.rb"
# @uproc = "/work/gi/software/uproc-1.2.0/"
# @pfam27_uproc = "/work/gi/coop/perner/metameta/data/pfam27_uproc"
# @model_uproc = "/work/gi/coop/perner/metameta/data/model"
# @taxy_pro = "/work/gi/software/taxy-pro"
# @sratoolkit = "~/tools/sratoolkit.2.5.4-1-ubuntu64/bin/"
# @data = "/work/gi/coop/perner/metameta/data"
# @diamond = "/work/gi/software/diamond-0.7.9/bin/diamond"