
pfams = Hash.new
counts = Hash.new
ARGV.each do |file|
  File.open(file).each_line do |line|
    l = line.split(',')
    if l.size == 3
      counts['classified'] = 0 if counts['classified'] == nil 
      counts['unclassified'] = 0 if counts['unclassified'] == nil 
      counts['total'] = 0 if counts['total'] == nil 
      counts['classified'] += l[0].chomp.to_i
      counts['unclassified'] += l[1].chomp.to_i
      counts['total'] += l[2].chomp.to_i
    else
      fam = l[0]
      freq = l[1].chomp.to_i
      pfams[fam] = 0 if pfams[fam] == nil
      pfams[fam] += freq
    end
  end
end

# puts "#{counts['classified']},#{counts['unclassified']},#{counts['total']}"

pfams = pfams.sort_by{|k, v| v}.reverse
pfams.each do |k,v|
  puts "#{k},#{v}"
end