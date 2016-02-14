
module Preprocess
  def Preprocess.process(run, raw_reads, prepro_reads, pe, init_file)
    puts pe ? 'paired-end' : 'single-end'
#    if init_file == nil
#      puts "Warning: no matching vent found in meta file. Proceeding with default values"
#      init_file = {}
#      init_file[:fosmid] = 'n'
#      init_file[:adapter_seq] = ''
#    end
    puts "platform: #{init_file[:platform]}"
    puts "fosmid based: #{init_file[:fosmid_based]}"
    puts "adapter/tag sequence: #{init_file[:adapter_seq]}"
      
    run_nr = File.basename(run.sub('.fastq.gz',''))
    run_nr2 = pe ? "#{run_nr.match(/\D+\d+/)}_2" : ''
    
    if init_file[:platform] == 'illumina'
      puts "processing #{run_nr}: illumina adapter trimming"
      if pe
	execute("java -jar /work/gi/software/bin/trimmomatic-0.33.jar PE #{run} #{raw_reads}/#{run_nr2}.fastq.gz #{prepro_reads}/#{run_nr}_1p.fastq.gz #{prepro_reads}/#{run_nr}_1u.fastq.gz #{prepro_reads}/#{run_nr}_2p.fastq.gz #{prepro_reads}/#{run_nr}_2u.fastq.gz ILLUMINACLIP:data/adapters.fa:2:30:10:8:TRUE")
        execute("rm -f #{prepro_reads}/#{run_nr}_1u.fastq.gz")
        execute("rm -f #{prepro_reads}/#{run_nr}_2u.fastq.gz")
        execute("mv #{prepro_reads}/#{run_nr}_1p.fastq.gz #{prepro_reads}/#{run_nr}.fastq.gz")
        execute("mv #{prepro_reads}/#{run_nr}_2p.fastq.gz #{prepro_reads}/#{run_nr2}.fastq.gz")
      else
	execute("java -jar /work/gi/software/bin/trimmomatic-0.33.jar SE #{run} #{prepro_reads}/#{run_nr}.fastq.gz ILLUMINACLIP:data/adapters.fa:2:30:10:8:TRUE")
      end
    end
    
    puts "processing #{run_nr}: removing vector contamination"
    dir = init_file[:platform] == 'illumina' ? prepro_reads : raw_reads
    if pe
      execute("bwa mem -M data/univec #{dir}/#{run_nr}.fastq.gz  #{dir}/#{run_nr2}.fastq.gz | ruby filter_seq_identity.rb | samtools view -bh - | bedtools bamtofastq -i - -fq #{prepro_reads}/#{run_nr}_novector.fastq -fq2 #{prepro_reads}/#{run_nr2}_novector.fastq")
    else
      execute("bwa mem -M data/univec/univec.fasta #{dir}/#{run_nr}.fastq.gz | ruby filter_seq_identity.rb | samtools view -hbu - | samtools bam2fq - > #{prepro_reads}/#{run_nr}_novector.fastq")
    end
    execute("rm -f #{prepro_reads}/#{run_nr}.fastq.gz")
    execute("rm -f #{prepro_reads}/#{run_nr2}.fastq.gz") if pe    
    execute("mv #{prepro_reads}/#{run_nr}_novector.fastq #{prepro_reads}/#{run_nr}.fastq")
    execute("mv #{prepro_reads}/#{run_nr2}_novector.fastq #{prepro_reads}/#{run_nr2}.fastq") if pe
    
    
    puts "processing #{run_nr}: tag trimming"
    output = execute("perl /work/gi/software/bin/tagcleaner.pl -fastq #{prepro_reads}/#{run_nr}.fastq -predict | ruby run_tagclean.rb")
    puts output
    output = output.split("\n")
    tag1 = output[0] != nil ? "-#{output[0]}" : ''
    seq1 = output[1] != nil ? output[1] : ''
    tag2 = output[2] != nil ? "-#{output[2]}" : ''
    seq2 = output[3] != nil ? output[3] : ''
    if tag1 != ''
      execute("perl /work/gi/software/bin/tagcleaner.pl -fastq #{prepro_reads}/#{run_nr}.fastq #{tag1} #{seq1} #{tag2} #{seq2} -verbose -out #{prepro_reads}/#{run_nr}_tagclean")
      execute("rm -f #{prepro_reads}/#{run_nr}.fastq")
      execute("mv #{prepro_reads}/#{run_nr}_tagclean.fastq #{prepro_reads}/#{run_nr}.fastq")
    end
    if init_file[:adapter_seq] != ''
      execute("perl /work/gi/software/bin/tagcleaner.pl -fastq #{prepro_reads}/#{run_nr}.fastq #{init_file[:adapter_seq]} -verbose -out #{prepro_reads}/#{run_nr}_tagclean")
      execute("rm -f #{prepro_reads}/#{run_nr}.fastq")
      execute("mv #{prepro_reads}/#{run_nr}_tagclean.fastq #{prepro_reads}/#{run_nr}.fastq")
    end
    
    if pe
      puts "processing #{run_nr2}: tag trimming"
      output = execute("perl /work/gi/software/bin/tagcleaner.pl -fastq #{prepro_reads}/#{run_nr2}.fastq -predict | ruby run_tagcleaner.rb")
      puts output
      output = output.split("\n")
      tag1 = output[0] != nil ? "-#{output[0]}" : ''
      seq1 = output[1] != nil ? output[1] : ''
      tag2 = output[2] != nil ? "-#{output[2]}" : ''
      seq2 = output[3] != nil ? output[3] : ''
      if tag1 != ''
	execute("#{Paths.tagcleaner} -fastq #{prepro_reads}/#{run_nr2}.fastq #{tag1} #{seq1} #{tag2} #{seq2} -verbose -out #{prepro_reads}/#{run_nr2}_tagclean")
	execute("rm -f #{prepro_reads}/#{run_nr2}_novector.fastq")
        execute("mv #{prepro_reads}/#{run_nr2}_tagclean.fastq #{prepro_reads}/#{run_nr2}.fastq")
      end
      if init_file[:adapter_seq] != ''
	execute("#{Paths.tagcleaner} -fastq #{prepro_reads}/#{run_nr2}.fastq #{init_file[:adapter_seq]} -verbose -out #{prepro_reads}/#{run_nr2}_tagclean")
	execute("rm -f #{prepro_reads}/#{run_nr2}.fastq")
	execute("mv #{prepro_reads}/#{run_nr2}_tagclean.fastq #{prepro_reads}/#{run_nr2}.fastq")
      end
    end

    
    if init_file[:fosmid_based] == 'y'
      #run seqclean on processed reads. generates .fasta.clean (-> trimmed .fasta) and .cln (-> trimming report) 
      puts "processing #{run}: seqclean"
      execute("#{Paths.fastq2fasqual} #{prepro_reads}/#{run_nr}")
      execute("#{Paths.fastq2fasqual} #{prepro_reads}/#{run_nr2}") if pe
      execute("#{Paths.formatdb} -i #{Paths.host} -p F")
      if pe
	execute("#{Paths.seqclean} #{prepro_reads}/#{run_nr}.fna -s #{Paths.host} -v #{Paths.fosmid} -y 8 -N -M -A -L -l 0 -c 4 -r #{prepro_reads}/#{run_nr}.cln -o #{prepro_reads}/#{run_nr}.fasta.clean")
	execute("#{Paths.seqclean} #{prepro_reads}/#{run_nr2}.fna -s #{Paths.host} -v #{Paths.fosmid} -y 8 -N -M -A -L -l 0 -c 4 -r #{prepro_reads}/#{run_nr2}.cln -o #{prepro_reads}/#{run_nr2}.fasta.clean")
      else
	execute("#{Paths.seqclean} #{prepro_reads}/#{run_nr}.fna -s #{Paths.host} -v #{Paths.fosmid} -y 8 -N -M -A -L -l 0 -c 4 -r #{prepro_reads}/#{run_nr}.cln -o #{prepro_reads}/#{run_nr}.fasta.clean")
      end
      execute("rm -rf #{Paths.scripts}/*.cidx #{Paths.scripts}/*.sort #{Paths.scripts}/cleaning_* #{Paths.scripts}/*.log")
      
      #run cln2qual. generates .qual.clean from .cln and .qual (-> quality file without trimmed sequences)
      puts "processing #{run}: cln2qual"
      if !File.exist?("#{prepro_reads}/#{run_nr}.qual.clean")
	execute("#{Paths.cln2qual} #{prepro_reads}/#{run_nr2}.cln #{prepro_reads}/#{run_nr2}.qual") if pe
	execute("#{Paths.cln2qual} #{prepro_reads}/#{run_nr}.cln #{prepro_reads}/#{run_nr}.qual")
      end
      
      #run fasqual2fastq. generate .fastq from .clean and qual.clean 
      puts "processing #{run}: fasqual2fastq"
      #next if File.exist?("#{prepro_reads}/#{run_nr}.fastq.gz")
      execute("#{Paths.fasqual2fastq} #{prepro_reads}/#{run_nr2}.fasta.clean #{prepro_reads}/#{run_nr2}.qual.clean >  #{prepro_reads}/#{run_nr2}.fastq") if pe
      execute("#{Paths.fasqual2fastq} #{prepro_reads}/#{run_nr}.fasta.clean #{prepro_reads}/#{run_nr}.qual.clean >  #{prepro_reads}/#{run_nr}.fastq")    
      execute("rm -f #{prepro_reads}/*.fasta #{prepro_reads}/*.clean #{prepro_reads}/*.qual #{prepro_reads}/*.cln #{prepro_reads}/*.fna")
      
      if pe
	#Seqclean cannot handle paired-end reads. Thus each file is processed seperately which can lead to unsynchronized paired-read files
	#run delete_unpaired_reads.rb to synchronize paired-read files
	puts "synchronizing paired-read files for #{run} and #{run_nr2}"
	execute("gzip -dk #{raw_reads}/#{run_nr}.fastq.gz")
	execute("ruby #{Paths.delete_unpaired_reads} #{raw_reads}/#{run_nr}.fastq #{prepro_reads}/#{run_nr}.fastq #{prepro_reads}/#{run_nr2}.fastq")
	execute("rm -f #{prepro_reads}/#{run_nr}.fastq #{prepro_reads}/#{run_nr2}.fastq")
	execute("rm -f #{raw_reads}/#{run_nr}.fastq")
	execute("mv #{prepro_reads}/#{run_nr}_merged1.fastq #{prepro_reads}/#{run_nr}.fastq")
	execute("mv #{prepro_reads}/#{run_nr2}_merged2.fastq #{prepro_reads}/#{run_nr2}.fastq")
      end
    end
    
    
    #run seqtk trimfq to trim low quality reads
    puts "processing #{run}: seqtk trimfq"
    if pe 
      execute("seqtk trimfq -q 0.0158 #{prepro_reads}/#{run_nr}.fastq > #{prepro_reads}/#{run_nr}_trimmed.fastq")
      execute("seqtk trimfq -q 0.0158 #{prepro_reads}/#{run_nr2}.fastq > #{prepro_reads}/#{run_nr2}_trimmed.fastq")
      execute("rm -f #{prepro_reads}/#{run_nr}.fastq")
      execute("rm -f #{prepro_reads}/#{run_nr2}.fastq") if pe
      execute("mv #{prepro_reads}/#{run_nr}_trimmed.fastq #{prepro_reads}/#{run_nr}.fastq")
      execute("mv #{prepro_reads}/#{run_nr2}_trimmed.fastq #{prepro_reads}/#{run_nr2}.fastq") if pe
      puts "processing #{run}: prinseq"
      execute("perl /work/gi/software/bin/prinseq-lite.pl -fastq #{prepro_reads}/#{run_nr}.fastq -fastq2 #{prepro_reads}/#{run_nr2}.fastq -trim_qual_left 28 -trim_qual_right 28 -trim_tail_left 8 -trim_tail_right 8 -trim_ns_left 8 -trim_ns_right 8 -lc_method entropy -lc_threshold 70 -min_len 50 -out_format 3 -out_bad null")
      execute("rm -f #{prepro_reads}/*singletons*.fastq")
      execute("rm -f #{prepro_reads}/#{run_nr}.fastq")
      execute("rm -f #{prepro_reads}/#{run_nr2}.fastq")
      execute("mv #{prepro_reads}/#{run_nr}*.fastq #{prepro_reads}/#{run_nr}.fastq")
      execute("mv #{prepro_reads}/#{run_nr2}*.fastq #{prepro_reads}/#{run_nr2}.fastq")
    else
      execute("seqtk trimfq -q 0.0158 #{prepro_reads}/#{run_nr}.fastq | perl /work/gi/software/bin/prinseq-lite.pl -fastq stdin -trim_tail_left 8 -trim_tail_right 8 -trim_ns_left 8 -trim_ns_right 8 -lc_method entropy -lc_threshold 70 -min_len 50 -out_format 3 -out_bad null -out_good #{prepro_reads}/#{run_nr}_prinseq")
      execute("rm -f #{prepro_reads}/#{run_nr}.fastq")
      execute("mv #{prepro_reads}/#{run_nr}_prinseq.fastq #{prepro_reads}/#{run_nr}.fastq")
    end
    
    execute("gzip -f #{prepro_reads}/#{run_nr}.fastq")
    execute("gzip -f #{prepro_reads}/#{run_nr2}.fastq") if pe
    
 end
 
 def Preprocess.execute(command)
   puts command
   out = `#{command}`
   if $?.exitstatus != 0 
     STDERR.puts "Error at command #{command}"
     exit 1
   end
   out
 end
 
end
