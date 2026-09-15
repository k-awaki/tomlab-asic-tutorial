#!/bin/bash

# 空ディレクトリでエラーを出さないためにnullglobを有効化
shopt -s nullglob

walk_tree() {
    local dir="$1"
    local prefix="$2"
    local current_depth="$3"
    local max_depth="$4"
    
    # 現在の深さが上限を超えたら、ここで処理を止めて戻る
    if [ "$current_depth" -gt "$max_depth" ]; then
        return
    fi
    
    local items=("$dir"/*)
    local count=${#items[@]}
    local i=0

    for item in "${items[@]}"; do
        ((i++))
        local name=$(basename "$item")
        
        if [ "$i" -eq "$count" ]; then
            echo "${prefix}└── $name"
            # ディレクトリかつシンボリックリンクでない場合のみ、深さを+1して次へ
            if [ -d "$item" ] && [ ! -L "$item" ]; then
                walk_tree "$item" "${prefix}    " $((current_depth + 1)) "$max_depth"
            fi
        else
            echo "${prefix}├── $name"
            if [ -d "$item" ] && [ ! -L "$item" ]; then
                walk_tree "$item" "${prefix}│   " $((current_depth + 1)) "$max_depth"
            fi
        fi
    done
}

# 第1引数: 対象ディレクトリ (指定なしならカレントディレクトリ)
TARGET_DIR="${1:-.}"

# 第2引数: 最大の深さ (指定なしなら3をデフォルトにする)
MAX_DEPTH="${2:-3}"

echo "$TARGET_DIR"
# 最初の深さを「1」として探索スタート
walk_tree "$TARGET_DIR" "" 1 "$MAX_DEPTH"
