require 'zlib'

ARGV.each do |vent|
  diamond = "#{vent}/profiles/functional/diamond"
  uproc = "#{vent}/profiles/functional/uproc"
  next if Dir["#{vent}/profiles/functional/diamond/*"].empty?
  puts "#{vent}"
  run_nr = nil
  Dir.glob("#{diamond}/*.gz") do |matches|  
    run_nr = File.basename(matches.sub('_matches.tab.gz',''))
    infile = open(matches)
    uproc_file = File.open("#{uproc}/#{run_nr}_uproc_all.txt")
    gz = Zlib::GzipReader.new(infile)
    class_count = 0 
    old_id = ''
    pfam_hash = Hash.new
    i = 0
    curr_id = ul_id = old_hit = l = nil
    next_id = next_ul = true
    loop = true
    while loop
      loop = false
      
      if next_id
	gz.each_line do |line|
	  loop = true
	  l = line.split("\t")
	  curr_id = l[0].scan(/\.(\d*)/)[0][0].to_i
	  if old_id != curr_id
	    old_id = curr_id
	    break
	  end
	end
      end
      
      if next_ul
	uproc_file.each_line do |uline|
	  loop = true
	  ul_id = uline.split(",")[1].scan(/\.(\d*)/)[0][0].to_i
          break
	end
      end
      
      if curr_id == ul_id
	pfam = l[1].scan(/(PF\d\d\d\d\d)/)[0][0]
	pfam_hash[pfam] = pfam_hash[pfam] == nil ? 1 : pfam_hash[pfam]+1
	old_hit = curr_id 
	next_id = next_ul = true
      elsif curr_id < ul_id
	next_id = true
	next_ul = false
      elsif curr_id > ul_id
	next_id = false
	next_ul = true
      end
      
#         break if class_count > 10
	i+=1
    end
    
#     puts class_count
    pfam_sorted = pfam_hash.sort_by {|key, value| -value}

    File.open("#{vent}/profiles/functional/diamond/#{run_nr}_diamond_uproc.txt", 'w') { |file| 
      pfam_sorted.each do |i|
        file.write "#{i[0]},#{i[1]}\n"
      end
    }
    
    infile.close
  end
end



