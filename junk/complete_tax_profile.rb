tax_hash = Hash.new
ARGV.each do |vent|
  profiles_dir = "#{vent}/profiles/Taxy"
  next if !File.exists?("#{profiles_dir}/complete.csv")  
  tax_file = ("#{profiles_dir}/complete.csv")  
  ve = File.basename(vent)
  File.open(tax_file).each do |line|
    line = line.split("\t")
    next if line[0] == '#frequency'
    freq = line[0].to_f
    species = line[7].chomp
    tax_hash[species] = 0 if tax_hash[species] == nil
    tax_hash[species] += freq
  end
end

puts "species,freqsum"
tax_hash.each do |species,freqsum|
#   pfam_desc = `grep #{pfam} data/Pfam-A.clans.tsv | cut -f 5`.chomp
#   pfam_desc = pfam_desc.length > 30 ? "#{pfam_desc[0..30]}..." : pfam_desc
  puts "#{species},#{freqsum}"
end
  