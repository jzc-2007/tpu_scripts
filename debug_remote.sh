# Your configurations here
source config.sh
CONDA_ENV=$OWN_CONDA_ENV_NAME
############# No need to modify #############

source ka.sh

echo Running at $VM_NAME $ZONE

STAGEDIR=/$DATA_ROOT/staging/$(whoami)/debug-$VM_NAME
sudo mkdir -p $STAGEDIR
sudo chmod 777 -R $STAGEDIR
echo 'Staging files...'
sudo rsync -a . $STAGEDIR --exclude=tmp --exclude=.git --exclude=__pycache__ --exclude='*.png' --exclude=wandb
echo 'staging dir: '$STAGEDIR
echo 'Done staging.'

LOGDIR=$STAGEDIR/log
sudo rm -rf $LOGDIR
sudo mkdir -p ${LOGDIR}
sudo chmod 777 -R ${LOGDIR}
echo 'Log dir: '$LOGDIR

gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE \
    --worker=all --command "
cd $STAGEDIR
echo 'Current dir: '
pwd
$CONDA_PY_PATH main.py \
    --workdir=${LOGDIR} \
    --mode=remote_debug \
    --config=configs/load_config.py:remote_debug \
" 2>&1 | tee -a $LOGDIR/output.log

############# No need to modify [END] #############