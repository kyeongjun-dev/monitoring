while true
do
    curl -s "localhost:30008/delay?delay=1" > /dev/null & 
    curl -s "localhost:30008/delay?delay=3" > /dev/null &
    curl -s "localhost:30008/delay?delay=5" > /dev/null &
    sleep 1
done