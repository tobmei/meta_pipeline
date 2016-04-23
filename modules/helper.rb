require 'mkmf'

module Helper
  
  def Helper.parse_init_file(file)
    init = Hash.new
    File.open(file).each_line do |line|
      line = line.split("\t")
      next if line[0] == 'vent'
      vent = line[0]
      platform = line[1]
      fosmid_based = line[2]
      adapter_seq = line[3]
      pfam2go = line[4]
      if vent == nil || vent == '' || platform == nil || fosmid_based == nil || fosmid_based == ''
	      STDERR.puts "Error while parsing init file. Empty field detected"
	      exit 1
      end
      if adapter_seq != nil && adapter_seq != '' && (adapter_seq =~ /^[actgACTG]+$/) == nil
	      STDERR.puts "Error in init file. Nonvalid nucleotide sequence: #{adapter_seq}"
	      exit 1
      end
      init[vent] = Hash.new
      init[vent][:platform] = platform
      init[vent][:fosmid_based] = fosmid_based 
      init[vent][:adapter_seq] = adapter_seq
      init[vent][:pfam2go] = pfam2go
    end
    return init
  end
  
  def Helper.parse_summary_file(file)
    summary = Hash.new
    File.open(file).each_line do |line|
      line = line.split(",")
      next if line[0] == 'vent'
      vent = line[0].chomp
      avg_length = line[4].chomp
      if vent == nil || avg_length == nil || avg_length == ''
	      STDERR.puts "Error while parsing summary file. Empty field detected"
	      exit 1
      end
      summary[vent] = avg_length
    end
    return summary
  end
  
end

