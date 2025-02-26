import subprocess

ZONE_EU = "europe-west4-a"
ZONE_US = "us-central1-a"
ZONE_US_2 = "us-central2-b"

def get_zone(ka):
    if "v2-32-preemptible-1" in ka:
        return ZONE_US
    elif "preemptible" in ka:
        return ZONE_EU
    elif "v4" in ka:
        return ZONE_US_2
    elif "v3" in ka:
        return ZONE_EU
    elif "v2-32-4" in ka:
        return ZONE_EU
    else:
        return ZONE_US
        
def check_ka(ka):
    zone = get_zone(ka)
    run = subprocess.run(["bash", "get_ka_status.sh", ka, zone])
    code = run.returncode
    return {
        0: "xian",
        1: "running",
        2: "internal error",
        3: "preeempted",
        4: "env broken"
    }[code]
    
if __name__ == '__main__':
    results = [(check_ka("kmh-tpuvm-v2-32-1")),
    (check_ka("kmh-tpuvm-v2-32-2")),
    (check_ka("kmh-tpuvm-v2-32-preemptible-1")),
    (check_ka("kmh-tpuvm-v3-32-preemptible-1"))]
    print('==========')
    print(results)