class_count = 0 
old_id = ''
pfam_hash = Hash.new
puts ARGV[0]
ARGF.each do |line|
  l = line.split("\t")
  curr_id = l[0]
  if old_id != curr_id
    class_count += 1 
#     puts l[0]
      pfam = l[1].scan(/(PF\d\d\d\d\d)/)[0][0]
#       puts pfam
      pfam_hash[pfam] = pfam_hash[pfam] == nil ? 1 : pfam_hash[pfam]+1
  end
  old_id = curr_id
#   break if class_count > 100
end
puts class_count
pfam_sorted = pfam_hash.sort_by {|key, value| -value}

pfam_sorted.each do |i|
   puts "#{i[0]},#{i[1]}"
end