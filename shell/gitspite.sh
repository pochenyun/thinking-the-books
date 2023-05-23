#!/bin/bash
# 分割文件上传到github，并将分割文件打包
# 需要遍历的文件夹
directory="$1"
echo "git项目文件夹路径:$directory"
if [ ! -d "$directory" ]; then
    echo "路径 $directory 不存在"
    exit 1
fi

# 排除的文件夹列表
exclude=(".git" ".idea")
# github限制100
min_size="100M"
# 分割大小
spite_size="90m"

find "$directory" -type f -size +$min_size |
    while read -r file; do
        # 排除指定的文件夹
        for ex in "${exclude[@]}"; do
            if echo "$file" | grep -q "$ex"; then
                continue 2
            fi
        done
        echo "change: $file"
        # 文件所处的文件夹
        dir=$(dirname "$file")
        # 文件带后缀的全名，如file.txt
        fileAllName=$(basename "$file")
        # 文件不带后缀的名子，如file
        filename=${fileAllName%.*}

        cd "$dir" || exit
        # 打包，产生file.tar
        tar -cvf "$filename".tar "$file"
        # 按照spite_size的大小分割，产生file001.tar、file002.tar...file00n.tar
        split -b $spite_size -d --numeric-suffixes=1 --suffix-length=3 --additional-suffix=.tar "$filename".tar "$filename"
        # 删除file.tar和源文件
        rm "$filename".tar
        rm "$fileAllName"
    done
