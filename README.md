## リポジトリ名
webmemo

## 概要
web上でメモを作成するアプリケーションです。

## デモ：Demo
## 使い方：Usage
作成ボタンで新たにメモを作成します。
メモをクリックすると中身が確認できます。削除、修正もそこから行えます。
まずlinuxでlibpq-dev（拡張ファイル）をインストールしてください。rubyでpgを使用するために必要です。
linuxコマンド
`sudo service postgresql start`

起動方法：postgresqlを起動し、下記のsql文を打ち込んでデータベースとテーブルを作成してください。
sql文
```
create database memos;
\c memos
create table memo (id int not null, title varchar(1000) not null, content varchar(1000) not null, primary key (id) );
```
## 環境：Requirement
Debian 10
Ruby 3.0.1
psql 11.12
## インストール方法：Install
- GemについてはGemfileの中身を確認ください
- ファイルの説明
  - app.rb: ルーティングを行うメインファイルです。
  - memos.json: メモの内容の保存、読み込みが行われます。
  - num.txt: メモのid管理を行うファイルです。
  - views: ビューのerbファイルが格納されています。
  - public: 静的ファイル(.css)が格納されています。
  