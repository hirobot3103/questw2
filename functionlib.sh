#!/bin/bash

################################################################
# 変数定義
################################################################

DATA_FILE_PATH='./servicelist.csv' # データファイル格納先(複号後のファイル)
DATA_FILE_PATH_GPG='./servicelist.csv.gpg' # データファイル格納先(複号のファイル)


################################################################
# 関数定義
################################################################

#---------------------------------------------------------------
# 入力を促すプロンプトを表示
#---------------------------------------------------------------
function show_prommpt () {
    echo -n '次の選択肢から入力してください(Add Password/Get Password/Exit)：'
}

#---------------------------------------------------------------
# 選択肢以外が入力された場合の処理
# 引数：$1 -> mainloop()で入力された文字列
#---------------------------------------------------------------
function select_wrongmenu ()
{
    echo "正しい選択肢を入力してください。入力文字：${1}"
}

#---------------------------------------------------------------
# 入力を促すプロンプトを表示(addpassword/getpassword用)
# 戻値：入力された文字列(echoで返す)
#---------------------------------------------------------------
function show_prommpt_gp () {
    read -p 'サービス名を入力してください。:' inputword
    echo $inputword;
}

#---------------------------------------------------------------
# 入力を促すプロンプトを表示(addpassword用)
# 戻値：入力された文字列(echoで返す)
#---------------------------------------------------------------
function show_prommpt_un () {
    read -p 'ユーザー名を入力してください。:' inputword
    echo $inputword;
}

#---------------------------------------------------------------
# 入力を促すプロンプトを表示(addpassword用)
# 戻値：入力された文字列(echoで返す)
#---------------------------------------------------------------
function show_prommpt_pw () {
    read -p 'パスワードを入力してください。:' inputword
    echo $inputword;
}

#---------------------------------------------------------------
# 書き込み成功を表示(addpassword用)
#---------------------------------------------------------------
function success_regit () 
{
    echo 'パスワードの追加は成功しました。'
}

#---------------------------------------------------------------
# 空欄が入力された際の表示(addpassword用)
# 引数:$1 サービス名として入力された文字列
# 引数:$2 ユーザー名として入力された文字列
# 引数:$3 パスワードとして入力された文字列
#---------------------------------------------------------------
function exist_blank () 
{
    echo '空データが入力されています。もう一度初めからやり直してください。'
    Show_serviceList $1 $2 $3
}

#---------------------------------------------------------------
# 一件もサービス名がヒットしなかった場合の表示(getpassword用)
# 引数:$1 サービス名として入力された文字列
#---------------------------------------------------------------
function nohit_servicename ()
{
    echo "そのサービスは登録されていません。:${1}"
}

#---------------------------------------------------------------
# サービス名等の詳細を表示(addpassword/getpassword用)
# 引数:$1 サービス名文字列
# 引数:$2 ユーザー名文字列
# 引数:$3 パスワード文字列
#---------------------------------------------------------------
function Show_serviceList () 
{
    echo "サービス名：${1}"
    echo "ユーザー名：${2}"
    echo "パスワード：${3}"
}

#---------------------------------------------------------------
# ファイル内データの照合／明細表示(getpassword用)
# 引数:$1 サービス名文字列
#---------------------------------------------------------------
function getpassword_do () {
    local fpath=$DATA_FILE_PATH
    local inputData=$1
    local hitflg=0

    decrypts

    # cat | while文とすると、While文内で変数を代入してもwhileの外では反映しなかった⇒リダイレクトへ
    while read line
    do

        # 入力されたデータを一致するか（サービス名一致を判定）
        service_name=$(echo ${line} | cut -d ':' -f 1)
        if [ "$service_name" = "$inputData" ]; then

            user_name=$(echo ${line} | cut -d ':' -f 2)
            passwords=$(echo ${line} | cut -d ':' -f 3)

            Show_serviceList $service_name $user_name $passwords  
            hitflg=1
        fi

    done < $fpath

    encrypts

    # ファイル内で一件もヒットしなかった場合はその旨を表示
    if test $hitflg -eq 0; then
        nohit_servicename $inputData
    fi
}

#---------------------------------------------------------------
# 入力されたデータをファイルへ追記(Addpassword用)
# 引数:$1 サービス名として入力された文字列
# 引数:$2 ユーザー名として入力された文字列
# 引数:$3 パスワードとして入力された文字列
#---------------------------------------------------------------
function addpassword_do () {
    local fpath=$DATA_FILE_PATH
    local service_name=$1
    local user_name=$2
    local password=$3

    decrypts

    # ファイルに追記
    echo "${service_name}:${user_name}:${password}" >> $fpath

    encrypts

    # 書き込み完了を通知
    success_regit
}

# gpgコマンドで暗号化したファイルを複合（共通鍵暗号）
function decrypts () {
    #gpg $DATA_FILE_PATH_GPG
    gpg --batch --passphrase-fd 0 $DATA_FILE_PATH_GPG < goblin.dat | >/dev/null
    rm $DATA_FILE_PATH_GPG
}

# gpgコマンドで暗号化したファイルを暗号化（共通鍵暗号）
function encrypts () {
    #gpg --batch --passphrase-fd 0 --symmetric hello.txt < password.txt
    gpg --batch --passphrase-fd 0 --symmetric $DATA_FILE_PATH < goblin.dat | >/dev/null
    rm $DATA_FILE_PATH
}

#---------------------------------------------------------------
# Add Password選択時の処理（メイン）
#---------------------------------------------------------------
function addpassword () {

    # 入力内容の取得/入力された文字列をチェック(３項目一括入力)
    service_name=$(show_prommpt_gp)
    user_name=$(show_prommpt_un)
    passwords=$(show_prommpt_pw)    

    # 空欄の場合はもう一度入力するよう促す。
    if [ "$service_name" = "" ] || [ "$user_name" = "" ] || [ "$passwords" = "" ]; then
        
        exist_blank $service_name $user_name $passwords
        return 0    
    else

        # ファイルに書き込む
        addpassword_do $service_name $user_name $passwords

    fi
}

#---------------------------------------------------------------
# Get Password選択時の処理（メイン）
#---------------------------------------------------------------
function getpassword(){

    # 入力されたサービス名を取得
   local inputwords=$(show_prommpt_gp)

   # データファイルと照合し、該当すれば明細を表示
   getpassword_do $inputwords

}

#---------------------------------------------------------------
# Exit入力時の処理
#---------------------------------------------------------------
function quit ()
{
    echo 'Thank you!'
    exit 0
}

#---------------------------------------------------------------
# メインループ　入力待ち／処理の振り分け
#---------------------------------------------------------------
function mainloop ()
{
    # 入力待ち／処理の振り分け
    while read selectmenu; do
        case $selectmenu in
            'Add Password' )
                addpassword;;
            'Get Password' )
                getpassword;;
            'Exit' )
                quit;;
            * )
                select_wrongmenu $selectmenu;;
        esac

        # 後処理
        unset $selectmenu | show_prommpt
    done
}
