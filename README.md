# gitscp

gitでの差分をtarにして対象ディレクトリに対応するリモートサーバに転送します。

ちなみに削除ファイルに関しては転送を行いません。
理由は事故防止と必要性があまりないので。

どうしても消す必要がある場合は直接サーバで削除願います。

## 設定ファイル

以下の内容に添ってリモートの情報を記述したファイルをgitscp.shが置いてあるディレクトリの
confディレクトリ以下に作成してください。

作成したファイルはgitscp.shのカスタムエリアで修正してください。


```
TARGET_DIR=/var/hoge/hoge/
USE_SSH_KEY="FALSE"
SSH_KEY_PATH=""
USER=hoge
PORT=22
SERVER=127.0.0.1
PASSWORD=hogehoge
```
