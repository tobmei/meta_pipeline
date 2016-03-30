require '/work/gi/coop/perner/metameta/scripts/paths'

tax_arr = ['Proteobacteria','Thaumarchaeota','VMG','Bacteroidetes','Actinobacteria']
print ','
tax_arr.each do |tax|
  print tax == tax_arr[-1] ? "#{tax}\n" : "#{tax},"
end
ARGV.each do |vent|
  row_hash = Hash.new
  profiles_dir = "#{vent}/profiles"
  ve = File.basename(vent)
  next if ve == 'test_data'
  file = File.exists?("#{profiles_dir}/Taxy/uproc_phylumID.csv") ? "#{profiles_dir}/Taxy/uproc_phylumID.csv" : "#{profiles_dir}/Taxy/uproc_combined_phylumID.csv"
  File.open(file).each_line do |line|
    l = line.split(',')
    next if l[0] == 'taxon'
    next if !tax_arr.include?(l[0])
    taxon = l[0]
    freq = l[1].to_f
    row_hash[taxon] = 0.0 if row_hash[taxon] == nil
    row_hash[taxon] += freq
  end
  print "#{ve},"
  tax_arr.each do |t|
      print t == tax_arr[-1] ? "#{row_hash[t]}\n" : "#{row_hash[t]},"
  end
end
