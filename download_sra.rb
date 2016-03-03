
file = ARGV[0]
out_dir = ARGV[1] 

File.open(file).each do |line|
  next if line[0] == '#'
  line = line.split(',')
  name = line.first
  line.shift
  `mkdir #{out_dir}/#{name}` if !File.directory?("#{out_dir}/#{name}")
  line.each do |accession|
    accession = accession.strip
    `/home/stud2012/tmeier/tools/sratoolkit.2.5.4-1-ubuntu64/bin/fastq-dump --split-3 --skip-technical --gzip -O #{out_dir}/#{name}/raw_reads #{accession}` 
  end
end 