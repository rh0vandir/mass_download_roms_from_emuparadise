#!/bin/bash

echo "Welcome to the Rom Massdownloader for Emuparadise"

# check if dtrx is installed
if ! pip3 list | grep dtrx > /dev/null 2>&1;  
  then 
    echo "Please install drtx for archive extration."
    echo "pip3 install drtx"
  fi

echo 'Please got to the List of all Games of the desired Consoles ROMs'
echo; echo "https://www.emuparadise.me/roms-isos-games.php"
echo 'Select the desired Console then "List all Titles"'

# Getting user inputs
read -p "Please paste the URL of the list of all games:  " allgameslisturl
echo "Please select which the region of games you want to download: "
read -p "Available regions Europe | Japan | USA | Germany : " region

# Writing list of game and getting ids
if echo $allgameslisturl | grep http  > /dev/null 2>&1
 then
  idlist=( $(curl --silent "$allgameslisturl" 2>&1 | grep $region |awk -F/ '{for(i=1;i<=NF;i++) print $i}' | grep $region | grep -oE '([0-9]+["])' | tr -d '"') )
 else
  idlist=( $(curl --silent "https://$allgameslisturl" 2>&1 | grep $region |awk -F/ '{for(i=1;i<=NF;i++) print $i}' | grep $region | grep -oE '([0-9]+["])' | tr -d '"') )
 fi
 
 Gamecount=${#idlist[@]}
 echo "$(date +"%T") Found $Gamecount games, starting to iterate through gameIDs"

for i in "${idlist[@]}"
   do

    # Define emuparadise rom ID to be downloaded
	gameId=$i

	# The url where to start
	url="https://www.emuparadise.me/roms/get-download.php?gid=${gameId}&test=true"

	# Needed cookie to please referal protection
	cookie='_ga=GA1.2.312033907.1546609825; _gid=GA1.2.1610492985.1546609825; OX_plg=pm; __gads=ID=c721805b270b1676:T=1546609828:S=ALNI_MZFHHvKIhTO5Q04HAiU6bpSlfg-UQ; refexception=1'

	# Get the url of the zip
	location=$(curl -s -I -X GET $url -H "cookie: ${cookie}" -b "${cookie}" | grep -o -E 'location:.*$' | sed -e 's/location://')

	# Extract the filename and remove extension
	filename="${location##*/}"
	Ext=${filename##*.}
	Name=`basename "$filename" ".$Ext"`
	echo "$(date +"%T") Found $Name"
	
	# Remove unwanted line endings
	filename=${filename//[$'\t\r\n ']}	
	
	
	# Is the Game already downloaded? 
	if find . -maxdepth 1 -type f | grep "$Name"  > /dev/null 2>&1
		then 
			echo "$(date +"%T") Game already downloaded, skipping $Name"
		else
			echo "$(date +"%T") Starting download of $filename"
			# Download archive as filename
			curl -L -o $filename -X GET $url -H "cookie: ${cookie}" -b "${cookie}"
		
			echo "$(date +"%T") Download finished"
			echo "$(date +"%T") Starting unzip"
	
			# Unzip it
			dtrx  -qf $filename
			sleep 1
			
			# Remove arvchiv if extraction was successfull
			FileCount=`find . -maxdepth 1 -type f | grep  -e "$Name" -e "$filename" -c`
			if [ "$FileCount" -eq "2" ] 
				then
					echo "$(date +"%T") Rom extraced successfully from $filename, removing the archive."
					rm $filename
				else
					echo "$(date +"%T") Failed archiv extraction, keeping original archive."
			fi
			
	fi
	
done
