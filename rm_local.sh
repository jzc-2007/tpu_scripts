
# list=(
# kmh-tpuvm-v2-32-1
# kmh-tpuvm-v2-32-2
# kmh-tpuvm-v2-32-3
# kmh-tpuvm-v2-32-4
# kmh-tpuvm-v2-32-5
# kmh-tpuvm-v2-32-6
# kmh-tpuvm-v2-32-7
# kmh-tpuvm-v2-32-8
# kmh-tpuvm-v3-32-1
# kmh-tpuvm-v4-8-6
# kmh-tpuvm-v2-32-preemptible-1
# kmh-tpuvm-v2-32-preemptible-2
# kmh-tpuvm-v3-32-preemptible-1
# kmh-tpuvm-v4-32-preemptible-1
# kmh-tpuvm-v4-32-preemptible-2
# kmh-tpuvm-v3-32-11
# kmh-tpuvm-v3-32-12
# kmh-tpuvm-v3-32-13
# )

list=(
kmh-tpuvm-v4-32-preemptible-1
kmh-tpuvm-v4-32-preemptible-2
)

for VM_NAME in  "${list[@]}"; do
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

echo $VM_NAME $ZONE
gcloud compute tpus tpu-vm ssh $VM_NAME --zone $ZONE --worker=all \
    --command "
rm -rf /home/sqa/.local
ls -a /home/sqa
" # &> /dev/null

done