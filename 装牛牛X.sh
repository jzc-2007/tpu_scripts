conda create -n NNX python==3.10.14 -y
conda activate NNX # These two lines are very smart. If on a device there is no conda, then these two lines error out, but the remaining can still be run.
pip install 'setuptools==69.5.1'
pip install jax[tpu]==0.4.37 -f https://storage.googleapis.com/jax-releases/libtpu_releases.html
pip install jaxlib==0.4.37 'flax>=0.8'
# pip install -r requirements.txt # other tang dependencies
pip install pillow clu tensorflow==2.15.0 'keras<3' 'torch<=2.4' torchvision tensorflow_datasets matplotlib==3.9.2
pip install orbax-checkpoint==0.6.4 ml-dtypes==0.5.0 tensorstore==0.1.67
pip install diffusers dm-tree cached_property ml-collections
pip install flax==0.10.2
pip install 'wandb==0.19.9'
pip install gcsfs
