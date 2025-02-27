source ka.sh # import VM_NAME, ZONE

echo 'solve'
gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE --worker=all \
    --command "
sudo lsof -w /dev/accel0 | grep main.py | grep -v 'grep' | awk '{print \"sudo kill -9 \" \$2}' | sh
" # &> /dev/null
echo 'solved!'
# ls /home/sqa

# pip3 install tensorstore==0.1.67

# | grep main.py | grep -v 'grep' | awk '{print \"sudo kill -9 \" \$2}' | sh