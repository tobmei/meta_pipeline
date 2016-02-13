
pfam_arr = []
vcounts_hash = Hash.new
ARGV.each do |vent|
  profiles_dir = "#{vent}/profiles/functional/uproc"
  ve = File.basename(vent)
  next if ve == 'test_data' || (ve != 'nakai_fryer_28' && ve != 'perner_sisters_peak_29')
  uproc_file = File.exists?("#{profiles_dir}/uproc_combined.txt")  ? "#{profiles_dir}/uproc_combined.txt" : "#{profiles_dir}/uproc.txt"
  File.open(uproc_file).each_line do |line|
    l = line.split(',')
    pfam_id = l[0]
    counts = l[1]
    pfam_arr.push(pfam_id) if !pfam_arr.include?(pfam_id)
    vcounts_hash[ve] = Hash.new(0.0) if vcounts_hash[ve] == nil
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



