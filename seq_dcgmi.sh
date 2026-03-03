#!/bin/bash

## This script will check for Nvidia DCGM, then fine the Nvidia GPUs present and sequentially run diagnostics against all the GPUs one-by-one.
## Use this if you are getting cascading failures during DCGMI Diags and it isn't obvious which GPU is actually failed. 

LOGFILE="/var/log/dcgmi_seq_test.log"

if ! touch "$LOGFILE" 2>/dev/null; then
    echo "ERROR: Cannot write to $LOGFILE. Try running as root or with sudo."
    exit 1
fi

echo "==================================================" | tee -a "$LOGFILE"
echo "Starting sequential DCGMI diagnostics (level 3)" | tee -a "$LOGFILE"
echo "Start time: $(date)" | tee -a "$LOGFILE"
echo "==================================================" | tee -a "$LOGFILE"

# Get GPU indexes from nvidia-smi
GPU_IDS=$(nvidia-smi --query-gpu=index --format=csv,noheader)

if [ -z "$GPU_IDS" ]; then
    echo "No GPUs found." | tee -a "$LOGFILE"
    exit 1
fi

for GPU in $GPU_IDS; do
    echo "" | tee -a "$LOGFILE"
    echo "Running dcgmi diag -r 3 on GPU $GPU" | tee -a "$LOGFILE"
    echo "Start time: $(date)" | tee -a "$LOGFILE"
    echo "----------------------------------------------" | tee -a "$LOGFILE"

    dcgmi diag -r 3 -i "$GPU" 2>&1 | tee -a "$LOGFILE"
    STATUS=${PIPESTATUS[0]}

    echo "----------------------------------------------" | tee -a "$LOGFILE"
    echo "Finished GPU $GPU with exit code $STATUS" | tee -a "$LOGFILE"
    echo "End time: $(date)" | tee -a "$LOGFILE"
    echo "----------------------------------------------" | tee -a "$LOGFILE"

    if [ $STATUS -ne 0 ]; then
        echo "WARNING: Diagnostic reported non-zero exit code for GPU $GPU" | tee -a "$LOGFILE"
    fi
done

echo ""
echo "==================================================" | tee -a "$LOGFILE"
echo "All GPU diagnostics complete." | tee -a "$LOGFILE"
echo "End time: $(date)" | tee -a "$LOGFILE"
echo "==================================================" | tee -a "$LOGFILE"
