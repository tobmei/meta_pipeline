

Dir.foreach('/scratch/gi/coop/perner/metameta/vents/') do |vent| 
  next if vent == '.' or vent == '..' or vent != 'marker113'
  puts vent
  Dir.glob('/scratch/gi/coop/perner/metameta/vents/'+vent+'/*.sra') do |item|
    #next if File.directory?('/scratch/gi/coop/perner/metameta/vents/'+vent+'/'+File.basename(item,'.fastq.gz')+'_fastqc')
    puts File.basename(item, '.sra')
    #puts item
    #%x{#{'/work/gi/software/fastqc-0.11.3/./fastqc --extract '+item}}
    %x{#{'/work/gi/software/sratoolkit.2.3.2-ubuntu64/bin/./fastq-dump --split-3 --skip-technical --gzip -O /scratch/gi/coop/perner/metameta/vents2/'+vent+'/ '+item}}#/scratch/gi/coop/perner/metameta/vents2/#{name}/*} 
    #%x{'mv #{item} /scratch/gi/coop/perner/metameta/fastqc/'}
  end
end 
