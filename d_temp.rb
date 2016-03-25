require_relative 'combine_functional_profiles'

ARGV.each do |vent|

  summary = combine("#{vent}/profiles/functional/diamond",'diamond')

end
