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
![6-1-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-1-1_1.png)

### 6-1-2. 顔認証コレクションを削除する

Cloud9環境を削除する前にステップ2-3で作成した顔認識用に作成したコレクションを削除します。

- 右ペインの「＋」をクリックして「New Terminal」をクリックする
![6-1-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-1-2_1.png)

- 以下のコマンドを実行し、コレクションの一覧を確認する
```shell
$ aws rekognition list-collections 
{
    "FaceModelVersions": [
        "5.0"
    ], 
    "CollectionIds": [
        "yamada-authentication-collection"
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
    "FaceModelVersions": [],
    "CollectionIds": []
}
```

### 6-1-3. Cloud9環境を削除する

- ステップ1-1で作成したCloud9環境の右上の丸を選択し「Delete」ボタンをクリックする
![6-1-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-1-3_1.png)

- 入力欄に「Delete」を入力し「Delete」をクリックする
![6-1-3_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-1-3_2.png)

※ バックグラウンドで削除処理が進み、時間が経てば削除されます

## 6-2. Amazon S3バケットを削除する

S3バケットを削除します。

### 6-2-1. S3サービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「s3」と入力し、候補から「S3」を選択してください

### 6-2-2. Collection登録用のS3バケットを削除する

ステップ2-1で作成したコレクションに登録する画像をアップロードするためのバケットを削除します。

- バケット検索欄にステップ2-1で作成したバケット名の一部を入力し検索する
![6-2-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-2-2_1n.png)

- 対象バケットの左側にチェックをつけ「削除」ボタンをクリックする
例）yamada-rekognition-collection-source
![6-2-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-2-2_2n.png)

- 削除するバケットの中にオブジェクトがあるため、最初に空にすることを求められます
「空のバケット設定」をクリックする
![6-2-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-2-2_3n.png)

- 「完全に削除」と入力し「空にする」をクリックする
![6-2-2_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-2-2_4n.png)

- 空になったので「バケットの削除設定」をクリックする
![6-2-2_5](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-2-2_5n.png)

- 削除するバケット名を入力して「バケットを削除」をクリックする
![6-2-2_6](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-2-2_6n.png)

## 6-3. AWS Lambdaを削除する

ステップ3−1で作成したAWS Lambdaを削除します。

### 6-3-1. Lambdaサービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「lambda」と入力し、候補から「Lambda」を選択してください

### 6-3-2. AWS Lambdaを削除する

- キーワード検索欄に3-1で作成した関数名の一部を入力し検索する
![6-3-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-3-2_1.png)

- 対象の関数の横のチェックをつけて「アクション」メニューの「削除」をクリックする
![6-3-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-3-2_2.png)

- 削除確認画面で「削除」ボタンをクリックする
![6-3-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-3-2_3.png)

※ 削除確認画面に記載があるようにLambda削除時にはロールとログは削除されませんので、必要であれば別途削除する必要があります。

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

ステップ3で作成したLambdaにより自動生成されたロール・ポリシーのIAM情報を削除します。

### 6-5-1. IAMサービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「iam」と入力し、候補から「IAM」を選択してください

### 6-5-2. Lambdaにより自動生成されたポリシーを削除する

- 左メニューのアクセス管理欄の「ロール」をクリックしてください。
![6-5-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-5-2_1n.png)

- 検索窓部分に作成したLambdaの関数名の一部（名前）を入力し、対象となるLambda関数名のついたロール名をクリックしてください。
![6-5-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-5-2_2n.png)

- 「アクセス権限」タブ内のポリシー「AWSLambdaBasic~」の名前部分をクリックしてください。
![6-5-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-5-2_3n.png)

- 「ポリシーの削除」をクリックしてください。
![6-5-2_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-5-2_4n.png)

- 表示された画面で「削除」をクリックしてください。
![6-5-2_5](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-5-2_5n.png)

### 6-5-3. Lambdaにより自動生成されたロールを削除する

- 左メニューのアクセス管理欄の「ロール」をクリックしてください。
![6-5-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-5-2_1n.png)

- 検索窓部分に作成したLambdaの関数名の一部（名前）を入力し、対象となるLambda関数名のついたロール名をクリックしてください。
![6-5-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-5-2_2n.png)

- 「ロールの削除」をクリックしてください。
![6-5-2_6](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-5-2_6n.png)

- 「はい、削除します」をクリックしてください。
![6-5-2_7](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-5-2_7n.png)

- 以上でLambda作成時に自動作成されたIAM情報(ロール・ポリシー)の削除は完了です。

## 6-6. CloudWatch Logs情報を削除する

ステップ3で作成したLambdaにより自動生成されたログ情報(CloudWatch Logs)を削除します。

### 6-6-1. CloudWatchサービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「cloudwatch」と入力し、候補から「CloudWatch」を選択してください

### 6-6-2. Lambdaにより自動生成されたロググループを削除する

- 左側メニューの「ロググループ」をクリックしてください。
![6-8-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-8-2_1.png)

- 検索窓にLambda関数につけた名前の一部（例：yamada）を入力し、対象のロググループ(/aws/lambda/{Lambda関数名})にチェックをつけてください。
![6-8-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-8-2_2.png)

- アクションの「ロググループの削除」をクリックしてください。
![6-8-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-8-2_3.png)

- ロググループの削除画面の「削除」をクリックしてください。
![6-8-2_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-8-2_4.png)

- 以上で、ロググループの削除は完了です。

## 6-7. SORACOM SIMグループを削除する

ステップ4で作成したSORACOM SIMグループを削除します。

### 6-7-1. SORACOM管理コンソールにログインする

- [SORACOM管理コンソール](https://console.soracom.io/#/?coverage_type=jp)にアクセスし、ログインしてください。

### 6-7-2. SIMからグループを解除する

- SORACOM管理コンソールの左上のメニューをクリックし、メニューの「SIM管理」をクリックしてください。
![6-6-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-6-2_1.png)

- 対象のSIMのチェックボックスをONにし、画面上部の「操作」から「所属グループ変更」をクリックしてください。
![6-6-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-6-2_2.png)

- 「新しい所属グループ」に **グループ解除** を選択し「グループ変更」をクリックしてください。
![6-6-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-6-2_3.png)

- SIM一覧上の対象のSIMカードのグループが空白になっていることを確認してください。
![6-6-2_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-6-2_4.png)

- 必要であれば変更したSIMの速度クラスを元に戻してください。  
設定変更時と同じ手順となりますので手順は省略します。

### 6-7-3. 作成したSIMグループを削除する

- SORACOM管理コンソールの左端のメニューをクリックしてください。
![6-6-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-6-3_1.png)

- メニューのSIMグループをクリックしてください。
![6-6-3_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-6-3_2.png)

- SIMグループの一覧から4-1-2で作成したグループをクリックしてください。
![6-6-3_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-6-3_3.png)

- 右上の「削除」をクリックしてください。
![6-6-3_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-6-3_4.png)

- 削除確認ウィンドウで削除対象のグループ名であることを確認し「削除」をクリックしてください。
![6-6-3_5](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step6/6-6-3_5.png)

- SIMグループの一覧上から対象のグループが消えていることを確認してください。


### 以上で全てのステップが完了です

- [トップページ](https://iotkyoto.github.io/soracom-ug-reko-handson/)に戻ってください
