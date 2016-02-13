

if ARGV.size == 0
  puts "Usage: blabla"
  exit 0
end

ARGV.each do |dir|
  if !Dir.exists?(dir)
    STDERR.puts "ERROR: Directory #{dir} does not exist."
    exit 1
  end
end
total = 0
puts 'prepro'
puts "vent\t#sequences_raw\tavg_length_raw\ttotal_length_raw\tfosmid_based(y/n)\tplatform\tknown_adapter/tag_seq"
hash = Hash.new
ARGV.each do |vent|
  vent_name = File.basename(vent)
  dir_prepro = "#{vent}/preprocessed_reads"
  dir_raw = "#{vent}/raw_reads"
  
  hash[vent_name] = Hash.new
  hash[vent_name]['sequences_raw'] = 0 
#   hash[vent_name]['sequences_prepro'] = 0 
#   hash[vent_name]['total_length_prepro'] = 0 
  hash[vent_name]['total_length_raw'] = 0 
  avg_length = []
  Dir.glob("#{dir_raw}/*.fastq.gz") do |run|
    run_nr = File.basename(run.sub('.fastq.gz',''))
    result = `gt seqstat -distlen #{run}`
    result = result.split('\n')
    next if result[0] == nil
    avg_length.push(result[0].scan(/length (\d+\.\d+)/)[0][0])
    hash[vent_name]['sequences_raw'] += result[0].match(/[\d]+/)[0].to_i
    hash[vent_name]['total_length_raw'] += (result[0].scan(/total length ([\d]+)/)[0][0]).to_i
  end
  avg_length_avg = avg_length.inject(0){|sum,x| sum + x.to_f}.to_f / avg_length.size  
  hash[vent_name]['avg_length_raw'] = avg_length_avg
  
end
# print hash

hash.each do |vent,h|
  print "#{vent}\t"
  print "#{h['sequences_raw']}\t"
  print "#{h['avg_length_raw']}\t"
  print "#{h['total_length_raw']}\t\n"
end
    
