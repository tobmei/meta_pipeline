
sum = 0
ARGF.each do |line|
  line = line.split(',')
  sum += line[1].to_i
end
puts sum