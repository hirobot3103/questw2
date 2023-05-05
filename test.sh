#!/bin/bash

#--------------------------------------------------------
# 変数定義

DATA_FILE_PATH='./servicelist.csv'

#--------------------------------------------------------
# 関数定義
# データファイルについては、サービス名,ユーザー名,パスワード

# 入力を促すプロンプトを表示
function show_prommpt () {
    echo -n '次の選択肢から入力してください(Add Password/Get Password/Exit)：'
}

# function read_file () {
# }

# function write_file () {
#     local fpath=$1
#     if [$fpath ];then

#     fi

# }

# function decrypts () {
# }

# function encrypts () {
# }

# function addpassword () {
# }

# function getpassword(){
# }

# Exit入力時の処理
function quit ()
{
    echo 'Thank you!'
    exit 0
}

# 選択肢以外が入力された場合の処理
function selectwrongmenu ()
{
    echo "正しい選択肢を入力してください。入力文字：${1}"
}

# メインループ　入力待ち／処理の振り分け
function mainloop ()
{
    # 入力待ち／処理の振り分け
    while read selectmenu; do
        case $selectmenu in
            'Add Password' )
                echo 'A';;
            'Get Password' )
                echo 'B';;
            'Exit' )
                quit;;
            * )
                selectwrongmenu $selectmenu;;
        esac

        # 後処理
        unset $selectmenu | show_prommpt
    done
}

#--------------------------------------------------------
# main
#--------------------------------------------------------

# 初期表示
echo 'パスワードマネージャーへようこそ！'

# 入力待ち／処理の振り分け
show_prommpt
mainloop

# キー入力待ち(EXIT、エラー以外ループ)

# 指定されたファイルを読み込んで表示

# サービス名、ユーザー名、パスワードの入力待ち

# 指定したファイルへ書き込み
