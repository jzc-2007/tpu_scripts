source ka.sh # import VM_NAME, ZONE

echo 'solve'
gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE --worker=all \
    --command "
alias python=$CONDA_PY_PATH
alias pip=$CONDA_PIP_PATH
" # &> /dev/null
echo 'solved!'
# ls /home/sqa

# pip3 install tensorstore==0.1.67

# | grep main.py | grep -v 'grep' | awk '{print \"sudo kill -9 \" \$2}' | sh

# sudo lsof -w /dev/accel0 | grep main.py | grep -v 'grep' | awk '{print \"sudo kill -9 \" \$2}' | sh

# pip3 list | grep jax
# pip3 list | grep flax
# pip3 install flax==0.10.2

# pip3 show flax
