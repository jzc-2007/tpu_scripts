import argparse
import os
# green for info
INFO = '\033[92m[INFO]\033[0m'
# red for warning
WARNING = '\033[91m[Warning]\033[0m'

parser = argparse.ArgumentParser()
parser.add_argument('--dest', type=str, help='Path to your repo folder')

args = parser.parse_args()
dest = args.dest

assert os.path.exists(dest), f"Destination path {dest} does not exist."
assert os.path.isdir(dest), f"Destination path {dest} is not a directory."

sh_files = [c for c in os.listdir(dest) if c.endswith('.sh')]

PWD = os.getcwd()
cur_sh_files = [c for c in os.listdir(PWD) if c.endswith('.sh')]

for sh_file in sh_files:
    abs_sh_file = os.path.join(dest, sh_file)
    
    # special judge: ka.sh & config.sh
    if sh_file == 'ka.sh':
        assert not os.path.islink(abs_sh_file), f'ka.sh should not be a link'
        CUR_HASH = open('ka.sh', 'r').readlines()
        CUR_HASH = [c for c in CUR_HASH if c.strip().startswith('# This is the newest script on')]
        assert len(CUR_HASH) == 1, 'Bad ka.sh. contact ZHH.'
        CUR_HASH = CUR_HASH[0].strip()
        
        dest_hash = open(abs_sh_file, 'r').readlines()
        dest_hash = [c for c in dest_hash if c.strip().startswith('# This is the newest script on')]
        if not (len(dest_hash) == 1 and dest_hash[0].strip() == CUR_HASH):
            print(f'{INFO} removing old {sh_file}...')
            os.remove(abs_sh_file)
            # copy the ka.sh to the dest, instead of symlink
            os.system(f'cp {os.path.join(PWD, sh_file)} {abs_sh_file}')
            print(f'{INFO} Created copy for {sh_file} -> {abs_sh_file}')
        else:
            print(f'{INFO} ka.sh is up to date.')
            
        continue
        
    elif sh_file == 'config.sh':
        assert not os.path.islink(abs_sh_file), f'config.sh should not be a link'
        print(f'{INFO} skipping config.sh;')
        continue
    
    # if sh is a link
    if os.path.islink(abs_sh_file):
        # get the link target
        target = os.readlink(abs_sh_file)
        if os.path.abspath(target) != os.path.abspath(os.path.join(PWD, sh_file)):
            raise RuntimeError(f'{sh_file} is a link to {target}, but it should be a link to {os.path.join(PWD, sh_file)}')
        else:
            print(f'{INFO} {sh_file} is a link to {target}, which is automatically correct')
            continue
    else:
        if sh_file not in cur_sh_files:
            print(f'{WARNING} skipped {sh_file} because it is not in the provided scripts. Gonna mark it as old...')
            # rename
            os.rename(abs_sh_file, os.path.join(dest, f'old_{sh_file}'))
        else:
            print(f'{INFO} removing old script {sh_file}...')
            os.remove(abs_sh_file)
            os.symlink(os.path.join(PWD, sh_file), abs_sh_file)
            print(f'{INFO} Created symlink for {sh_file} -> {os.path.join(PWD, sh_file)}')

print(f'{INFO} Done!')