

def combine(profiles_dir, out)

  profile = Hash.new
  classification_summary = Hash.new
  classification_summary[:classified] = 0 
  classification_summary[:unclassified] = 0 
  classification_summary[:total] = 0 
  Dir.glob("#{profiles_dir}/*.txt") do |file| 
    File.open(file).each_line do |line|
      l = line.split(',')
      if l.size == 3
        classification_summary[:classified] += l[0].chomp.to_i
        classification_summary[:unclassified] += l[1].chomp.to_i
        classification_summary[:total] += l[2].chomp.to_i
      else
        fam = l[0]
        freq = l[1].chomp.to_i
        profile[fam] = 0 if profile[fam] == nil
        profile[fam] += freq
      end
    end    
  end
  
  profile = profile.sort_by{|k, v| v}.reverse
  
  #TODO load pfamaclans into memory (hash) instead of grepping
  File.open("#{profiles_dir}/#{out}.txt", 'w') { |f|
    profile.each do |fam,freq|
#       pfam_desc = `grep #{fam} data/Pfam-A.clans.tsv | cut -f 5`.chomp
#       pfam_desc = pfam_desc.length > 30 ? "#{pfam_desc[0..30]}..." : pfam_desc
#       f.puts "#{pfam_desc.gsub(',',' ')}(#{fam}),#{freq}"
      f.puts "#{fam},#{freq}"
    end
  }
  
  return classification_summary
  
end
