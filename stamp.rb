

profile = ARGV[0]
metadata = ARGV[1]
field = ARGV[2]


# python commandLine.py --typeOfTest 'Two samples' --profile /work/gi/coop/perner/metameta/meta_pipeline/funcprof.tsv --name1 anantharaman_abe_1_1 --name2 anantharaman_abe_2_2 --statTest "Fisher's exact test" --CI "DP: Newcombe-Wilson" --outputTable /work/gi/coop/perner/metameta/meta_pipeline/results_desc.tsv
# python commandLine.py --typeOfTest "Two groups" --profile /work/gi/coop/perner/metameta/meta_pipeline/funcprof.tsv --metadata /work/gi/coop/perner/metameta/meta_pipeline/stats/vents.csv --field platform --name1 454 --name2 illumina --statTest "t-test (equal variance)" --CI "DP: t-test inverted" --outputTable /work/gi/coop/perner/metameta/meta_pipeline/results_two.tsv

`python /work/gi/software/stamp-2.0.1/commandLine.py --typeOfTest "Multiple groups" --profile #{profile} --metadata #{metadata} --field #{field} --statTest "ANOVA" --outputTable ./stamp_result_temp.tsv`
if $?.exitstatus != 0
  STDERR.puts 'Error!'
  exit 1
end


