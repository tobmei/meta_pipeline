require '/work/gi/coop/perner/metameta/scripts/paths'

file = ARGV[0]
out_dir = ARGV[1] 

File.open(file).each do |line|
  line = line.split(',')
  name = line.first
  line.shift
  `mkdir #{out_dir}/#{name}` if !File.directory?("#{out_dir}/#{name}")
  line.each do |accession|
    accession = accession.strip
    `#{Paths.sratoolkit}./fastq-dump --split-3 --skip-technical --gzip -O #{out_dir}/#{name}/raw_reads #{accession}` 
  end
end 