module Preprocess_summary

  def Preprocess_summary.summary(vents)
    summary = Hash.new
    
    vents.each do |vent|
      vent_name = File.basename(vent)
      summary[vent_name] = Hash.new
      
      ['raw','preprocessed'].each do |mode|
        summary[vent_name]["sequences_#{mode}"] = 0 
        summary[vent_name]["total_length_#{mode}"] = 0 
        avg_length = []
        Dir.glob("#{vent}/#{mode}_reads/*.fastq.gz") do |run|
          run_nr = File.basename(run.sub('.fastq.gz',''))
          result = `gt seqstat -distlen #{run}`
          result = result.split('\n')
          next if result[0] == nil
          avg_length.push(result[0].scan(/length (\d+\.\d+)/)[0][0])
          summary[vent_name]["sequences_#{mode}"] += result[0].match(/[\d]+/)[0].to_i
          summary[vent_name]["total_length_#{mode}"] += (result[0].scan(/total length ([\d]+)/)[0][0]).to_i
        end
        avg_length_avg = avg_length.inject(0){|sum,x| sum + x.to_f}.to_f / avg_length.size 
        summary[vent_name]["avg_length_#{mode}"] = avg_length_avg
      end
      
    end
    
    #TODO write summary to file 
    
  end
end
