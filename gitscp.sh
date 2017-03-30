#!/bin/bash
SHELL_DIR=$(cd "$(dirname "$0")"; pwd)

CONF_CHECK="FALSE"

## START customize area

if test "`pwd`" = "/home/hoge"; then
    echo "this hoge directory ."
    CONF_CHECK="TRUE"
    . ${SHELL_DIR}/conf/hoge.conf
fi
## END customize area

function transfer() {
    echo "転送処理開始"
    if test "`echo ./tmp_gitssh_list|tr -d "\n"|tr -d " "`" = ""; then
        echo "空行なので終了！"
        exit
    fi

    if test $USE_SSH_KEY = "TRUE"; then
        ssh_private_key_transfer
    else
        ssh_transfer
    fi
}

function ssh_transfer() {
    echo "password: ${PASSWORD}"
    echo "tar czvf - `cat ./tmp_gitssh_list|awk '{print $2}'`|ssh -p ${PORT} ${USER}@${SERVER} tar xzvf - -C ${TARGET_DIR} "
    tar czvf - `cat ./tmp_gitssh_list|awk '{print $2}'`|ssh -p ${PORT} ${USER}@${SERVER} tar xzvf - -C ${TARGET_DIR}
}

function ssh_private_key_transfer() {
    echo "password: ${PASSWORD}"
    echo "tar czvf - `cat ./tmp_gitssh_list|awk '{print $2}'`|ssh -p ${PORT} -i $SSH_KEY_PATH ${USER}@${SERVER} tar xzvf - -C ${TARGET_DIR} "
    tar czvf - `cat ./tmp_gitssh_list|awk '{print $2}'`|ssh -p ${PORT} -i $SSH_KEY_PATH ${USER}@${SERVER} tar xzvf - -C ${TARGET_DIR}
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
    if test $CONF_CHECK = "FALSE"; then
        echo "設定ファイルが見つからないので実行できません。"
        exit;
    fi

    echo "server: ${SERVER}"
    echo "dir: ${TARGET_DIR}"

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
    vim ./tmp_gitssh_list

    # ここで削除ファイルの除外を行う。
    cat ./tmp_gitssh_list|grep -v '^ D' >./tmp_gitssh_list
    cat ./tmp_gitssh_list

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
