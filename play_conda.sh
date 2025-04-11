# 卡.sh
source config.sh

if [ -z "$OWN_CONDA_ENV_NAME" ]; then
    echo "Please set your own config.sh. See README for reference"
    sleep 60
    exit 1
fi

if [ -z "$TASKNAME" ]; then
    echo "Please set your own config.sh. See README for reference"
    sleep 60
    exit 1
fi

# specify your TPU VM name here!

############## TPU VMs ##############

# export VM_NAME=kmh-tpuvm-v2-32-1
# export VM_NAME=kmh-tpuvm-v2-32-2
# export VM_NAME=kmh-tpuvm-v2-32-3
# export VM_NAME=kmh-tpuvm-v2-32-4
# export VM_NAME=kmh-tpuvm-v2-32-5
# export VM_NAME=kmh-tpuvm-v2-32-6
# export VM_NAME=kmh-tpuvm-v2-32-7
export VM_NAME=kmh-tpuvm-v2-32-8
# export VM_NAME=kmh-tpuvm-v3-32-1
# export VM_NAME=kmh-tpuvm-v4-8-6
# export VM_NAME=kmh-tpuvm-v2-32-preemptible-1
# export VM_NAME=kmh-tpuvm-v2-32-preemptible-2
# export VM_NAME=kmh-tpuvm-v3-32-preemptible-1
# export VM_NAME=kmh-tpuvm-v4-32-preemptible-1
# export VM_NAME=kmh-tpuvm-v4-32-preemptible-2
# export VM_NAME=kmh-tpuvm-v3-32-11
# export VM_NAME=kmh-tpuvm-v3-32-12
# export VM_NAME=kmh-tpuvm-v3-32-13

#####################################

# Zone: your TPU VM zone

# Zone: your TPU VM zone
if [[ $VM_NAME == *"v4"* ]]; then
    export ZONE=us-central2-b
elif [[ $VM_NAME == *"v3"* ]]; then
    export ZONE=europe-west4-a
else
    if [[ $VM_NAME == *"v2-32-4"* ]]; then
        export ZONE=europe-west4-a
    elif [[ $VM_NAME == *"v2-32-preemptible-1"* ]]; then
        export ZONE=europe-west4-a
    else
        export ZONE=us-central1-a
    fi
fi

# DATA_ROOT: the disk mounted
# FAKE_DATA_ROOT: the fake data (imagenet_fake) link
# USE_CONDA: 1 for europe, 2 for us (common conda env)

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
    # export CONDA_PATH=$(which conda)
    # export CONDA_INIT_SH_PATH=$(dirname $CONDA_PATH)/../etc/profile.d/conda.sh
    export CONDA_INIT_SH_PATH=/$DATA_ROOT/code/qiao/anaconda3/etc/profile.d/conda.sh
    export CONDA_ENV=$OWN_CONDA_ENV_NAME
fi


echo $VM_NAME $ZONE


# if [ \"$USE_CONDA\" -eq 1 ]; then
#     echo 'Using conda'
#     source $CONDA_INIT_SH_PATH
#     echo tmp 1
# fi

gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE \
--worker=all --command "
if [ $USE_CONDA -eq 1 ]; then
    echo 'Using conda'
    source $CONDA_INIT_SH_PATH
    echo tmp 1
    conda activate $CONDA_ENV
    echo activated
fi
"

# which python3
# which pip3
# /kmh-nfs-us-mount/code/qiao/anaconda3/envs/NNX/bin/python3 -c 'import flax.nnx as nn; print(nn.Linear)'

# /kmh-nfs-us-mount/code/qiao/anaconda3/envs/NNX/bin/python3 -c 'print(114514 + 1919810)'

# /kmh-nfs-us-mount/code/qiao/anaconda3/envs/NNX/bin/python3 -c 'import flax.nnx as nn; print(nn.Linear)'
# /kmh-nfs-ssd-eu-mount/code/qiao/anaconda3/envs/NNX/bin/python3 -c 'import flax.nnx as nn; print(nn.Linear); print(nn.__file__)'

# python3 -c 'import flax.nnx as nn; print(nn.Linear)'

# pip install wandb
    # conda activate $CONDA_ENV
