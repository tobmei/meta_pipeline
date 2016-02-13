    
def haversine(lat1, lon1, lat2, lon2)
  
  dec_lat1,dec_lon1 = to_decimal_degree(lat1,lon1)
  dec_lat2,dec_lon2 = to_decimal_degree(lat2,lon2)
#   puts dec_lat1
#   puts dec_lon1
#   puts dec_lat2
#   puts dec_lon2
  
  deg2rad = Math::PI/180
  r = 6371000

  r_lat1 = dec_lat1 * deg2rad 
  r_lon1 = dec_lon1 * deg2rad 
  r_lat2 = dec_lat2 * deg2rad 
  r_lon2 = dec_lon2 * deg2rad 

  d_lon = r_lon1 - r_lon2
  d_lat = r_lat1 - r_lat2

  a = (Math.sin(d_lat/2)** 2) + Math.cos(r_lat1) * Math.cos(r_lat2) * (Math.sin(d_lon/2)** 2)
  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  d = r * c

  d.round(2)
end

def to_decimal_degree(lat,lon)
  lat = lat.split(' ')
  lon = lon.split(' ')
  
  if lat.size == 2
    dec_lat = lat[1] == 'S' ? -1*lat[0].to_f : lat[0].to_f
  elsif lat.size == 3
    dec_lat = lat[0].to_f + lat[1].to_f/60
    dec_lat = lat[2] == 'S' ? dec_lat*-1 : dec_lat
  end
  
  if lon.size == 2
    dec_lon = lon[1] == 'W' ? -1*lon[0].to_f : lon[0].to_f
  elsif lon.size == 3
    dec_lon = lon[0].to_f + lon[1].to_f/60
    dec_lon = lon[2] == 'W' ? dec_lon*-1 : dec_lon
  end
  
  return dec_lat,dec_lon
end   



#parse meta file
locations = []
File.open(ARGV[0]).each_line do |line|
  line = line.split("\t")
  next if line[0] == 'vent'
  locations.push([line[0],line[7].chomp])
end
i = 0
j = 1
# print locations
while i < locations.size-1
  for k in 0..i
    latlon_k = locations[k][1].split(',')
    latlon_j = locations[j][1].split(',')
    lat_k = latlon_k[0]
    lon_k = latlon_k[1]
    lat_j = latlon_j[0]
    lon_j = latlon_j[1]
    distance = haversine(lat_k,lon_k,lat_j,lon_j)
    print k == i ? "#{distance}" : "#{distance},"
  end
  i += 1
  j += 1
  puts "\n"
end
    
# for i in (0..locations.size-1)
#   for j in (0..locations.size-1)
#     latlon_i = locations[i][1].split(',')
#     latlon_j = locations[j][1].split(',')
#     lat_i = latlon_i[0]
#     lon_i = latlon_i[1]
#     lat_j = latlon_j[0]
#     lon_j = latlon_j[1]
#     distance = haversine(lat_i,lon_i,lat_j,lon_j)
#     print j == locations.size-1 ? "#{distance}" : "#{distance},"
#   end
#   puts "\n"
# end

