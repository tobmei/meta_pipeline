require 'csv'

vhash = Hash.new
phash = Hash.new
ahash = Hash.new
method = 'uproc'

'vhash = {vent => {pfam=>count, pfam=>count, ...}, vent => {...}, ...}'
'phash = {pfam => {vent=>proportion, vent=>proportion, ..}, pfam => {...}, ...}'
'ahash = {pfam => {avg_prop=>prop, min=>[prop,vent], max=>[prop,vent]}, pfam => {...}, ...}'

ARGV.each do |vent|
  ve = File.basename(vent)
  next if ve =~ /TARA/
  profile_file = "#{vent}/profiles/functional/#{method}/#{method}.txt"
  if !File.exists?(profile_file)
    STDERR.puts "Profile file #{profile_file} not found"
    #exit 1
    next
  end
  vhash[ve] = Hash.new
  count_sum = 0.0
  CSV.open(profile_file, 'r').each do |line|
    next if line[0] == 'pfam'
    pfam = line[0]
    count = line[1].chomp.to_i
    vhash[ve][pfam] = count
    count_sum += count
  end
  vhash[ve].each do |p,c|
    vhash[ve][p] = (vhash[ve][p] / count_sum).to_f #relative proportion
  end
end

vhash.each do |v,h|
  h.each do |p,rp|
    phash[p] = Hash.new if !phash.has_key?(p)
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
    if rp < min
      min = rp
      min_vent = v
    end
    if rp > max
      max = rp
      max_vent = v
    end
    prop_sum += rp
  end
  ahash[p] = Hash.new if !ahash.has_key?(p)
  ahash[p][:avg_prop] = (prop_sum / h.size).to_f
  ahash[p][:min] = [min,min_vent]
  ahash[p][:max] = [max,max_vent]
end

'["PF01051", {:avg_prop=>0.017128828911598414, :min=>[3.0058155531108254e-06, "cayman_rise_unpublished_beebe_background_22"], :max=>[0.5055659649509534, "perner_sisters_peak_29"]}]'
topten_pfam = []
ahash.sort_by{|p,h| -h[:avg_prop]}.each_with_index do |k,idx|
  if idx < 10
    topten_pfam.push(k[0])
  end
end

# write data for boxplot
# pfam1    prop
# pfam1    prop
# pfam2    prop
# pfam2    prop
#...
puts 'pfam,freq'
topten_pfam.each do |pfam|
  phash[pfam].each do |v,p|
    puts "#{pfam},#{p}"
  end
end
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
  
  
  
    
