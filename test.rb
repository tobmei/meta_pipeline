require_relative 'modules/helper'


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
init = Helper.parse_init_file('/work/gi/coop/perner/metameta/scripts/seq_meta.tsv')
print init

      
