.. _backbone-label:

learning
==============================

Description
~~~~~~~~
The learning module loads the prerequisites (such as anaconda and cudnn ) and makes ML applications visible to the user

Versions
~~~~~~~~
- conda-2021.05-py38-gpu

Module
~~~~~~~~
You can load the modules by::

    module load learning


Example job
~~~~~~~~~~~

    #!/bin/bash
    #SBATCH -A myallocation     # Allocation name 
    #SBATCH -t 20:00:00
    #SBATCH -N 1
    #SBATCH -n 10
    #SBATCH --gpus-per-node=1 
    #SBATCH -p PartitionName 
    #SBATCH --job-name=learning
    #SBATCH --mail-type=FAIL,BEGIN,END
    #SBATCH --error=%x-%J-%u.err
    #SBATCH --output=%x-%J-%u.out


    module --force purge
    module load learning/conda-2020.11-py38-gpu
    module load ml-toolkit-gpu/pytorch/1.7.1

    python torch.py
