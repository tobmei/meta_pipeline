
tax_arr = []
vf_hash = Hash.new

ARGV.each do |vent|
  ve = File.basename(vent)
  next if ve == "test_data"
  row_arr = [ve]
  File.open("#{vent}/profiles/Taxy/taxonomic_profile.csv").each_line do |line|
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
    
#     next if superkingdom != 'Bacteria'
#     taxa_arr.push(phylum)
#     row_arr.push(freq)
    
    tax_arr.push(species) if !tax_arr.include?(species)
    vf_hash[ve] = Hash.new(0.0) if vf_hash[ve] == nil
    vf_hash[ve][species] = freq.chomp

  end
end

# print ","

tax_arr.each do |tax| 
  print tax == tax_arr[-1] ? "#{tax}" : "#{tax},"
end
puts"\n"
vf_hash.each do |vent,hash|
  print "#{vent},"
  tax_arr.each do |tax|
    print tax == tax_arr[-1] ? "#{hash[tax]}" : "#{hash[tax]},"
  end
  puts "\n"
end




