source config.sh
rm -rf tmp # Comment this line if you want to reload (usually not the case)
mkdir tmp

echo "start running main"

# JAX_PLATFORMS=cpu python3 main.py \
/kmh-nfs-ssd-us-mount/code/eva/miniforge3/bin/python3 main.py \
    --workdir=$(pwd)/tmp \
    --mode=local_debug \
    --config=configs/load_config.py:local_debug \
2>&1 | tee tmp/log.txt
