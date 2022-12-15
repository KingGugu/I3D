#!/bin/bash

#Batch execution pre-processing
if [ $# != 0 ]; then
  echo "Usage: This script does not require any parameters to be entered, please go to the script to modify the specific variables"
  exit 1
fi

function preprocess() {
  #  Parameters can be changed here
  bash ./scripts/run_preprocess.sh 8 hccl_8p.json hmdb51 rgb 40 ./rgb/hmdb51/jpg ./rgb/hmdb51/annotation/hmdb51_1.json ./src/pretrained/rgb_imagenet.ckpt
  sleep 4m
  bash ./scripts/run_preprocess.sh 8 hccl_8p.json ucf101 rgb 40 ./rgb/ucf101/jpg ./rgb/ucf101/annotation/ucf101_01.json ./src/pretrained/rgb_imagenet.ckpt
  sleep 4m
  bash ./scripts/run_preprocess.sh 8 hccl_8p.json hmdb51 flow 60 ./flow/hmdb51/jpg ./flow/hmdb51/annotation/hmdb51_1.json ./src/pretrained/flow_imagenet.ckpt
  sleep 4m
  bash ./scripts/run_preprocess.sh 8 hccl_8p.json ucf101 flow 60 ./flow/ucf101/jpg ./flow/ucf101/annotation/ucf101_01.json ./src/pretrained/flow_imagenet.ckpt
}

rm -rf $DIR/output_preprocess
mkdir $DIR/output_preprocess

preprocess
if [ $? -ne 0 ]; then
  echo "preprocess code failed"
  exit 1
fi
