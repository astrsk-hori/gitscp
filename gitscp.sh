#!/bin/bash

TARGET_DIR=/var/emtg/dev13-aop.admin.emtg.jp/
SSH_KEY_PATH=/cygdrive/c/Users/go.horie/aopadmin_ssh
USER=aopadmin
SERVER=127.0.0.1

function transfer() {
    echo "転送処理開始"
    if test "`echo ./tmp_gitssh_list|tr -d "\n"|tr -d " "`" = ""; then
        echo "空行なので終了！"
        exit
    fi
    #echo "scp -r -P 10022 -i $SSH_KEY_PATH ./$line ${USER}@${SERVER}:${TARGET_DIR}$line"
    #tar zcf - * | ssh yu@172.16.56.168 tar zxf - -C /home/yu/test
    echo "tar czvf - `cat ./tmp_gitssh_list|awk '{print $2}'`|ssh -P 10022 -i $SSH_KEY_PATH ${USER}@${SERVER} tar xzvf - -C ${TARGET_DIR} "
    tar czvf - `cat ./tmp_gitssh_list|awk '{print $2}'`|ssh -p 10022 -i $SSH_KEY_PATH ${USER}@${SERVER} tar xzvf - -C ${TARGET_DIR}
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

    #git status -su |awk '{print $2}'|grep -v tmp_gitssh_list >./tmp_gitssh_list
    git status -su |grep -v tmp_gitssh_list >./tmp_gitssh_list
    echo "現在の変更ファイル一覧です。"
    echo "また現在のバージョンでは削除には対応していません。"
    echo
    echo "##############################"
    cat ./tmp_gitssh_list
    echo "##############################"
    echo
    echo "転送するファイルを絞り込む場合はリストから削除してください。"
    read
    vi ./tmp_gitssh_list

    # ここで削除ファイルの除外を行う。
    cat ./tmp_gitssh_list|grep -v "^ D" >./tmp_gitssh_list

    echo "以下のファイルを転送します(削除は除外してあります)。"
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
