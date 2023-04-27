# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the GNU General Public License version 3.

PRESIGNED_URL="https://dobf1k6cxlizq.cloudfront.net/*?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kb2JmMWs2Y3hsaXpxLmNsb3VkZnJvbnQubmV0LyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2ODM4MzU5NTV9fX1dfQ__&Signature=QB64hi4eMqw4Vp3xdkySCd7MkJPen37Gikm3TgKp3HtW8s0xiO4v1WSwP06~oyrBYf803YeuhVYPyY7jDEgwX7tGCrWEF5yDjyfmeAZwyYU8T5t4errjgKYRwYKBynXaX1pXe5iIvGooR8DkYhfldGxXjjc3f3kKwzLupuAIt8D7FW3E5Wqh7xfEJmAKTDZdhsMiIm6LB5z1z1Zw1dFKM7KOpL3ST~4dDgu4h853uN~6XnjsAeS-BooNSSkarslvRzx-p5hXoYerUuRCGAJfBOQ73aDfzA4CUXV2EozcVVR4JOgHzCNwU-Vmr12QY03VIjP6xBRzfLxyVM-xZBRMFg__&Key-Pair-Id=K231VYXPC1TA1R"
MODEL_SIZE="30B"  # 7B,13B,30B,65B
TARGET_FOLDER="model_dir"             # where all files should end up

declare -A N_SHARD_DICT

N_SHARD_DICT["7B"]="0"
N_SHARD_DICT["13B"]="1"
N_SHARD_DICT["30B"]="3"
N_SHARD_DICT["65B"]="7"

echo "Downloading tokenizer"
wget ${PRESIGNED_URL/'*'/"tokenizer.model"} -O ${TARGET_FOLDER}"/tokenizer.model"
wget ${PRESIGNED_URL/'*'/"tokenizer_checklist.chk"} -O ${TARGET_FOLDER}"/tokenizer_checklist.chk"

(cd ${TARGET_FOLDER} && md5sum -c tokenizer_checklist.chk)

for i in ${MODEL_SIZE//,/ }
do
    echo "Downloading ${i}"
    mkdir -p ${TARGET_FOLDER}"/${i}"
    for s in $(seq -f "0%g" 0 ${N_SHARD_DICT[$i]})
    do
        wget ${PRESIGNED_URL/'*'/"${i}/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${i}/consolidated.${s}.pth"
    done
    wget ${PRESIGNED_URL/'*'/"${i}/params.json"} -O ${TARGET_FOLDER}"/${i}/params.json"
    wget ${PRESIGNED_URL/'*'/"${i}/checklist.chk"} -O ${TARGET_FOLDER}"/${i}/checklist.chk"
    echo "Checking checksums"
    (cd ${TARGET_FOLDER}"/${i}" && md5sum -c checklist.chk)
done
