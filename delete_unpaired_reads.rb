require_relative 'giorgios_fastq_iterator'

#This script synchronizes paired read files

if ARGV.size != 3
  puts 'Usage: ruby delete_unpaired_reads.rb <raw.fastq> <preprocessed1.fastq> <preprocessed2.fastq>'
  exit 0
end

ARGV.each do |file|
  if !File.exists?(file) 
    STDERR.puts "ERROR: File #{file} not found"
    exit 1
  end
end

f_orig = FastqFile.open(ARGV[0])
f_fastq1 = FastqFile.open(ARGV[1])
f_fastq2 = FastqFile.open(ARGV[2])

id_orig = id_fastq1 = id_fastq2 = nil
next_unit2 = next_unit3 = true
unit_fastq1 = unit_fastq2 = nil
orig_size = `cat #{ARGV[0]} | wc -l`

f_out1 = File.open("#{ARGV[1].sub('.fastq', '')}_merged1.fastq", 'a')
f_out2 = File.open("#{ARGV[2].sub('.fastq', '')}_merged2.fastq", 'a')

puts "#{ARGV[1].sub('.fastq', '')}_merged1.fastq"
puts "#{ARGV[2].sub('.fastq', '')}_merged2.fastq"
for i in 1..orig_size.to_i/4
  f_orig.each do |unit|
    id_orig = unit.desc.split("\s")[0].gsub("/1","")
    break
  end

  if next_unit2
    f_fastq1.each do |unit|
      id_fastq1 = unit.desc.split("\s")[0].gsub("/1","")
      unit_fastq1 = unit
      break
    end
  end

  if next_unit3
    f_fastq2.each do |unit|
      id_fastq2 = unit.desc.split("\s")[0].gsub("/2","")
      unit_fastq2 = unit
      break
    end
  end
  
  if id_orig == id_fastq1 && id_orig == id_fastq2
    #id_fastq1 and id_fastq2 are mates -> keep
    f_out1.puts unit_fastq1.desc
    f_out1.puts unit_fastq1.seq
    f_out1.puts unit_fastq1.qdesc
    f_out1.puts unit_fastq1.qual
    f_out2.puts unit_fastq2.desc
    f_out2.puts unit_fastq2.seq
    f_out2.puts unit_fastq2.qdesc
    f_out2.puts unit_fastq2.qual
    next_unit2 = next_unit3 = true
  elsif id_orig != id_fastq1 && id_orig != id_fastq2 
    #both pairs with id_orig were filtered
    next_unit2 = next_unit3 = false
  elsif id_orig == id_fastq1 && id_orig != id_fastq2
    #id_fastq1 has no mate -> drop
    next_unit2 = true
    next_unit3 = false
  elsif id_orig != id_fastq1 && id_orig == id_fastq2
    #id_fastq2 has no mate -> drop
    next_unit2 = false
    next_unit3 = true
  end
  
end
