

print "vent,classified,percent\n"
ARGV.each do |vent|
  ve = File.basename(vent)
  next if !File.exists?("#{vent}/profiles/functional/uproc/classification_count.txt")
  File.open("#{vent}/profiles/functional/uproc/classification_count.txt").each_line do |line|
    line = line.split(',')
    p = 100 * line[0].to_f/line[2].to_f
#     puts "#{ve},#{p.round(2)}"
    puts "#{ve},#{line[0]},#{p.round(2)}\n"
  end
end