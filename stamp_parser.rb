require 'csv'

stamp_file = ARGV[0]
group = ARGV[1]
group_hash = Hash.new

#barplot and boxplot data

#parse group_file
i = 0
idx = 0
File.open('stats/vents.csv').each do |line|
  line = line.split("\t")
  if line[0] == 'vent'
    line.each do |v|
      if group == v
	idx = i
      end
      i += 1
    end
    next
  end
  vent = line[0]
  g = line[idx]
  group_hash[vent] = g
end

if idx == 0
  STDERR.puts 'Error: Group not found in meta_file'
  exit 1
end


max_effect = 0.0
min_pvalue = 1.0
pvalue_index = 0
effect_index = 0
header = nil
File.open(stamp_file).each_with_index do |row, index|
  row = row.split("\t")
  if row[0] == 'Species'
    header = row
    next
  end
  pvalue = row[2].to_f
  effect = row[3].to_f
  if pvalue < min_pvalue
    pvalue_index = index
    min_pvalue = pvalue
  end
  if effect > max_effect
    effect_index = index
    max_effect = effect
  end
end
  
file = CSV.read(stamp_file, :col_sep => "\t")

h = Hash[header.zip(file[effect_index])]

plot_hash = Hash.new
h.each do |k,v|
  if k =~ /: rel. freq./
    vent = k.scan(/^[^\:]*/)[0]
    plot_hash[vent] = [group_hash[vent],v]
  end
end

CSV.open("stamp_bar_temp.tsv", :col_sep => "\t", "w") do |csv|
  csv << ['vent','value','group']
  plot_hash.each do |vent,v|
    csv << [vent,v[1],v[0]]
  end
end


#heatmap

start_index = 0
header.each_with_index do |v,i|
  if v =~ /: rel. freq./
    start_index = i
    break
  end
end

CSV.open("stamp_heat_temp.tsv", :col_sep => "\t", "w") do |csv|
  csv << ['vent','value','group']
  plot_hash.each do |vent,v|
    csv << [vent,v[1],v[0]]
  end
end
# (start_index..row.length).step(3) do |n|
#     print "#{header[n]},"
#   end
# CSV.open("stats/stamp/.csv", :col_sep => "\t", "w") do |csv|  
file.each do |row|
  print "#{row[0]}\t"
  (start_index..row.length).step(3) do |n|
    print n==row.length ? "#{row[n]}\n" : "#{row[n]}\t"
  end
  print "\n"
end

    

  