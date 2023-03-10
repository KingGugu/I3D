#!/bin/bash

# help message
if [ $# != 7 ]; then
  echo "Usage: bash ./scripts/run_standalone_train.sh [device_id] [dataset] [mode] [num_epochs] [video_path] [annotation_path] [checkpoint_path](necessary)"
  exit 1
fi

ulimit -c unlimited
ulimit -n 65530
export SLOG_PRINT_TO_STDOUT=0

if [ ! -d "./output_standalone" ]; then
  mkdir ./output_standalone
fi

nohup python ./train.py \
  --device_id=$1 \
  --dataset=$2 \
  --video_path=$5 \
  --annotation_path=$6 \
  --checkpoint_path=$7 \
  --mode=$3 \
  --num_epochs=$4 >./output_standalone/$2_$3_device$1_log.txt 2>&1 &
