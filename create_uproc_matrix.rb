
pfam_arr = []
vcounts_hash = Hash.new
meta_hash = Hash.new

#parse meta_file
File.open('stats/vents.csv').each do |line|
  next if line[0] == '#'
  line = line.split("\t")
  vent = line[0]
  platform = line[3]
  meta_hash[vent] = platform
end

ARGV.each do |vent|
  ve = File.basename(vent)
#   next if meta_hash[ve] != 'illumina'
  profiles_dir = "#{vent}/profiles/functional/uproc"
#   next if !File.exists?("#{profiles_dir}/diamond_less.txt")  
  uproc_file = "#{profiles_dir}/uproc.txt"
  File.open(uproc_file).each do |line|
    l = line.split(',')
    next if l[0] == 'pfam'
    pfam_id = l[0]
    counts = l[1]
    pfam_arr.push(pfam_id) if !pfam_arr.include?(pfam_id)
    vcounts_hash[ve] = Hash.new(0) if vcounts_hash[ve] == nil
    vcounts_hash[ve][pfam_id] = counts.chomp
  end
end


pfam_arr.each do |pfam|
  print pfam == pfam_arr[-1] ? "#{pfam}\n" : "#{pfam},"
end
vcounts_hash.each do |vent,hash|
  print "#{vent},"
  pfam_arr.each do |pfam|
    print pfam == pfam_arr[-1] ? "#{hash[pfam]}\n" : "#{hash[pfam]},"
  end
end
  
  



