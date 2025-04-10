import subprocess

ZONE_EU = "europe-west4-a"
ZONE_US = "us-central1-a"
ZONE_US_2 = "us-central2-b"

def get_zone(ka):
    if 'v4' in ka:
        return ZONE_US_2
    elif "v3" in ka:
        return ZONE_EU
    elif ka in ['v2-32-preemptible-1', 'v2-32-4']:
        return ZONE_EU
    else:
        return ZONE_US
        
def check_ka(ka):
    zone = get_zone(ka)
    try:
        run = subprocess.run(["bash", "get_ka_status.sh", ka, zone], timeout=40)
        code = run.returncode
    except subprocess.TimeoutExpired:
        code = 5
    return {
        0: "xian",
        1: "running",
        2: "internal error",
        3: "preeempted",
        4: "env broken",
        5: "timeout"
    }[code]
    
if __name__ == '__main__':
    results = [(check_ka("kmh-tpuvm-v2-32-1")),
    (check_ka("kmh-tpuvm-v2-32-2")),
    (check_ka("kmh-tpuvm-v2-32-preemptible-1")),
    (check_ka("kmh-tpuvm-v3-32-preemptible-1"))]
    print('==========')
    print(results)