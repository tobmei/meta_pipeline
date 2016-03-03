prf1_hash = Hash.new
prf2_hash = Hash.new
prf1_count_hash = Hash.new
prf2_count_hash = Hash.new
prf1_sum = 0
prf2_sum = 0

# ARGV.each do |vent| 
#   puts vent
#   prf1 = "#{vent}/profiles/functional/#{ARGV[0]}"
#   prf2 = "#{vent}/profiles/functional/#{ARGV[1]}"
#   next if !File.exists?("#{prf1}/#{prf1}.txt") ||  !File.exists?("#{prf2}/#{prf2}.txt")
#   prf1_hash[vent] = Hash.new
#   prf2_hash[vent] = Hash.new
  
#   File.open("#{prf1}/#{prf1}.txt").each_line do |line|
  File.open("uproc.txt").each_line do |line|
    line = line.split(',')
    next if line[0] == 'pfam'
    pfam = line[0].scan(/(PF\d\d\d\d\d)/)[0][0]
    count = line[1].chomp.to_i
    prf1_hash[pfam] = prf1_hash[pfam] == nil ? count : prf1_hash[pfam]+count
    prf1_sum += count
  end
#   prf1_count_hash[vent] = prf1_sum
    
  
#   File.open("#{prf2}/#{prf2}.txt").each_line do |line|
  File.open("tara_122_funcprof.txt").each_line do |line|
    line = line.split(',')
    next if line[0] == 'pfam'
    pfam = line[0].scan(/(PF\d\d\d\d\d)/)[0][0]
    count = line[1].chomp.to_i
    prf2_hash[pfam] = prf2_hash[pfam] == nil ? count : prf2_hash[pfam]+count
    prf2_sum += count
  end
#   prf2_count_hash[vent] = prf2_sum
  
# end  
  
#   prf1_hash.each do |vent,phash|
#     phash.each do |pfam,count|
#       prf1_hash[vent][pfam] = count / prf1_count_hash[vent].to_f
#     end
#   end
#   
#   prf2_hash.each do |vent,phash|
#     phash.each do |pfam,count|
#       prf2_hash[vent][pfam] = count / prf2_count_hash[vent].to_f
#     end
#   end
  
#  print prf1_count_hash
# prf1_hash = prf1_hash.sort_by{|k,v| v}
# prf2_hash = prf2_hash.sort_by{|k,v| v}
#  puts prf2_hash.size
#  puts prf1_hash.size
 
pairs_hash = Hash.new 
prf1_hash.each do |pfam,count|
  prf2_count = prf2_hash.has_key?(pfam) ? prf2_hash[pfam] : 0
  pairs_hash[pfam] = [count,prf2_count]
end
prf2_hash.each do |pfam,count|
  prf1_count = prf1_hash.has_key?(pfam) ? prf1_hash[pfam] : 0
  pairs_hash[pfam] = [prf1_count,count]
end

puts"#{ARGV[0]},#{ARGV[1]}"
pairs_hash.each do |pfam,counts_arr|
  if counts_arr[0] != 0 && counts_arr[1] != 0 
    puts "#{counts_arr[0]},#{counts_arr[1]}"
  end
end
   
  
# h = Hash.new
# 
# max = 0.0
# ARGV.each do |vent|
# prf1 = "#{vent}/profiles/functional/prf1"
#  prf2 = "#{vent}/profiles/functional/prf2"
#  next if !File.exists?("#{prf1}/prf1.txt") ||  !File.exists?("#{prf2}/prf2.txt")
#   h[vent] = Hash.new
#   
#   prf1_hash[vent].each do |pfam,u_prozant|
#     d_prozant = prf2_hash[vent][pfam] != nil ? prf2_hash[vent][pfam] : 0.0
#     h[vent][pfam] = u_prozant - d_prozant
#   end
#   
#   prf2_hash[vent].each do |pfam,d_prozant|
#     if !prf1_hash[vent].has_key?(pfam)
#       u_prozant = 0.0
#       h[vent][pfam] = u_prozant - d_prozant
#     end
# 
#   end
#   
#   
# end
# 
# pfam_arr = []
# 
# h.each do |vent,hash|
#   hash.each do |pfam,v|
#     pfam_arr.push(pfam) if !pfam_arr.include?(pfam)
#   end
# end
# 
# #puts pfam_arr.size
# #puts h.size
# 
# #für boxplots
# h.each do |vent,prozhash|
#  prozhash.each do |pfam,prozant|
#    puts "#{pfam},#{prozant}"
#  end
# end
#     
# #avg_hash = Hash.new
# 
# #pfam_arr.each do |pfam|
# #  avg_hash[pfam] = []
# #  h.each do |vent,prozhash|
# #    if prozhash.has_key?(pfam)
# #      avg_hash[pfam].push(prozhash[pfam].abs)
# #    end
# #  end
# #end
# # puts avg_hash
#       
# #average für korellation
# u_avg = Hash.new
# d_avg = Hash.new
# 
# pfam_arr.each do |pfam|
#   prf1_hash.each do |vent,prozhash|
#     if prozhash.has_key?(pfam)
#       if u_avg[pfam] == nil 
#         u_avg[pfam] = []
#       end
#       u_avg[pfam].push(prozhash[pfam].abs)
#     end
#   end
# end
# u_avg.each do |pfam,arr|
#   u_avg[pfam] = arr.inject(0.0) { |sum, el| sum + el } / arr.size
# end
# 
# #puts u_avg
# 
# pfam_arr.each do |pfam|
#   prf2_hash.each do |vent,prozhash|
#     if prozhash.has_key?(pfam)
#       if d_avg[pfam] == nil 
#         d_avg[pfam] = []
#       end
#       d_avg[pfam].push(prozhash[pfam].abs)
#     end
#   end
# end
# d_avg.each do |pfam,arr|
#   d_avg[pfam] = arr.inject(0.0) { |sum, el| sum + el } / arr.size
# end
# 
# #puts d_avg
# puts 'x,y'
# pfam_arr.each do |pfam|
#   if u_avg.has_key?(pfam) && d_avg.has_key?(pfam)
#     puts "#{u_avg[pfam]},#{d_avg[pfam]}"
#   end
# end
  

















 
 
 
 
 
 
