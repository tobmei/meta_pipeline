
vents_arr = []
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
  next if !File.exists?("#{vent}/profiles/Taxy/complete.csv")
  ve = File.basename(vent)
#   next if vent =~ /cayman/ || vent =~ /xie/
  vents_arr.push(ve) 
  File.open("#{vent}/profiles/Taxy/complete.csv").each_line do |line|
    l = line.split("\t")
    next if l[0] == 'frequency' || l[0] =="#frequency" 
    freq = l[0].chomp
#     superkingdom = l[1].chomp
#     phylum = l[2].chomp
#     clas = l[3].chomp
#     order = l[4].chomp
#     family = l[5].chomp
#     genus = l[6].chomp
    species = l[7].chomp
    species = 'Unknown' if species =~ /Unknown/
    hash[species] = Hash.new if !hash.has_key?(species)
    hash[species][ve] = freq
  end
end

print "Species\t"
vents_arr.each do |v|
  print "#{v}\t"
end
print "\n"

hash.each do |tax, vent_hash|
  print "#{tax}\t"
  vents_arr.each do |vent|
    print vent_hash.has_key?(vent) ? "#{vent_hash[vent]}\t" : "0\t"
  end
  print "\n"
end

#average profile
# hash.each do |tax,vent_hash|
#   sum = 0.0
#   avg = 0.0
#   vent_hash.each do |vent,count|
#     sum += count.to_f
#   end
#   avg = (sum / vent_hash.length).to_f
#   hash[tax] = avg
# end
# 
# print "Category\tcount\n"
# 
# hash.each do |tax,avg|
#   print "#{tax}\t#{avg}\n"
# end




