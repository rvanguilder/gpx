# Function to calculate the distance between two points

function atan(x) { return atan2(x,1) }
function acos(x) { return atan2(sqrt(1-x*x), x) }
function deg2rad(Deg){ return ( 4.0*atan(1.0)/180 ) * Deg }
function rad2deg(Rad){ return ( 45.0/atan(1.0) ) * Rad }

# Distance(lat1,lon1,lat2,lon2)
     
#    lat1, lon1 = Latitude and Longitude of point 1 (in decimal degrees)  
#    lat2, lon2 = Latitude and Longitude of point 2 (in decimal degrees)  

function distance(lat1, lon1, lat2, lon2) {
	theta = lon1 - lon2
	dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) +  cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta))
	dist = acos(dist)
	dist = rad2deg(dist)
	miles = dist * 60 * 1.1515
	return miles
}

function time_elapsed(start, end) {
	groups = "^(....)-(..)-(..).(..):(..):(..).*"
	format = "\\1 \\2 \\3 \\4 \\5 \\6"

	datespec = gensub(groups, format, "g", start)
	timestamp = mktime(datespec)
	sub(/.*\./,"",start)
	sub(/Z/,"",start)
	start = timestamp "." start

	datespec = gensub(groups, format, "g", end)
	timestamp = mktime(datespec)
	sub(/.*\./,"",end)
	sub(/Z/,"",end)
	end = timestamp "." end

	#return end " - " start
	return (end - start) / 3600
}

BEGIN{
	FS=",";
	print "lat,lon,elevation,time,distance_delta,total_distance,time_delta,total_time,speed,avg_speed,elavation_delta,total_ascent,total_descent";
	total_ascent = 0;
	total_descent = 0;
	minimum_elevation = 10000;
	maximum_elevation = 0;
};
{
	if(lat) {

		distance_delta= distance(lat, lon, $1, $2)
		if(distance_delta != "-nan")
			total_distance = total_distance + distance_delta

		time_delta = time_elapsed(time, $4)
		total_time = total_time + time_delta

		elevation_delta = $3 - elevation
		if(elevation_delta > 0) {
			total_ascent = total_ascent + elevation_delta
		}
		else {
			total_descent = total_descent + elevation_delta
		}

		if(time_delta == 0)
			speed = "NaN"
		else
			speed = distance_delta / time_delta
		
		avg_speed = total_distance / total_time

		print $1 "," $2 "," $3 "," $4 "," distance_delta "," total_distance "," time_delta "," total_time "," speed ","  avg_speed "," elevation_delta "," total_ascent "," total_descent
	}
	else
		print $0
	
	lat=$1; lon=$2; elevation=$3; time=$4
	
	if(starting_elevation == "")
		starting_elevation = elevation
	
	#if(length(starting_time) == 0)
	#	starting_time = time
	
	if(minimum_elevation > elevation)
		minimum_elevation = elevation
	
	if(maximum_elevation < elevation)
		maximum_elevation = elevation
		
};
END{
	elevation_change = (elevation - starting_elevation) * 3.28084
	minimum_elevation = minimum_elevation * 3.28084
	maximum_elevation = maximum_elevation * 3.28084
	total_ascent = total_ascent * 3.28084
	total_descent = total_descent * 3.28084
	#total_time_elapsed = time_elapsed(starting_time, time)
	print "\nSummary Information\n\nTotal Time: " total_time " hours\nTotal Distance: " total_distance " miles\nAverage Speed: " avg_speed " mph\nMinimum Elevation: " minimum_elevation " feet\nMaximum Elevation: " maximum_elevation " feet\nElevation Change: " elevation_change " feet\nTotal Ascent: " total_ascent " feet\nTotal Descent: " total_descent " feet\n"
}

