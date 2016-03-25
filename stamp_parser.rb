require 'csv'

stamp_file = ARGV[0]
group = ARGV[1]
group_hash = Hash.new

#barplot and boxplot data

#parse group_file
i = 0
idx = 0
name_to_plot = Hash.new
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
  to_plot = line[1]
  g = line[idx]
  group_hash[vent] = g
  name_to_plot[vent] = to_plot
end

if idx == 0
  STDERR.puts 'Error: Group not found in meta_file'
  exit 1
end


max_effect = 0.0
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
  if effect > max_effect
    effect_index = index
    max_effect = effect
  end
end
  
file = CSV.read(stamp_file, :col_sep => "\t")

h = Hash[header.zip(file[effect_index])]

pvalue = (h["p-values (corrected)"]).to_f.round(6)
feature = h["Species"].gsub(' ','_')
effect = max_effect.to_f.round(3)

plot_hash = Hash.new
h.each do |k,v|
  if k =~ /: rel. freq./
    vent = k.scan(/^[^\:]*/)[0]
    plot_hash[vent] = [group_hash[vent],v]
  end
end

CSV.open("stamp_bar_temp.tsv", "w", :col_sep => "\t") do |csv|
  csv << ['vent','value','Gruppe']
  plot_hash.each do |vent,v|
    csv << [name_to_plot[vent],v[1],v[0]]
  end
end



#heatmap
heat_hash = Hash.new

max_effects = []
CSV.foreach(stamp_file, :col_sep => "\t") {|row| max_effects << row[3]}
max_effects.shift
max_effects = max_effects.sort.pop(20)


start_index = 0
header.each_with_index do |v,i|
  if v =~ /: rel. freq./
    start_index = i
    break
  end
end

File.open(stamp_file).each do |row|
  row = row.split("\t")
  next if row[0] == 'Species'
  next if !max_effects.include?(row[3])
  label = "#{row[0]}(#{row[3].to_f.round(3)},#{row[2].to_f.round(4)})"
  heat_hash[label] = Hash.new
  (start_index..row.length).step(3) do |n|
    heat_hash[label][header[n].scan(/^[^\:]*/)[0]] = row[n]
  end
end

CSV.open("stamp_heat_temp.tsv", "w", :col_sep => "\t") do |csv|
  csv << ['feature','vent','Frequenz']
  heat_hash.each do |feat,vent_value_hash|
    vent_value_hash.each do |vent,value|
      csv << [feat,name_to_plot[vent],value]
    end
  end
end



`Rscript stamp.r stamp_bar_temp.tsv stamp_heat_temp.tsv #{stamp_file}  #{effect} #{pvalue} #{feature}`
`rm stamp_bar_temp.tsv`
`rm stamp_heat_temp.tsv`

  