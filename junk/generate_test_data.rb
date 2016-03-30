 

hash = Hash.new
ARGV.each do |vent|
  uproc = "#{vent}/profiles/functional/uproc"
  diamond = "#{vent}/profiles/functional/diamond"
  
  File.open("#{uproc}/uproc.txt", 'r').each do |line|
    line = line.split(',')	
    hash[line[0].scan(/(PF\d\d\d\d\d)/)[0][0]] = line[1].chomp
  end

  File.open("#{diamond}/diamond.txt", 'r').each do |line|
    line = line.split(',')
    pfam = line[0].scan(/(PF\d\d\d\d\d)/)[0][0]
    hash[pfam] = (line[1].chomp.to_i - hash[pfam].to_i) / (line[1].chomp.to_i + hash[pfam].to_i).to_f
  end

  File.open('stats/test.txt', 'w') { |f|
    hash.each do |k,v|
      f.puts "#{k},#{v}"
    end
  }
end