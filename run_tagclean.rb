tag = ''
seq = ''

ARGF.each do |line|
  split_line = line.split("\t")
  next if split_line[0] =~ /^#/  
#   next if split_line[2].to_i < 5
  next if split_line[3].to_i <= 10
  
  tag = split_line[0]
  seq = split_line[1]
  puts tag
  puts seq
end

