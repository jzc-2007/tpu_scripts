# initialize and set up remote TPU VM
# source ka.sh # import VM_NAME, ZONE

# test whether $1 is empty
if [ -z "$1" ]; then
    exit 2
else
    echo use command line arguments
    export VM_NAME=$1
    export ZONE=$2
fi

echo $VM_NAME $ZONE

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
    export CONDA_INIT_SH_PATH=/$DATA_ROOT/code/qiao/anaconda3/etc/profile.d/conda.sh
    export CONDA_ENV=NNX
fi
# if is preemptible, check if it is preempted

if [[ $VM_NAME == *"preemptible"* ]]; then
    if [ "$(gcloud compute tpus describe $VM_NAME --zone=$ZONE --format="value(state)")" == "READY" ]; then
        echo "preemptible TPU $VM_NAME is ready"
    else
        echo "TPU is preempted."
        exit 3
    fi
fi

gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE \
--worker=all --command "
if [ \"$USE_CONDA\" -eq 1 ]; then
    echo 'Using conda'
    source $CONDA_INIT_SH_PATH
    conda activate $CONDA_ENV
fi
python3 -c 'import jax; import flax.linen as nn; print(nn.Dense)'
"

# check whether return code is 0
if [ $? -eq 0 ]; then
    echo "TPU VM $VM_NAME env is good"
else
    echo "TPU env is broken"
    exit 4
fi

gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE \
--worker=all --command "
if [ \"$USE_CONDA\" -eq 1 ]; then
    echo 'Using conda'
    source $CONDA_INIT_SH_PATH
    conda activate $CONDA_ENV
fi
python3 -c 'import jax; print(jax.devices())'
"

# check whether return code is 0
if [ $? -eq 0 ]; then
    echo "TPU VM $VM_NAME is xian"
    exit 0
else
    echo "TPU is running"
    exit 1
fi