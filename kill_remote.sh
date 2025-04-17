# if [ -z "$2" ]; then
# 	source ka.sh $1 # import VM_NAME, ZONE
# else
# 	echo use command line arguments
# 	export VM_NAME=$1
# 	export ZONE=$2
# fi

if [ -n "$1" ]; then
	export VM_NAME=$1
	source ka.sh $1
else
	source ka.sh
fi

echo 'To kill jobs in: '$VM_NAME 'in' $ZONE' after 2s...'
sleep 2s

echo 'Killing jobs...'
gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE --worker=all \
    --command "
pgrep -af python | grep 'main.py' | grep -v 'grep' | awk '{print \"sudo kill -9 \" \$1}' | sh
" # &> /dev/null
echo 'Killed jobs.'

# pgrep -af python | grep 'main.py' | grep -v 'grep' | awk '{print "sudo kill -9 " $1}' | sh

# sudo lsof -w /dev/accel0 | grep python | grep -v 'grep' | awk '{print \"sudo kill -9 \" \$2}'
# sudo lsof -w /dev/accel0 | grep python | grep -v 'grep' | awk '{print \"sudo kill -9 \" \$2}' | sh