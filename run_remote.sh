# Your configurations here
source config.sh
CONDA_ENV=$OWN_CONDA_ENV_NAME
############# No need to modify #############
for i in {1..20}; do echo "Do you remember to use TMUX?"; done
source ka.sh

echo Running at $VM_NAME $ZONE

now=`date '+%Y%m%d_%H%M%S'`
export salt=`head /dev/urandom | tr -dc a-z0-9 | head -c6`
JOBNAME=${TASKNAME}/${now}_${salt}_${VM_NAME}_${CONFIG}_b${batch}_lr${lr}_ep${ep}_eval

LOGDIR=/$DATA_ROOT/logs/$USER/$JOBNAME

sudo mkdir -p ${LOGDIR}
sudo chmod 777 -R ${LOGDIR}
echo 'Log dir: '$LOGDIR
echo 'Staging dir: '$STAGEDIR

gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE \
    --worker=all --command "
cd $STAGEDIR
echo 'Current dir: '
pwd
$CONDA_PY_PATH main.py \
    --workdir=${LOGDIR} \
    --mode=remote_run \
    --config=configs/load_config.py:remote_run \
" 2>&1 | tee -a $LOGDIR/output.log

############# No need to modify [END] #############