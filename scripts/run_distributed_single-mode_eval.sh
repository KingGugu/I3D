#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"

# help message
if [ $# != 7 ]; then
  echo "Usage: bash ./scripts/run_distributed_single_eval.sh [ckpt_start_id] [mode] [dataset] [annotation_path] [video_path] [output_ckpt_path] [train_steps]"
  exit 1
fi

rm -rf $DIR/output_eval
mkdir $DIR/output_eval

for ((i = 0; i <= 8 - 1; i++)); do
  echo 'start eval, device id='${i}'...'
  nohup python ./eval.py \
    --device_id=${i} \
    --test_mode=$2 \
    --$2_path=$6/i3d-$((${i} + $1))_$7.ckpt \
    --dataset=$3 \
    --video_path=$5 \
    --annotation_path=$4 >$DIR/output_eval/eval_divice${i}_log.txt 2>&1 &
done

wait

for ((i = 0; i <= 8 - 1; i++)); do
  cat $DIR/output_eval/eval_divice${i}_log.txt | grep "checkpoint:" >>output_eval/summary.txt
  cat $DIR/output_eval/eval_divice${i}_log.txt | grep "$2 accuracy" >>output_eval/summary.txt
done
