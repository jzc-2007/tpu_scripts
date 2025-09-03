# Run job in a remote TPU VM
# source ka.sh # import VM_NAME, ZONE

if [ -z "$1" ]; then
    source ka.sh # import VM_NAME, ZONE
else
    echo use command line arguments
    export VM_NAME=$1
    export ZONE=$2

    if [[ $VM_NAME == *"v4"* ]]; then
        export ZONE=us-central2-b
    elif [[ $VM_NAME == *"v3"* ]]; then
        export ZONE=europe-west4-a
    else
        if [[ $VM_NAME == *"v2-32-4"* ]]; then
            export ZONE=europe-west4-a
        elif [[ $VM_NAME == *"v2-32-preemptible-2"* ]]; then
            export ZONE=europe-west4-a
        else
            export ZONE=us-central1-a
        fi
    fi
    if [[ $VM_NAME == *"v6e"* ]]; then
        export ZONE=us-east1-d
    fi
    if [[ $VM_NAME == *"v5e"* ]]; then
        export ZONE=us-central1-a
    fi

    if [[ $ZONE == *"europe"* ]]; then
        export DATA_ROOT="kmh-nfs-ssd-eu-mount"
        # export TFDS_DATA_DIR='gs://kmh-gcp/tensorflow_datasets'  # use this for imagenet
        export TFDS_DATA_DIR='/kmh-nfs-ssd-eu-mount/code/hanhong/dot/tensorflow_datasets'
        export USE_CONDA=1
    else
        export DATA_ROOT="kmh-nfs-us-mount"
        export USE_CONDA=1
        # export TFDS_DATA_DIR='gs://kmh-gcp-us-central2/tensorflow_datasets'  # use this for imagenet
        export TFDS_DATA_DIR='/kmh-nfs-us-mount/data/tensorflow_datasets'
    fi

    if [[ $USE_CONDA == 1 ]]; then
        export CONDA_PY_PATH=/$DATA_ROOT/code/qiao/anaconda3/envs/$OWN_CONDA_ENV_NAME/bin/python
        echo $CONDA_PY_PATH
    fi

fi

echo $VM_NAME $ZONE

gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE \
    --worker=all --command "
python -m wandb login $WANDB_API_KEY
sleep 1
python -m wandb login
echo \$?
"