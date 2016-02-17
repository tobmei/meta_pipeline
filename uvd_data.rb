

uproc_hash = Hash.new
diamond_hash = Hash.new
uproc_count_hash = Hash.new
diamond_count_hash = Hash.new
  uproc_sum = 0
  diamond_sum = 0

ARGV.each do |vent| 
#  uproc = "#{vent}/profiles/functional/uproc"
#  diamond = "#{vent}/profiles/functional/diamond"
#  next if !File.exists?("#{uproc}/uproc.txt") ||  !File.exists?("#{diamond}/diamond.txt")
  uproc_hash[vent] = Hash.new
  diamond_hash[vent] = Hash.new
  
  File.open("uproc_#{vent}.txt").each_line do |line|
    line = line.split(',')
    pfam = line[0].scan(/(PF\d\d\d\d\d)/)[0][0]
    count = line[1].chomp.to_i
    uproc_hash[vent][pfam] = uproc_hash[vent][pfam] == nil ? count : uproc_hash[vent][pfam]+count
    uproc_sum += count
  end
  uproc_count_hash[vent] = uproc_sum
    
  
  File.open("diamond_#{vent}.txt").each_line do |line|
    line = line.split(',')
    pfam = line[0].scan(/(PF\d\d\d\d\d)/)[0][0]
    count = line[1].chomp.to_i
    diamond_hash[vent][pfam] = diamond_hash[vent][pfam] == nil ? count : diamond_hash[vent][pfam]+count
    diamond_sum += count
  end
  diamond_count_hash[vent] = diamond_sum
  
end  
  
  uproc_hash.each do |vent,phash|
    phash.each do |pfam,count|
      uproc_hash[vent][pfam] = count / uproc_count_hash[vent].to_f
    end
  end
  
  diamond_hash.each do |vent,phash|
    phash.each do |pfam,count|
      diamond_hash[vent][pfam] = count / diamond_count_hash[vent].to_f
    end
  end
  
#  print uproc_count_hash
#  print uproc_hash

 
h = Hash.new

max = 0.0
ARGV.each do |vent|

  h[vent] = Hash.new
  
  uproc_hash[vent].each do |pfam,u_prozant|
    d_prozant = diamond_hash[vent][pfam] != nil ? diamond_hash[vent][pfam] : 0.0
    h[vent][pfam] = u_prozant - d_prozant
  end
  
  diamond_hash[vent].each do |pfam,d_prozant|
    if !uproc_hash[vent].has_key?(pfam)
      u_prozant = 0.0
      h[vent][pfam] = u_prozant - d_prozant
    end

  end
  
  
end

pfam_arr = []

h.each do |vent,hash|
  hash.each do |pfam,v|
    pfam_arr.push(pfam) if !pfam_arr.include?(pfam)
  end
end

#puts pfam_arr.size
#puts h.size

#für boxplots
#h.each do |vent,prozhash|
#  prozhash.each do |pfam,prozant|
#    puts "#{pfam},#{prozant}"
#  end
#end
    
#avg_hash = Hash.new

#pfam_arr.each do |pfam|
#  avg_hash[pfam] = []
#  h.each do |vent,prozhash|
#    if prozhash.has_key?(pfam)
#      avg_hash[pfam].push(prozhash[pfam].abs)
#    end
#  end
#end
# puts avg_hash
      
#average für korellation
u_avg = Hash.new
d_avg = Hash.new

pfam_arr.each do |pfam|
  uproc_hash.each do |vent,prozhash|
    if prozhash.has_key?(pfam)
      if u_avg[pfam] == nil 
        u_avg[pfam] = []
      end
      u_avg[pfam].push(prozhash[pfam].abs)
    end
  end
end
u_avg.each do |pfam,arr|
  u_avg[pfam] = arr.inject(0.0) { |sum, el| sum + el } / arr.size
end

#puts u_avg

pfam_arr.each do |pfam|
  diamond_hash.each do |vent,prozhash|
    if prozhash.has_key?(pfam)
      if d_avg[pfam] == nil 
        d_avg[pfam] = []
      end
      d_avg[pfam].push(prozhash[pfam].abs)
    end
  end
end
d_avg.each do |pfam,arr|
  d_avg[pfam] = arr.inject(0.0) { |sum, el| sum + el } / arr.size
end

#puts d_avg

pfam_arr.each do |pfam|
  if u_avg.has_key?(pfam) && d_avg.has_key?(pfam)
    puts "#{u_avg[pfam]},#{d_avg[pfam]}"
  end
end
  

















 
 
 
 
 
 
