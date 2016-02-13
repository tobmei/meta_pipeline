require 'csv'
require '/work/gi/coop/perner/metameta/scripts/paths'

csv_hash = Hash.new

Dir.foreach("#{Paths.vents}") do |project| 
  next if project == '.' or project == '..' #or project != 'axial_seamount_unpublished' #or project == 'anantharaman' or project == 'axial_seamount_unpublished' or project == 'cayman_rise_unpublished'
  Dir.foreach("#{Paths.vents}/#{project}") do |vent| 
    next if vent == '.' or vent == '..' #or vent != 'marshmallow'
    dir ="#{Paths.vents}/#{project}/#{vent}/raw_reads"
    Dir.glob("#{dir}/*.fastq.gz") do |run|
      csv_array = ["#{project} (#{vent}: #{File.basename(run.sub('.fastq.gz',''))})"]
      next if run == '.' or run == '..' 
      puts run
      if !File.exist?("#{run.sub('.fastq.gz','')}_fastqc/fastqc_data.txt")
        STDERR.puts "#{run.sub('.fastq.gz','')}_fastqc/fastqc_data.txt not found"
        exit 1
      end
      File.open("#{run.sub('.fastq.gz','')}_fastqc/fastqc_data.txt", 'r') do |file|
	string  = file.read
	modules = string.scan(/>>(.*?)>>END_MODULE/m)
	modules.each do |modul|
	  modul = modul[0].split("\n")
	  #print modul
	  modul.each do |line|
	    split = line.split("\t")
	    next if split[0] == 'Per tile sequence quality'
	    csv_array.push(split[1]) if split[1] == 'warn' or split[1] == 'fail' or split[1] == 'pass'
	    next if split[1] == 'pass'  
	    #csv << [line]
	  end	
	end
	csv_hash[run] = csv_array
      end
    end
  end
end



CSV.open('fastqc_summary.csv', 'a+') do |csv|
  csv << [' ', 'Basic Statistics', 'Per base sequence quality', 'Per sequence quality scores', 'Per base sequence content', 'Per sequence GC content', 'Per base N content', 'Sequence Length Distribution', 'Sequence Duplication Levels', 'Overrepresented sequences','Adapter Content','Kmer Content']
  csv_hash.each do |key, value|
    csv <<  value
  end
end 
  