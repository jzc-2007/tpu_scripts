# initialize and set up remote TPU VM

source ka.sh # import VM_NAME, ZONE

echo $VM_NAME $ZONE


gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE \
--worker=all --command "
$CONDA_PY_PATH -c 'from jax.lib import xla_bridge; print(xla_bridge.get_backend().platform)'
$CONDA_PY_PATH -c 'import jax; print(jax.devices())'
$CONDA_PY_PATH -c 'import flax.nnx as nn; print(nn.Linear); print(nn.__file__)'
"
