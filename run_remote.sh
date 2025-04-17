# Your configurations here
source config.sh
CONDA_ENV=$OWN_CONDA_ENV_NAME
############# No need to modify #############
# for i in {1..20}; do echo "Do you remember to use TMUX?"; done
# if [ -z "$2" ]; then
# 	source ka.sh $1 # import VM_NAME, ZONE
# else
# 	echo use command line arguments
# 	export VM_NAME=$1
# 	export ZONE=$2
# fi

echo Running at $VM_NAME $ZONE

now=`date '+%Y%m%d_%H%M%S'`
export salt=`head /dev/urandom | tr -dc a-z0-9 | head -c6`
JOBNAME=${TASKNAME}/${now}_${salt}_${VM_NAME}_${CONFIG}_b${batch}_lr${lr}_ep${ep}_eval

LOGDIR=/$DATA_ROOT/logs/$USER/$JOBNAME

sudo mkdir -p ${LOGDIR}
sudo chmod 777 -R ${LOGDIR}
echo 'Log dir: '$LOGDIR
echo 'Staging dir: '$STAGEDIR

export cmd="cd $STAGEDIR
echo 'Current dir: '
pwd
$CONDA_PY_PATH main.py --workdir=${LOGDIR} --mode=remote_run --config=configs/load_config.py:remote_run "

# add all the configs pass in to cmd
for arg in "$@"; do
    export cmd="$cmd $arg"
done

echo "Running command: $cmd"

gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE \
    --worker=all --command "${cmd}" 2>&1 | tee -a $LOGDIR/output.log

############# No need to modify [END] #############