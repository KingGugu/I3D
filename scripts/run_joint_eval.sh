#!/bin/bash

# help message
if [ $# != 8 ]; then
  echo "Usage: bash ./scripts/run_joint_eval.sh [device_id] [dataset] [video_path] [video_path_joint_flow] [annotation_path] [annotation_path_joint_flow] [rgb_path] [flow_path]"
  exit 1
fi

nohup python ./eval.py \
  --device_id=$1 \
  --dataset=$2 \
  --video_path=$3 \
  --video_path_joint_flow=$4 \
  --annotation_path=$5 \
  --annotation_path_joint_flow=$6 \
  --rgb_path=$7 \
  --flow_path=$8 \
  --test_mode=joint >./joint_eval_log.txt 2>&1 &
