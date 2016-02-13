# 
# hash = Hash.new
# puts "taxon,frequency"
# ARGV.each do |vent|
#   ve = File.basename(vent)
#   prepro_reads = "#{vent}/preprocessed_reads"
#   Dir.glob("#{prepro_reads}/*_Taxy/*.csv") do |file|
#     next if file.match(/family/) == nil
#     File.open(file).each_line do |line|
#       l = line.split(',')
#       taxon = l[0]
#       freq = l[1]
#       next if taxon == 'taxon'
#       taxon = 'Viralstromatolite' if taxon.match(/VIRALSTROMATOLITE/) != nil
#       taxon = taxon.length > 30 ? "#{taxon[0..25]}..." : taxon
#       puts "#{taxon},#{freq}"
# #       hash[taxon] = 0 if hash[taxon] == nil
# #       hash[taxon] += freg.chomp
#     end
#   end
# end


ARGV.each do |vent|
  ve = File.basename(vent)
  prepro_reads = "#{vent}/preprocessed_reads"
  run_nr = ''
  Dir.glob("#{prepro_reads}/*fastq.gz") do |run|  
    run_nr = File.basename(run.sub('.fastq.gz',''))
    break
  end
  profile_files_count = `ls #{prepro_reads}/*.txt | wc -l`.to_i
  uproc_file = profile_files_count > 1 ? "#{prepro_reads}/uproc_combined.txt" : "#{prepro_reads}/#{run_nr}_uproc.txt"
  puts "taxon,frequency"
  File.open(uproc_file).each_line do |line|
    puts line
    l = line.split(',')
    pfam_id = l[0]
    counts = l[1]
#     pfam_arr.push(pfam_id) if !pfam_arr.include?(pfam_id)
#     vcounts_hash[ve] = Hash.new(0.0) if vcounts_hash[ve] == nil
#     vcounts_hash[ve][pfam_id] = counts.chomp
  end
end