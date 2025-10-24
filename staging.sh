# Stage code and run job in a remote TPU VM
# if [ -z "$2" ]; then
# 	source ka.sh $1 # import VM_NAME, ZONE
# else
# 	echo use command line arguments
# 	export VM_NAME=$1
# 	export ZONE=$2
# fi
# ------------------------------------------------
# Copy all code files to staging
# ------------------------------------------------
PASS_KA=0
PASS_ZONE=0

if [ -n "$1" ]; then
	echo "1st arg(ka): $1"
	if [[ "$1" == ka=* ]]; then
		ka=${1#*=}
		export VM_NAME=$ka
		export PASS_KA=1

		if [ -n "$2" ]; then
			echo "2nd arg(zone): $2"
			if [[ "$2" == zone=* ]]; then
				zone=${2#*=}
				export ZONE=$zone
				export PASS_ZONE=1
			fi
		fi

	fi
fi

source ka.sh $VM_NAME $ZONE
now=`date '+%y%m%d%H%M%S'`
salt=`head /dev/urandom | tr -dc a-z0-9 | head -c6`
git config --global --add safe.directory $(pwd)
HERE=$(pwd)
commitid=`git show -s --format=%h`  # latest commit id; may not be exactly the same as the commit
export STAGEDIR=/$DATA_ROOT/staging/$USER/${now}-${salt}-${commitid}-code

echo 'Staging files...'
rsync -a . $STAGEDIR --exclude=tmp --exclude=.git --exclude=__pycache__ --exclude="*.png" --exclude="history" --exclude=wandb --exclude="zhh_code" --exclude="zhh" --exclude="*err.log"
# cp -r /kmh-nfs-ssd-eu-mount/code/hanhong/MyFile/research_utils/Jax/zhh $STAGEDIR
echo 'Done staging.'

sudo chmod 777 -R $STAGEDIR

cd $STAGEDIR
# echo 'Current dir: '`pwd`
# ------------------------------------------------

if [ $PASS_KA -eq 0 ]; then
	echo "parameters: "
	echo ${@:1}
	source run_remote.sh ${@:1}
elif [ $PASS_ZONE -eq 0 ]; then
	echo "parameters: "
	echo ${@:2}
	source run_remote.sh ${@:2}
else
	echo "parameters: "
	echo ${@:3}
	source run_remote.sh ${@:3}
fi

cd $HERE