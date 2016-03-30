require_relative 'modules/helper'
require_relative 'modules/downstream_helper'
require_relative 'modules/stamp'
require_relative 'combine_functional_profiles'


# new_vents = Helper.check_vents(ARGV[0])

# if new_vents.size > 0
#   puts 'New vents found:'
#   new_vents.each do |vent|
#     puts "-#{vent}"
#   end
# else
#   puts 'No new vents found'
# end

# Helper.check_requirements
# init = Helper.parse_init_file('/work/gi/coop/perner/metameta/scripts/seq_meta.tsv')
# print init


# Downstream_analysis.generate_taxonomic_profile_matrix(ARGV,'/scratch/gi/coop/perner/metameta/stats/profiles')
# Downstream_helper.generate_functional_profile_matrix(ARGV,'/scratch/gi/coop/perner/metameta/stats')

      
# funcprof_file = "/scratch/gi/coop/perner/metameta/stats/profiles/functional_profile.csv"
# if !File.exists?(funcprof_file)
#   STDERR.puts "File #{funcprof_file} not found. There was propably an error while generating it. This is not good."
#   exit 1
# end
# `Rscript R/ordination.r #{funcprof_file} /scratch/gi/coop/perner/metameta/stats/vents_meta.tsv /scratch/gi/coop/perner/metameta/stats/plots/functional_profile_`


# cats = Downstream_analysis.get_anosim_categories("/scratch/gi/coop/perner/metameta/stats/vents_meta.tsv")
# funcprof_file = "/scratch/gi/coop/perner/metameta/stats/profiles/functional_profile.csv"
# taxprof_file = "/scratch/gi/coop/perner/metameta/stats/profiles/taxonomic_profile_species_level.csv"
# [funcprof_file,taxprof_file].each do |file|
#   if !File.exists?(file)
#     STDERR.puts "File #{file} not found. There was propably an error while generating it. This is not good."
#     exit 1
#   end
# end
# `Rscript R/ordination.r #{funcprof_file} /scratch/gi/coop/perner/metameta/stats/vents_meta.tsv /scratch/gi/coop/perner/metameta/stats/plots/functional_profile_ #{cats}`
# `Rscript R/ordination.r #{taxprof_file} /scratch/gi/coop/perner/metameta/stats/vents_meta.tsv /scratch/gi/coop/perner/metameta/stats/plots/taxonomic_profile_ #{cats}`


# cats.each do |cat|
#   bla = `Rscript R/anosim.r #{taxprof_file} /scratch/gi/coop/perner/metameta/stats/vents_meta.tsv #{cat}`
# #   print bla
# bla.split("\n").each do |b|
#   puts b.split(' ')[1]
# end
# end
cats = Downstream_helper.get_anosim_categories('/scratch/gi/coop/perner/metameta/stats/vents_meta.tsv')
# print cats

# anosim_arr1 = []
# anosim_arr2 = []
# cats.each do |cat|
#   cat = cat.gsub(' ','_')
#   result1 = `Rscript R/anosim.r #{taxprof_file} /scratch/gi/coop/perner/metameta/stats/vents_meta.tsv #{cat}`
#   result2 = `Rscript R/anosim.r #{funcprof_file} /scratch/gi/coop/perner/metameta/stats/vents_meta.tsv #{cat}`
#   anosim_arr1.push(result1)
#   anosim_arr2.push(result2)
# end
# Downstream_analysis.write_anosim_results(anosim_arr1,"/scratch/gi/coop/perner/metameta/stats/taxonomic_profile_")
# Downstream_analysis.write_anosim_results(anosim_arr2,"/scratch/gi/coop/perner/metameta/stats/functional_profile_")

# ARGV.each do |vent|
#   v = File.basename(vent)
#   tax_file = "#{vent}/profiles/taxonomic/Taxy/complete.csv"
#   func_file = "#{vent}/profiles/functional/uproc/uproc.txt"
#   if !File.exists?(tax_file) || !File.exists?(func_file)
#     puts "Profile file not found. Skipping this one."
#     next
#   end
#   `Rscript R/taxonomy.r #{tax_file} #{func_file} #{vent}/profiles/taxonomic/Taxy/#{v} #{vent}/profiles/functional/uproc/#{v} `
# end

# ARGV.each do |vent|
#   profile = Hash.new
#   classification_summary = Hash.new
#   classification_summary[:classified] = 0 
#   classification_summary[:unclassified] = 0 
#   classification_summary[:total] = 0 
#   profiles_dir = "#{vent}/profiles/functional/uproc"
#   File.open("#{profiles_dir}/uproc.txt").each_line do |line|
#     l = line.split(',')
#     if l.size == 3
#       classification_summary[:classified] += l[0].chomp.to_i
#       classification_summary[:unclassified] += l[1].chomp.to_i
#       classification_summary[:total] += l[2].chomp.to_i
#     else
#       fam = l[0]
#       freq = l[1].chomp.to_i
#       profile[fam] = 0 if profile[fam] == nil
#       profile[fam] += freq
#     end
#   end    
# 
#   profile = profile.sort_by{|k, v| v}.reverse
#   `rm #{profiles_dir}/uproc_test.txt`
#   #TODO load pfamaclans into memory (hash) instead of grepping
#   CSV.open("#{profiles_dir}/uproc.txt", 'w') do |csv|
#     csv << ['pfam','count']
#     profile.each do |fam,freq|
#   #       pfam_desc = `grep #{fam} data/Pfam-A.clans.tsv | cut -f 5`.chomp
#   #       pfam_desc = pfam_desc.length > 30 ? "#{pfam_desc[0..30]}..." : pfam_desc
#   #       f.puts "#{pfam_desc.gsub(',',' ')}(#{fam}),#{freq}"
#       csv << [fam,freq]
#     end
#   end
# end

# Stamp.stamp_call("/scratch/gi/coop/perner/metameta/stats/profiles/functional_profile_stamp_compatible.csv","/scratch/gi/coop/perner/metameta/stats/vents_meta.tsv","platform")

funcprof_file_stamp = "/scratch/gi/coop/perner/metameta/stats//profiles/functional_profile_stamp_compatible.csv"
taxprof_file_stamp = "/scratch/gi/coop/perner/metameta/stats/profiles/taxonomic_profile_species_level_stamp.csv"

out = "/scratch/gi/coop/perner/metameta/stats"

#stamp
cats.each do |cat|
  Stamp.run(funcprof_file_stamp,"#{out}/vents_meta.tsv",cat,"#{out}/stamp/stamp_funcprof_#{cat}.pdf")
  Stamp.run(taxprof_file_stamp,"#{out}/vents_meta.tsv",cat,"#{out}/stamp/stamp_taxprof_#{cat}.pdf")
end

# Downstream_helper.generate_taxonomic_profile_matrix_stamp(ARGV,"/scratch/gi/coop/perner/metameta/stats/profiles")
















