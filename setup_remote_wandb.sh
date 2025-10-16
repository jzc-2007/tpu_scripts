# Run job in a remote TPU VM
source ka.sh # import VM_NAME, ZONE

echo $VM_NAME $ZONE

gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE \
    --worker=all --command "
$CONDA_PY_PATH -m wandb login $WANDB_API_KEY
sleep 1
$CONDA_PY_PATH -m wandb login
echo \$?
"