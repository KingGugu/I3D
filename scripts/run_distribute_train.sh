#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"

# help message
if [ $# != 8 ]; then
  echo "Usage: bash ./scripts/run_distribute_train.sh [rank_size] [rank_table_file] [dataset] [mode] [num_epochs] [video_path] [annotation_path] [checkpoint_path](necessary)"
  exit 1
fi

ulimit -c unlimited
ulimit -n 65530
export RANK_SIZE=$1
export RANK_TABLE_FILE=$2

rm -rf $DIR/output_distribute
mkdir $DIR/output_distribute

for ((i = 0; i < ${RANK_SIZE}; i++)); do
  export RANK_ID=${i}
  export DEVICE_ID=${i}
  echo "start training for device $i"
  if [ -d $DIR/output_distribute/$3_$4_device${i} ]; then
    rm -rf $DIR/output_distribute/$3_$4_device${i}
  fi
  mkdir $DIR/output_distribute/$3_$4_device${i}
  nohup python ./train.py \
    --device_id=${i} \
    --dataset=$3 \
    --video_path=$6 \
    --annotation_path=$7 \
    --checkpoint_path=$8 \
    --mode=$4 \
    --num_epochs=$5 \
    --distributed=True >$DIR/output_distribute/$3_$4_device${i}_log.txt 2>&1 &
done
