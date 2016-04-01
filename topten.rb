require 'csv'

vhash = Hash.new
phash = Hash.new
ahash = Hash.new
method = 'uproc'

'vhash = {vent => {pfam=>count, pfam=>count, ...}, vent => {...}, ...}'
'phash = {pfam => {vent=>proportion, vent=>proportion, ..}, pfam => {...}, ...}'
'ahash = {pfam => {avg_prop=>prop, min=>[prop,vent], max=>[prop,vent]}, pfam => {...}, ...}'

ARGV.each do |vent|
  profil_file = "#{vent}/profiles/functional/#{method}/#{method}.txt"
  if !File.exists(profile_file)
    STDERR.puts "Profile file #{pofie_file} not found"
    exit 1
  end
  vhash[vent] = Hash.new
  count_sum = 0
  CSV.open(profile_file, 'r').each do |line|
    next if line[0] == 'pfam'
    pfam = line[0]
    count = line[1].chomp.to_i
    vhash[vent][pfam] = count
    count_sum += 0
  end
  vhash.each do |v,h|
    h.each do |p,c|
    vhash[v][p] = (count / count_sum).to_f #relative proportion
  end
  end
end

vhash.each do |v,h|
  h.each do |p,rp|
    phash[p] = Hash.new if phash.has_key?(p)
    phash[p][v] = rp
  end
end

phash.each do |p,h|
  min = 1.0
  max = 0.0
  min_vent = nil
  max_vent = nil
  prop_sum = 0.0
  avg = 0.0
  h.each do |v,rp|
    if min < rp
      min = rp
      min_vent = v
    end
    if max > rp
      max = rp
      max_vent = v
    end
    prop_sum += rp
  end
  ahash[p] = Hash.new if ahash.has_key?(p)
  ahash[p][:avg_prop] = (prop_sum / h.size).to_f
  ahash[p][:min] = [min,min_vent]
  ahash[p][:max] = [max,max_vent]
end

print ahash.sort_by{|p,h| -h[:avg_prop]}

#topten = []


# write data for boxplot
# pfam1    prop
# pfam1    prop
# pfam2    prop
# pfam2    prop
#...

#ahash.each do |
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
  
  
  
    
