- 👋 Hi, I’m @eioncustom
- 👀 I’m interested in Clustered Computing and System Administration
- 🌱 I’m always trying to learn new things and test new environments.
- ✌️ I'm currently using GitHub to post scripts that I write for my day to day operations when I see a benefit to individuals like myself.

  HPC Life for all!

# Scripts in the Repo

## scan_raw_data.py
This script is a utility I needed to make for scanning potentially failed disk drives for recoverable data.  
This runs in a read-only state and will not attempt to recover any bits.  
You can run this directly on the block device or on a ddrescue disk image.  

* Example output on completion:  
> Read 1,917,157,638,144 bytes; remaining 3,225,772,032 bytes; nonzero 0; 801.1 MiB/s  
> Bytes read:    1,920,383,410,176  
> Bytes remaining: 0  
> Zero bytes:    1,920,383,410,176  
> Nonzero bytes: 0 (0.0000%)  
> Every byte read was zero.  

## derbytime.sh
This script is to automate the launch of the CRG Scoreboard System on a Linux System.

## mlnx_pci_check.sh
This script is to quick check all the PCI Buses in a Multi-GPU Server. 

## seq_dcgmi.sh
This script will check for Nvidia DCGM, then fine the Nvidia GPUs present and sequentially run diagnostics against all the GPUs one-by-one.
Use this if you are getting cascading failures during DCGMI Diags and it isn't obvious which GPU is actually failed. 

## ubuntu_passive_updater.ps1
Ubuntu Passive Updater via SSH with PowerShell, this will perform Linux Kernel updates via SSH
Be very careful with this as the updates can fail and leave the kernel in a broken state. 


<!---
eioncustom/eioncustom is a ✨ special ✨ repository because its `README.md` (this file) appears on your GitHub profile.
You can click the Preview link to take a look at your changes.
--->

