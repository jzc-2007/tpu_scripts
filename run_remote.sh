# Your configurations here
source config.sh
CONDA_ENV=$OWN_CONDA_ENV_NAME

echo Running at $VM_NAME $ZONE

now=`date '+%Y%m%d_%H%M%S'`
export salt=`head /dev/urandom | tr -dc a-z0-9 | head -c6`
# ZHH: added "ZONE"
JOBNAME=${TASKNAME}/${now}_${salt}_${VM_NAME}_${ZONE}_${CONFIG}_b${batch}_lr${lr}_ep${ep}_eval

LOGDIR=/$DATA_ROOT/logs/$USER/$JOBNAME

sudo mkdir -p ${LOGDIR}
sudo chmod 777 -R ${LOGDIR}
echo 'Log dir: '$LOGDIR
echo 'Staging dir: '$STAGEDIR

pane_id=$TMUX_PANE
current_window=$(tmux display-message -p -t "$pane_id" '#S:#I')
echo "Current tmux window: $current_window"

echo 'tpu: '$VM_NAME
echo 'window id: '$current_window
tpu upd-log $current_window $LOGDIR $STAGEDIR $VM_NAME $now

export cmd="cd $STAGEDIR
echo 'Current dir: '
pwd
$CONDA_PY_PATH main.py --workdir=${LOGDIR} --mode=remote_run --config=configs/load_config.py:remote_run "

# add all the configs pass in to cmd
for arg in "$@"; 
    do
        if [[ $arg == --config* ]]; then
            export cmd="$cmd $arg"
        fi
    done

echo "Running command: $cmd"

gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE \
    --worker=all --ssh-flag="-n" --command "${cmd}" 2>&1 | tee -a $LOGDIR/output.log

alias tpu='python /kmh-nfs-ssd-us-mount/code/zhichengjiang/working/xibo_tpu_manager/tpu.py'

if grep -q "wandb: Run history:" $LOGDIR/output.log; then
    echo "Job completed successfully"
    tpu finish-job $current_window
else
    echo "Job failed"
    tpu fail-job $current_window
fi


# tpu finish-job $current_window
############# No need to modify [END] #############

echo "你就张京兆吧"