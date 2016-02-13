
# sum=0
ARGF.each do |line|
  split_line = line.split("\t")
  next if split_line[1] == '256' #exclude alternative mapping when multiple mappings are present 
  if split_line[3] == '0' || split_line[0] =~ /^@/ #unaligned sequence or header
    puts line
    next
  end
  
  #parse cigar string
  read = split_line[9]
  nm = split_line[11].scan(/(\d)/)[0][0].to_i
  m = split_line[5].scan(/(\d+)M/)
  i = split_line[5].scan(/(\d+)I/)
  d = split_line[5].scan(/(\d+)D/)
  s = split_line[5].scan(/(\d+)S/)
  
  m_sum = m.inject(0){|sum,x| sum + x[0].to_i}
  i_sum = i.inject(0){|sum,x| sum + x[0].to_i}
  d_sum = d.inject(0){|sum,x| sum + x[0].to_i}
  s_sum = s.inject(0){|sum,x| sum + x[0].to_i}
  
  #percentage of the read that is part of the alignment
  query_coverage = 100 * ((read.size.to_f-s_sum.to_f)/read.size.to_f)
  #percentage of sequence identity
  identity = 100 * (i_sum+m_sum-nm).to_f/(read.size-s_sum).to_f
  #only output reads with >= 80% query coverage and >= 80% sequence identity 
  if query_coverage >= 80.0 && identity >= 80.0   
    puts line
#     sum += 1
  end
end
