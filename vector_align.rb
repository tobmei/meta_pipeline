require '/work/gi/coop/perner/metameta/scripts/paths'

Dir.foreach("/scratch/gi/coop/perner/metameta/vents") do |project| 
  next if project == '.' or project == '..' #or project != 'xie' #or project == 'anantharaman' or project == 'axial_seamount_unpublished' or project == 'cayman_rise_unpublished'
  Dir.foreach("/scratch/gi/coop/perner/metameta/vents/#{project}") do |vent| 
    next if vent == '.' or vent == '..' or vent != '4143-1'
    puts vent
    dir = "/scratch/gi/coop/perner/metameta/vents/#{project}/#{vent}/raw_reads"
    Dir.glob("#{dir}/*.fastq.gz") do |run|
      run_nr = File.basename(run.sub('.fastq.gz',''))
      puts run_nr
      puts `#{Paths.samtools} view #{dir}/align.sam | ruby #{Paths.filter_seq_identity}`#{Paths.samtools} view -| head -10
    end
  end
end
