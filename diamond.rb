require 'zlib'

ARGV.each do |vent|
  
  raw_reads = "#{vent}/raw_reads"
  prepro_reads = "#{vent}/preprocessed_reads"
  `mkdir #{prepro_reads}/temp`
  Dir.glob("#{prepro_reads}/*fastq.gz") do |run|  
    run_nr = File.basename(run.sub('.fastq.gz',''))
    `diamond blastx -d /scratch/gi/coop/perner/metameta/pfamA -q #{run} -a #{vent}/profiles/functional/diamond/#{run_nr}_matches -t #{prepro_reads}/temp`
    `diamond view -a #{vent}/profiles/functional/diamond/#{run_nr}_matches -o #{vent}/profiles/functional/diamond/#{run_nr}_matches.tab --compress 1 -f tab`
#     `rm -f #{vent}/profiles/functional/diamond/*.daa`
  end
#   `rm -f #{prepro_reads}/temp`
  
#   diamond = "#{vent}/profiles/functional/diamond"
#   Dir.glob("#{diamond}/*.tab.gz") do |matches|  
#     run_nr = File.basename(matches.sub('_matches.tab.gz',''))
#     puts run_nr
#     infile = open(matches)
#     gz = Zlib::GzipReader.new(infile)
#     class_count = 0 
#     pfam_hash = Hash.new
#     old_id = ''
#     gz.each_line do |line|
#       l = line.split("\t")
#       curr_id = l[0]
#       if old_id != curr_id
#         class_count += 1 
#         pfam = l[1].scan(/(PF\d\d\d\d\d)/)[0][0]
#         pfam_hash[pfam] = pfam_hash[pfam] == nil ? 1 : pfam_hash[pfam]+1
#       end
#       old_id = curr_id
# #       break if class_count > 1000
#     end
#     
#     puts "classified: #{class_count}"
#     pfam_sorted = pfam_hash.sort_by {|key, value| -value}
# 
#     File.open("#{vent}/profiles/functional/diamond/#{run_nr}_diamond.txt", 'w') { |file| 
#       pfam_sorted.each do |i|
#         file.write "#{i[0]},#{i[1]}\n"
#       end
#     }
#     
#     infile.close
#   end
end

