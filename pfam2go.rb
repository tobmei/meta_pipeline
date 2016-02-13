require_relative 'modules/environment'

pfams = []
File.open("data/pfam2go.txt").each_line do |line|
  next if line[0] == !
  l = line.split(">")
  go = l[1] =~ /0004803/ #GO:0004803 -> transposase activity
  if go != nil
    pfams.push(l[0].split(" ")[0].split(":")[1])
  end
end

pfam_arr = []
vcounts_hash = Hash.new
ARGV.each do |vent|
  profiles_dir = "#{vent}/profiles/functional/uproc"
  ve = File.basename(vent)
  next if ve == "test_data"
  row_arr = [ve]
  uproc_file = File.exists?("#{profiles_dir}/uproc_combined.txt")  ? "#{profiles_dir}/uproc_combined.txt" : "#{profiles_dir}/uproc.txt"
  File.open(uproc_file).each_line do |line|
    l = line.split(',')
    pfam_id = l[0]
    counts = l[1]
    perc=77
    File.open('stats/classification_count.csv').each_line do |li|
      li = li.split("&")
      next if li[0] != ve
      perc = (counts.to_f*100/li[1].to_f).to_f
    end
    if pfams.include?(pfam_id) 
      pfam_arr.push(pfam_id) if !pfam_arr.include?(pfam_id)
      vcounts_hash[ve] = Hash.new(0.0) if vcounts_hash[ve] == nil
      vcounts_hash[ve][pfam_id] = perc
    end
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
  pfam_desc = `grep #{pfam} data/Pfam-A.clans.tsv | cut -f 5`.chomp
  pfam_desc = pfam_desc.length > 30 ? "#{pfam_desc[1..30]}..." : pfam_desc
  if pfam == pfam_arr[-1]
    print "#{pfam_desc}(#{pfam})"
  else
    print "#{pfam_desc}(#{pfam}),"
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








