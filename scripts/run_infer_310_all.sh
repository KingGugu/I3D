#!/bin/bash

if [ $# != 5 ]; then
  echo "Usage:
    bash ./scripts/run_infer_310_all.sh [MINDIR_PATH_HMDB51_RGB] [MINDIR_PATH_HMDB51_FLOW] [MINDIR_PATH_UCF101_RGB] [MINDIR_PATH_UCF101_FLOW] [DEVICE_ID]
    DEVICE_ID is optional, it can be set by environment variable device_id, otherwise the value is zero."
  exit 1
fi

get_real_path() {
  #Get the file of mindr
  if [ "${1:0:1}" == "/" ]; then
    echo "$1"
  else
    echo "$(realpath -m $PWD/$1)"
  fi
}
model_HMDB51_RGB=$(get_real_path $1)
model_HMDB51_FLOW=$(get_real_path $2)
model_UCF101_RGB=$(get_real_path $3)
model_UCF101_FLOW=$(get_real_path $4)

echo "model_HMDB51_RGB: "$model_HMDB51_RGB
echo "model_HMDB51_FLOW: "$model_HMDB51_FLOW
echo "model_UCF101_RGB: "$model_UCF101_RGB
echo "model_UCF101_FLOW :"$model_UCF101_FLOW

device_id=0
if [ $# == 5 ]; then
  device_id=$5
fi

bash ./scripts/run_infer_310.sh $model_HMDB51_RGB hmdb51 $device_id rgb
bash ./scripts/run_infer_310.sh $model_HMDB51_FLOW hmdb51 $device_id flow
bash ./scripts/run_infer_310.sh $model_UCF101_RGB ucf101 $device_id rgb
bash ./scripts/run_infer_310.sh $model_UCF101_FLOW ucf101 $device_id flow
