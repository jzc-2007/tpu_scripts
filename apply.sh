while true; do
    gcloud compute tpus tpu-vm create kmh-tpuvm-v2-32-8 \
        --zone=us-central1-a \
        --accelerator-type=v2-32 \
        --version=tpu-ubuntu2204-base

    gcloud compute tpus tpu-vm create kmh-tpuvm-v2-32-9 \
        --zone=us-central1-a \
        --accelerator-type=v2-32 \
        --version=tpu-ubuntu2204-base

    gcloud compute tpus tpu-vm create kmh-tpuvm-v2-128-1 \
        --zone=us-central1-a \
        --accelerator-type=v2-128 \
        --version=tpu-ubuntu2204-base
done;