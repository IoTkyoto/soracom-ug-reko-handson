# ステップ4. ハンズオン終了後のあと片づけ（スマートフォンとSORACOM FunkとAWSサービスを用いた画像認識サービスを構築する）

*当コンテンツは、エッジデバイスとしてスマートフォン、クラウドサービスとしてAWSを利用し、エッジデバイスとクラウド間とのデータ連携とAWSサービスを利用した画像認識を体験し、IoT/画像認識システムの基礎的な技術の習得を目指す方向けのハンズオン(体験学習)コンテンツ「[スマートフォンとSORACOM FunkとAWSサービスを用いた画像認識サービスを構築する](https://iotkyoto.github.io/soracom-ug-reko-handson/)」の一部です。*

# ステップ4. ハンズオン終了後のあと片づけ

ご利用いただいたAWSの各種サービスには無料利用枠がございますが、無料利用枠を超えた場合は従量課金が発生します。

ハンズオンを行い、環境が不要となれば各種リソースを削除することを推奨します。

---

### 目的

- 作成したAWS環境の各種リソースを削除する

### 概要

- AWS Cloud9の環境を環境を削除する
- AWS Amplifyアプリケーションを削除する
- S3バケットを削除する
- AWS Amplify Consoleからシングルページアプリケーションのデプロイを行う

---

## 1-1. AWS Cloud9 環境を構築する

AWSコンソールにログインし、AWS Cloud9の環境を構築します。

### 1-1-1. AWSコンソールにログインする
- 各自のアカウントでAWS環境にログインしてください  
 **使用するユーザーは「AdministratorAccess」権限が付与されていることを前提とします**
![1-1-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-1-1_1.png)
![1-1-1_2](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-1-1_2.png)

- リージョンを「東京」言語を「日本語」に切り替えてください

### 1-1-2. Cloud9サービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「cloud」と入力し、候補から「Cloud9」を選択してください
![1-1-2](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-1-2.png)

### 1-1-3. Cloud9環境を構築する

- [create environment]（環境を作成する）をクリックしてください
![1-1-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-1-3_1.png)

- Nameに「{名前}-handson-env」を入力し、[Next step] をクリックしてください
例）yamada-handson-env
![1-1-3_3](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-1-3_3.png)

- 設定内容はすべてデフォルトのまま画面下部の [Next step] をクリックしてください
![1-1-3_4](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-1-3_4.png)
![1-1-3_5](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-1-3_5.png)

- 設定内容確認画面で [create environment] をクリックしてください
![1-1-3_6](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-1-3_6.png)
![1-1-3_7](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-1-3_7.png)

※ 新しいタブが開き、Cloud9 IDEのCreate処理が行われますので、環境が立ち上がるまでしばらくお待ちください

## 1-2. Webアプリケーションのセットアップを行う
スマートフォンで画面表示するためのWebアプリケーションのセットアップを行います
今回セットアップするアプリケーションは、JavaScriptフレームワークの１つである [Vue.js](https://jp.vuejs.org/index.html) を使った [SPA(シングルページアプリケーション)](https://ja.wikipedia.org/wiki/%E3%82%B7%E3%83%B3%E3%82%B0%E3%83%AB%E3%83%9A%E3%83%BC%E3%82%B8%E3%82%A2%E3%83%97%E3%83%AA%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3) と呼ばれるものです

### 1-2-1. ターミナルを開く

- Cloud9 IDE の画面を表示してください
![1-2-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-2-1_1.png)

- Welcomeページを閉じて、新しくターミナルを開いてください
![1-2-1_2](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-2-1_2.png)

### 1-2-2. Githubからファイル一式をCloneする

- ターミナルで以下のコマンドを実行し、Githubからソースコードを取得する

```sh
$ git clone https://github.com/IoTkyoto/soracom-ug-reko-handson

Cloning into 'soracom-ug-reko-handson'...
remote: Enumerating objects: 369, done.
remote: Counting objects: 100% (369/369), done.
remote: Compressing objects: 100% (324/324), done.
remote: Total 369 (delta 131), reused 210 (delta 29), pack-reused 0
Receiving objects: 100% (369/369), 21.30 MiB | 2.04 MiB/s, done.
Resolving deltas: 100% (131/131), done.
```

- ダウンロードしたリポジトリのWebアプリケーションのディレクトリに移動する

```sh
$ cd soracom-ug-reko-handson/webapp/
```

### 1-2-3. アプリケーションのProductionビルドを行う

- ターミナルで以下のコマンドを実行し、必要なライブラリファイルをインストールする

```sh
$ npm install
```

※ 処理が終わるまで少し時間がかかります

- ソースコードから静的ファイル(HTML/JavaScript/CSS)を生成する

```sh
$ npm run build
```

### 1-2-4. 静的リソースディレクトリを圧縮する

- 静的リソースディレクトリに移動する

```sh
$ cd dist
```

- フォルダ内のファイル一式をZIP形式で圧縮する

```sh
$ zip -r archive.zip *  
```

### 1-2-5. デプロイファイルを格納するためのS3バケットを作成する

- 圧縮したファイルをAWS環境に格納させるためのS3バケットを作成します
- バケット名は任意の名前にしてください  
（例：yamada-reko-handson-deployment）

```sh
$ aws s3 mb s3://yamada-reko-handson-deployment
make_bucket: yamada-reko-handson-deployment
```

- 以下のコマンドを実行しS3バケットの一覧にバケットが追加されていることを確認します

```sh
$ aws s3 ls
```

### 1-2-6. S3にファイルをアップロードする

- 圧縮したZipファイルをS3バケットにアップロードします

```sh
$ aws s3 cp archive.zip s3://yamada-reko-handson-deployment/
```

## 1-3. Amplify Consoleでデプロイを行う

### 1-3-1. Amplifyサービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「ampl」と入力し、候補から「AWS Amplify」を選択してください
![1-3-1](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-3-1.png)

### 1-3-2. アプリケーションの作成を行う

- 画面左のメニューをクリックし「すべてのアプリ」をクリックしてください
![1-3-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-3-2_1.png)

- 「アプリの作成」をクリックしてください
![1-3-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-3-2_2.png)

### 1-3-3. アプリケーションの設定を行う

- 「Deploy without Git provider」（Gitプロバイダー以外でのデプロイ）を選択し「Continue」をクリックしてください
![1-3-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-3-3_1.png)

- 以下の情報を入力し「Save and deploy」をクリックしてください
  - App name（アプリケーション名）
    - 任意（例：yamada_rekognition_handson）
  - Environment name（環境名）
    - 任意（例：prod）
  - Method（デプロイ方法）
    - Amazon S3
  - Bucket（デプロイ対象S3バケット）
    - ステップ1-2-5で作成したデプロイファイル配置用のS3バケット名
    - yamada-reko-handson-deployment
  - Zip file（デプロイ対象ZIPファイル）
    - ステップ1-2-4で作成した圧縮ファイルのファイル名
    - archive.zip
![1-3-3_2](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-3-3_2.png)
![1-3-3_3](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-3-3_3.png)
    

### 1-3-4. デプロイを実施する

- 処理が進行し「success」が表示されればデプロイが完了です
![1-3-4](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-3-4.png)

### 1-3-5. ブラウザでアクセスする

- Domain部分に表示されているURLをクリックしてください
![1-3-5_1](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-3-5_1.png)

- 以下のようなページが表示されれば成功です
![1-3-5_2](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step0/0-3-5_2.png)

### 1-3-6. スマートフォンでハンズオン用アプリを開く

- スマートフォンをインターネットに接続できる状態にし、ブラウザを起動し、ステップ1−3−5でアクセスしたアプリのURLを開いてください
- 以下のようなサイトでURLをQRコード化すると簡単にアクセスすることが出来ます
https://qr.quel.jp/

### 次のステップへ進んでください

- ここまでの作業で事前の準備作業は終了です
- [トップページ](https://iotkyoto.github.io/soracom-ug-reko-handson/)に戻って次のステップに進んでください
