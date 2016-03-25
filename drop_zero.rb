# File.open(ARGV[0]).each do |line|
#   line = line.split(',')
#   if line[1].to_i != 0
#     puts "#{line[0]},#{line[1]}"
#   end
# end


# sum = 0
# File.open(ARGV[0]).each do |line|
#   line = line.split(',')
#   next if line [0] == 'frequency'
#   fr = line[0].to_f
#   sum +=fr
# end
# puts sum

prf1_hash = Hash.new
prf2_hash = Hash.new

File.open('stats/complete_tax_uproc.csv').each do |line|
  line = line.split(",")
  next if line[0] == 'species'
  freq = line[1].chomp.to_f
  species = line[0]
  prf1_hash[species] = prf1_hash[species] == nil ? freq : prf1_hash[species] += freq
end

File.open('stats/complete_tax_diamond.csv').each do |line|
  line = line.split(",")
  next if line[0] == 'species'
  freq = line[1].chomp.to_f
  species = line[0]
  prf2_hash[species] = prf2_hash[species] == nil ? freq : prf2_hash[species] += freq
end

pairs_hash = Hash.new 
prf1_hash.each do |pfam,count|
  prf2_count = prf2_hash.has_key?(pfam) ? prf2_hash[pfam] : 0
  pairs_hash[pfam] = [count,prf2_count]
end
prf2_hash.each do |pfam,count|
  prf1_count = prf1_hash.has_key?(pfam) ? prf1_hash[pfam] : 0
  pairs_hash[pfam] = [prf1_count,count]
end

puts"uproc,diamond"
pairs_hash.each do |pfam,counts_arr|
  puts "#{counts_arr[0]},#{counts_arr[1]}"
end