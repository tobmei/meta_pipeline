require '/work/gi/coop/perner/metameta/scripts/paths'

print",VMG,Bacteria,Archaea,Eukaryota,Viruses\n"
ARGV.each do |vent|
  row_arr = []
  profiles_dir = "#{vent}/profiles"
  ve = File.basename(vent)
  next if ve == 'test_data'
  row_arr.push(ve)
  file = File.exists?("#{profiles_dir}/Taxy/uproc_superkingdomID.csv") ? "#{profiles_dir}/Taxy/uproc_superkingdomID.csv" : "#{profiles_dir}/Taxy/uproc_combined_superkingdomID.csv"
  File.open(file).each_line do |line|
    l = line.split(',')
    next if l[0] == 'taxon'
    taxon = l[0]
    freq = l[1].chomp
    row_arr.push(freq)
  end
  row_arr.each do |row|
    print row == row_arr[-1] ? "#{row}\n" : "#{row},"
  end
end
