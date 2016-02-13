

pfam_hash = Hash.new
ARGV.each do |vent|
  profiles_dir = "#{vent}/profiles/functional/uproc"
  ve = File.basename(vent)
  next if ve == 'test_data'
  uproc_file = File.exists?("#{profiles_dir}/uproc_combined.txt")  ? "#{profiles_dir}/uproc_combined.txt" : "#{profiles_dir}/uproc.txt"
  File.open(uproc_file).each_line do |line|
    l = line.split(',')
    pfam_id = l[0]
    counts = l[1].to_i
    pfam_hash[pfam_id] = 0 if pfam_hash[pfam_id] == nil
    pfam_hash[pfam_id] += counts
  end
end

puts "pfam\tcount"
pfam_hash.each do |pfam,count|
  pfam_desc = `grep #{pfam} data/Pfam-A.clans.tsv | cut -f 5`.chomp
  pfam_desc = pfam_desc.length > 30 ? "#{pfam_desc[0..30]}..." : pfam_desc
  print "#{pfam_desc}(#{pfam})\t#{count}\n"
end
  




