
vents_arr = []
# vcounts_hash = Hash.new
hash = Hash.new

# #parse meta_file
# File.open('stats/vents.csv').each do |line|
#   next if line[0] == '#'
#   line = line.split("\t")
#   vent = line[0]
#   platform = line[3]
#   meta_hash[vent] = platform
# end

# {pf1234 => {abe1 => 123, abe2 => 345, sisterspeak => 678}, pf45678 => {...}, ...}

ARGV.each do |vent|
  ve = File.basename(vent)
#   next if ve =~ /TARA/
#   next if meta_hash[ve] != 'illumina'
  profiles_dir = "#{vent}/profiles/functional/uproc"
  uproc_file = "#{profiles_dir}/uproc.txt"
  next if !File.exists?(uproc_file)
  vents_arr.push(ve)  
  File.open(uproc_file).each do |line|
    l = line.split(',')
    next if l[0] == 'pfam'
    pfam_id = l[0]
    counts = l[1].chomp
    hash[pfam_id] = Hash.new if !hash.has_key?(pfam_id)
    hash[pfam_id][ve] = counts
  end
end

print "Category\t"
vents_arr.each do |v|
  print "#{v}\t"
end
print "\n"

hash.each do |pfam, vent_hash|
  print "#{pfam}\t"
  vents_arr.each do |vent|
    print vent_hash.has_key?(vent) ? "#{vent_hash[vent]}\t" : "0\t"
  end
  print "\n"
end

#average profile
# hash.each do |pfam,vent_hash|
#   sum = 0.0
#   avg = 0.0
#   vent_hash.each do |vent,count|
#     sum += count.to_f
#   end
#   avg = (sum / vent_hash.length).to_f
#   hash[pfam] = avg
# end
# 
# print "Category\tcount\n"
# 
# hash.each do |pfam,avg|
#   print "#{pfam}\t#{avg}\n"
# end




