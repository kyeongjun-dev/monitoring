port=$1
while true
do
    curl -s "localhost:$port" > /dev/null &
    curl -s "localhost:$port/ip" > /dev/null &
    curl -s "localhost:$port/delay?delay=1" > /dev/null &
    curl -s "localhost:$port/delay?delay=3" > /dev/null &
    curl -s "localhost:$port/delay?delay=5" > /dev/null &
    sleep 1
done
