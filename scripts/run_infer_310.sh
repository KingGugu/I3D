#!/bin/bash

if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "Usage: bash ./scripts/run_infer_310.sh [MINDIR_PATH] [DATASET] [DEVICE_ID] [MODE]
    DATASET must be 'hmdb51' or 'ucf101'.
    DEVICE_ID, it can be set by environment variable device_id, otherwise the value is zero
    MODE must be 'rgb' or 'flow'."
  exit 1
fi

get_real_path() {
  if [ "${1:0:1}" == "/" ]; then
    echo "$1"
  else
    echo "$(realpath -m $PWD/$1)"
  fi
}
model=$(get_real_path $1)

if [ "$2" == "hmdb51" ] || [ "$2" == "ucf101" ]; then
  dataset=$2
else
  echo "DATASET must be hmdb51 or ucf101."
  exit 1
fi

device_id=0
if [ $# == 3 ]; then
  device_id=$3
fi

if [ "$4" == "rgb" ] || [ "$4" == "flow" ]; then
  mode=$4
else
  echo "mode must be rgb or flow."
  exit 1
fi

echo "mindir name: "$model
echo "dataset: "$dataset
echo "device id: "$device_id
echo "mode :"$mode

export ASCEND_HOME=/usr/local/Ascend/
if [ -d ${ASCEND_HOME}/ascend-toolkit ]; then
  export PATH=$ASCEND_HOME/fwkacllib/bin:$ASCEND_HOME/fwkacllib/ccec_compiler/bin:$ASCEND_HOME/ascend-toolkit/latest/fwkacllib/ccec_compiler/bin:$ASCEND_HOME/ascend-toolkit/latest/atc/bin:$PATH
  export LD_LIBRARY_PATH=$ASCEND_HOME/fwkacllib/lib64:/usr/local/lib:$ASCEND_HOME/ascend-toolkit/latest/atc/lib64:$ASCEND_HOME/ascend-toolkit/latest/fwkacllib/lib64:$ASCEND_HOME/driver/lib64:$ASCEND_HOME/add-ons:$LD_LIBRARY_PATH
  export TBE_IMPL_PATH=$ASCEND_HOME/ascend-toolkit/latest/opp/op_impl/built-in/ai_core/tbe
  export PYTHONPATH=$ASCEND_HOME/fwkacllib/python/site-packages:${TBE_IMPL_PATH}:$ASCEND_HOME/ascend-toolkit/latest/fwkacllib/python/site-packages:$PYTHONPATH
  export ASCEND_OPP_PATH=$ASCEND_HOME/ascend-toolkit/latest/opp
else
  export ASCEND_HOME=/usr/local/Ascend/latest/
  export PATH=$ASCEND_HOME/fwkacllib/bin:$ASCEND_HOME/fwkacllib/ccec_compiler/bin:$ASCEND_HOME/atc/ccec_compiler/bin:$ASCEND_HOME/atc/bin:$PATH
  export LD_LIBRARY_PATH=$ASCEND_HOME/fwkacllib/lib64:/usr/local/lib:$ASCEND_HOME/atc/lib64:$ASCEND_HOME/acllib/lib64:$ASCEND_HOME/driver/lib64:$ASCEND_HOME/add-ons:$LD_LIBRARY_PATH
  export PYTHONPATH=$ASCEND_HOME/fwkacllib/python/site-packages:$ASCEND_HOME/atc/python/site-packages:$PYTHONPATH
  export ASCEND_OPP_PATH=$ASCEND_HOME/opp
fi

function compile_app() {
  cd ascend_310_infer || exit
  bash build.sh &>build.log
}

function infer() {
  cd - || exit
  if [ -d result_Files ]; then
    rm -rf ./result_Files
  fi
  if [ -d time_Result ]; then
    rm -rf ./time_Result
  fi
  mkdir result_Files
  mkdir time_Result
  ascend_310_infer/src/i3d --mindir_path=$model --input0_path=preprocess_Result/data/$dataset/$mode --device_id=$device_id &>infer_${dataset}_${mode}.log

}

function cal_acc() {
  if [ "$dataset" == "hmdb51" ]; then
    python postprocess.py --dataset=$dataset --mode=$mode --num-classes=51 --batch-size=8 --label-path=preprocess_Result/label/hmdb51/$mode/label_bs${mode}8.npy &>acc_${dataset}_${mode}.log
  elif [ "$dataset" == "ucf101" ]; then
    python postprocess.py --dataset=ucf101 --mode=$mode --num-classes=101 --batch-size=8 --label-path=preprocess_Result/label/ucf101/$mode/label_bs${mode}8.npy &>acc_${dataset}_${mode}.log
   fi
}

function data_align() {
  if [ "$dataset" == "hmdb51" ] && [ "$mode" == "rgb" ]; then
    if [ -e preprocess_Result/data/hmdb51/rgb/hmdb51_bsrgb_56.bin ]; then
      rm preprocess_Result/data/hmdb51/rgb/hmdb51_bsrgb_56.bin
    fi
  elif [ "$dataset" == "hmdb51" ] && [ "$mode" == "flow" ]; then
    if [ -e preprocess_Result/data/hmdb51/flow/hmdb51_bsflow_56.bin ]; then
      rm preprocess_Result/data/hmdb51/flow/hmdb51_bsflow_56.bin
    fi
  elif [ "$dataset" == "ucf101" ] && [ "$mode" == "rgb" ]; then
    if [ -e preprocess_Result/data/ucf101/rgb/ucf101_bsrgb_148.bin ]; then
      rm preprocess_Result/data/ucf101/rgb/ucf101_bsrgb_148.bin
    fi
  else
    if [ -e preprocess_Result/data/ucf101/flow/ucf101_bsflow_148.bin ]; then
      rm preprocess_Result/data/ucf101/flow/ucf101_bsflow_148.bin
    fi
  fi
}

compile_app
if [ $? -ne 0 ]; then
  echo "compile app code failed"
  exit 1
fi
data_align
if [ $? -ne 0 ]; then
  echo " execute data_align failed"
  exit 1
fi
infer
if [ $? -ne 0 ]; then
  echo " execute inference failed"
  exit 1
fi
cal_acc
if [ $? -ne 0 ]; then
  echo "calculate accuracy failed"
  exit 1
fi
