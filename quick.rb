 
# ARGV.each do |vent|
# 
#   diamond = "#{vent}/profiles/functional/diamond"
#   next if !File.exists?("#{diamond}/diamond.txt")
#   File.open("#{diamond}/diamond_less.txt", 'w') { |f|
#     File.open("#{diamond}/diamond.txt").each_line do |line|
# 	line = line.split(',')
# 	pfam = line[0].scan(/(PF\d\d\d\d\d)/)[0][0]
# 	count = line[1].chomp
# 	f.puts "#{pfam},#{count}"
#     end
#   }
# end

# 
# krona_arr = []
# File.open(ARGV[0]).each do |row|
#   next if row[0] == '#'
#   row = row.split("\t")
#   count = row[0]
#   kingdom = row[1]
#   phylum = row[2] =~ /Unknown/ ? 'Unknown' : row[2]
#   clas = row[3]=~ /Unknown/ ? 'Unknown' : row[3]
#   order = row[4]=~ /Unknown/ ? 'Unknown' : row[4]
#   family = row[5]=~ /Unknown/ ? 'Unknown' : row[5]
#   genus = row[6]=~ /Unknown/ ? 'Unknown' : row[6]
#   
#   krona_arr.push([count,kingdom,phylum,clas,order,family,genus]) if count != 0.0
# end
# 
# 
#   puts "#frequency\tsuperkingdom\tphylum\tclass\torder\tfamily\tgenus"
#   krona_arr.each do |row|
#   row.each do |item|
#     print "#{item}\t"
#   end
#   puts "\t"
# end

require_relative 'modules/preprocess_summary'

Preprocess_summary.summary(ARGV)