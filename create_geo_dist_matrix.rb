
#This script claculates the distance between to points defined 
#by latitude and longitude based on the haversine formula
#Not used in the pipeline

    

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