
module Prot_seq_classification
  def Prot_seq_classification.classify(run, outdir, seq_meta)
    
    if seq_meta == nil || seq_meta[:avg_length] == ''
      puts "Warning: no avg_length found in meta file. Proceeding with default value"
      length = '-l'
    else
      length = seq_meta[:avg_length].to_i <= 200 ? '-s' : '-l'
    end
    puts length
    run_nr = File.basename(run.sub('.fastq.gz',''))
   # `uproc-dna -f -P 2 -c #{length} data/pfam27_uproc data/model #{run} > #{outdir}/#{run_nr}_uproc_lessrestricitve.txt`
#     `#{Paths.uproc}./uproc-dna -p #{length} #{Paths.pfam27_uproc} #{Paths.model_uproc} #{run} > #{outdir}/#{run_nr}_uproc_all.txt`
     `uproc-dna -f #{length} data/pfam27_uproc data/model #{run} > #{outdir}/#{run_nr}_uproc.txt`
  end
end
