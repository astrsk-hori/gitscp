#!/bin/bash

TARGET_DIR=/var/emtg/dev13-aop.admin.emtg.jp/
SSH_KEY_PATH=/cygdrive/c/Users/go.horie/aopadmin_ssh
USER=aopadmin
SERVER=127.0.0.1

function transfer() {
    echo "転送処理開始"
    while read line
    do
        echo "scp -P 10022 -i $SSH_KEY_PATH ./$line ${USER}@${SERVER}:${TARGET_DIR}$line"
        scp -P 10022 -i $SSH_KEY_PATH ./$line ${USER}@${SERVER}:${TARGET_DIR}$line
    done < ./tmp_gitssh_list
}

yes_or_no_recursive(){
    echo
    echo $1
    echo "Type yes or no."
        read answer
        case $answer in
            yes)
                echo -e "tyeped yes.\n"
                return 0
                ;;
            no)
                echo -e "tyeped no.\n"
                return 1
                ;;
            *)
                echo -e "cannot understand $answer.\n"
                yes_or_no_recursive
                ;;
        esac
}

function main(){

    git status -s |awk '{print $2}'|grep -v tmp_gitssh_list>./tmp_gitssh_list
    echo "現在の変更ファイル一覧です。"
    echo
    echo "##############################"
    cat ./tmp_gitssh_list
    echo "##############################"
    echo
    echo "転送するファイルを絞り込む場合はリストから削除してください。"
    read
    vi ./tmp_gitssh_list

    echo "以下のファイルを転送します。"
    cat ./tmp_gitssh_list

    yes_or_no_recursive "転送を実行してもよろしいですか？"

    # 転送しない場合は終了。
    if test $? -eq 1; then
        rm ./tmp_gitssh_list
        echo "処理を中止しました。"
        exit;
    fi

    transfer

    rm ./tmp_gitssh_list
    echo "done!"
}


main
