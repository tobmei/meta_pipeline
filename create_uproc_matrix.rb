
pfam_arr = []
vcounts_hash = Hash.new
meta_hash = Hash.new

#parse meta_file
File.open('stats/vents.csv').each do |line|
  next if line[0] == '#'
  line = line.split("\t")
  vent = line[0]
  platform = line[3]
  meta_hash[vent] = platform
end

ARGV.each do |vent|
  ve = File.basename(vent)
#   next if meta_hash[ve] != 'illumina'
  profiles_dir = "#{vent}/profiles/functional/diamond"
  next if !File.exists?("#{profiles_dir}/diamond_less.txt")  
  uproc_file = "#{profiles_dir}/diamond_less.txt"
  File.open(uproc_file).each do |line|
    l = line.split(',')
    next if l[0] == 'pfam'
    pfam_id = l[0]
    counts = l[1]
    pfam_arr.push(pfam_id) if !pfam_arr.include?(pfam_id)
    vcounts_hash[ve] = Hash.new(0) if vcounts_hash[ve] == nil
    vcounts_hash[ve][pfam_id] = counts.chomp
  end
end
# print "taxon"
arr2 = []
vcounts_hash.each do |k,v|
#   print ",#{k}"
  arr1 = []
  pfam_arr.each do |t|
    arr1.push(v[t])
  end
  arr2.push(arr1)
end
# arr2 = arr2.transpose
# puts "\n"

v_arr = []
vcounts_hash.each do |vent,bla|
  v_arr.push(vent)
end

pfam_arr.each do |pfam|
  if pfam == pfam_arr[-1]
    print "#{pfam}"
  else
    print "#{pfam},"
  end
end
puts "\n"
i = 0
arr2.each do |rows|
  print "#{v_arr[i]},"
  i += 1
  (0..rows.size-1).each do |val|
    if val == rows.size-1
      print "#{rows[val]}"
    else
      print "#{rows[val]},"
    end
  end
  puts "\n" if rows != arr2[-1]
end
puts"\n"



