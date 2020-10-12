# ステップ６. ハンズオン終了後のあと片づけ（SORACOM回線を使ったスマートフォンとAWSサービスを用いた画像認識サービスを構築する）

*当コンテンツは、エッジデバイスとしてスマートフォン、クラウドサービスとしてAWSを利用し、エッジデバイスとクラウド間とのデータ連携とAWSサービスを利用した画像認識を体験し、IoT/画像認識システムの基礎的な技術の習得を目指す方向けのハンズオン(体験学習)コンテンツ「[SORACOM回線を使ったスマートフォンとAWSサービスを用いた画像認識サービスを構築する](https://iotkyoto.github.io/soracom-ug-reko-handson/)」の一部です。*

# ステップ６. ハンズオン終了後のあと片づけ

ご利用いただいたAWSの各種サービスには無料利用枠がございますが、無料利用枠を超えた場合は従量課金が発生します。

ハンズオンを行い、環境が不要となれば各種リソースを削除することを推奨します。

---

### 目的

- 作成したAWS環境の各種リソースを削除する

### 概要

- AWS Cloud9の環境を環境を削除する
- AWS Rekognition コレクションを削除する
- S3バケットを削除する
- Lambda/API Gatewayを削除する
- IAM情報を削除する
- SORACOM SIMグループを削除する

---

## 6-1. AWS Cloud9 環境を削除する

AWSコンソールにログインし、AWS Cloud9の環境を削除します。

### 6-1-1. Cloud9サービスに移動する

- 画面上部の「サービス」をクリックし検索窓に「cloud」と入力し、候補から「Cloud9」を選択してください
![6-1-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-1-1_1.png)

### 6-1-2. 顔認証コレクションを削除する

Cloud9環境を削除する前にステップ2-3で作成した顔認識用に作成したコレクションを削除します。

- 右ペインの「＋」をクリックして「New Terminal」をクリックする
![6-1-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-1-2_1.png)

- 以下のコマンドを実行し、コレクションの一覧を確認する
```shell
$ aws rekognition list-collections 
{
    "CollectionIds": [
        "yamada-authentication-collection",
        "yamada-authentication-collection2"
    ],
    "FaceModelVersions": [
        "4.0",
        "4.0"
    ]
}
```

- 以下のコマンドを実行し、対象のコレクションを削除する
collection-idには自分が削除するコレクションIDを入力してください
```shell
$ aws rekognition delete-collection --collection-id "yamada-authentication-collection" 
{
    "StatusCode": 200
}
```

- 再度、以下のコマンドを実行し、コレクションの一覧から削除されていることを確認する
```shell
$ aws rekognition list-collections 
{
    "CollectionIds": [],
    "FaceModelVersions": []
}
```

### 6-1-3. Cloud9環境を削除する

- ステップ1-1で作成したCloud9環境の右上の丸を選択し「Delete」ボタンをクリックする
![6-1-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-1-3_1.png)

- 入力欄に「Delete」を入力し「Delete」をクリックする
![6-1-3_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-1-3_2.png)

※ バックグラウンドで削除処理が進み、時間が経てば削除されます

## 6-2. Amazon S3バケットを削除する

S3バケットを削除します。

### 6-2-1. S3サービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「s3」と入力し、候補から「S3」を選択してください

### 6-2-2. Collection登録用のS3バケットを削除する

ステップ2-1で作成したデプロイファイルを格納するためのバケットを削除します。

- バケット検索欄にステップ2-1で作成したバケット名の一部を入力し検索する
![6-2-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-3-2_1.png)

- 対象バケットの左側にチェックをつけ「削除」ボタンをクリックする
例）yamada-rekognition-collection-source
![6-2-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-3-2_2.png)

- 削除するバケットの中にオブジェクトがあるため、最初に空にすることを求められます
「空のバケット設定」をクリックする
![6-2-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-3-2_3.png)

- 空にする対象のバケット名を入力して「空にする」をクリックする
![6-2-2_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-3-2_4.png)

- 空になったので「バケットの削除設定」をクリックする
![6-2-2_5](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-3-2_5.png)

- 削除するバケット名を入力して「バケットを削除」をクリックする
![6-2-2_6](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-3-2_6.png)

## 6-3. AWS Lambdaを削除する

ステップ3−1で作成したAWS Lambdaを削除します。

### 6-3-1. Lambdaサービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「lambda」と入力し、候補から「Lambda」を選択してください

### 6-3-2. AWS Lambdaを削除する

- キーワード検索欄に3-1で作成した関数名の一部を入力し検索する
![6-3-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-4-2_1.png)

- 対象の関数の横のチェックをつけて「アクション」メニューの「削除」をクリックする
![6-3-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-4-2_2.png)

- 削除確認画面で「削除」ボタンをクリックする
![6-3-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-4-2_3.png)

※ 削除確認画面に記載があるようにLambda削除時にはロールとログは削除されませんので、別途削除する必要があります。

## 6-4. API Gatewayを削除する

ステップ3-2で作成したAmazon API Gatewayを削除します。

### 6-4-1. API Gatewayサービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「api」と入力し、候補から「API Gateway」を選択してください

### 6-4-2. Amazon API Gatewayを削除する

- キーワード検索欄に3-2で作成した関数名の一部を入力し検索する
![6-4-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-4-2_1.png)

- 対象の関数の横のチェックをつけて「Actions」メニューの「Delete」をクリックする
![6-4-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-4-2_2.png)

- 削除確認画面で「削除」ボタンをクリックする
![6-4-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-4-2_3.png)

## 6-5. IAM情報を削除する

ステップ3−1で作成したロール・ポリシーのIAM情報を削除します。


### 6-5-1. IAMサービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「iam」と入力し、候補から「IAM」を選択してください

### 6-5-2. IAMユーザーを削除する

- 左メニューのキーワード検索欄にステップ3-1で作成したユーザー名の一部を入力し検索する
![6-5-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-5-2_1.png)

- 削除対象のIAMユーザーの横にチェックをつけ「ユーザーの削除」をクリックする
![6-5-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-5-2_2.png)

- 「はい、削除します」をクリックする
![6-5-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/4-5-2_3.png)

- 同様の手順で左メニューのロール、ポリシーでもキーワード検索で作成したポリシー・ロールを削除してください

### 以上で全てのステップが完了です

- [トップページ](https://iotkyoto.github.io/soracom-ug-reko-handson/)に戻ってください
