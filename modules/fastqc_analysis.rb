
module Fastqc_analysis
  def Fastqc_analysis.run(run)
    fastqc_hash = Hash.new
    dir = "#{File.dirname(run)}/fastqc_analysis"
    run_nr = File.basename(run.sub('.fastq.gz',''))
    if !File.exist?("#{dir}/#{run_nr}_fastqc/summary.txt") #analysis already exists
      `mkdir #{dir}` if !File.directory?(dir)
      `fastqc --extract #{run} -o #{dir}`
      `rm -f #{dir}/*.html #{dir}/*.zip`
    end
    
    if !File.exist?("#{dir}/#{run_nr}_fastqc/summary.txt")
        STDERR.puts "#{dir}/#{run_nr}_fastqc/summary.txt not found"
        exit 1
    end
    fastqc_hash = Hash.new
      
    File.open("#{dir}/#{run_nr}_fastqc/summary.txt", 'r') do |file|
      file.read.each_line do |line|
	line_split = line.split("\t")
	fastqc_hash[line_split[1]] = line_split[0].downcase 
      end
    end
      
    return fastqc_hash
  end 
end
