file="./varsin_prop.txt"
lines=`cat $file`
for line in $lines; do
	        grep -a "^ERROR.*$line" ./logfile.txt 
	done
