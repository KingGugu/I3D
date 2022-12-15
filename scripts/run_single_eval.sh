#!/bin/bash

# help message
if [ $# != 6 ]; then
  echo "Usage: bash ./scripts/run_single_eval.sh [device_id] [mode] [dataset] [ckpt_path] [video_path] [annotation_path]"
  exit 1
fi

nohup python ./eval.py \
  --device_id=$1 \
  --test_mode=$2 \
  --$2_path=$4 \
  --dataset=$3 \
  --video_path=$5 \
  --annotation_path=$6 >./single_eval_$2_log.txt 2>&1 &
