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
- AWS Rekognition コレクションを削除する
- AWS Amplifyアプリケーションを削除する
- S3バケットを削除する
- IAM情報を削除する

---

## 4-1. AWS Cloud9 環境を削除する

AWSコンソールにログインし、AWS Cloud9の環境を削除します。

### 4-1-1. Cloud9サービスに移動する

- 画面上部の「サービス」をクリックし検索窓に「cloud」と入力し、候補から「Cloud9」を選択してください
![4-1-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-1_1.png)

### 4-1-2. 顔認証コレクションを削除する

Cloud9環境を削除する前にステップ2-3で作成した顔認識用に作成したコレクションを削除します。

- 右ペインの「＋」をクリックして「New Terminal」をクリックする
![4-1-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-2_1.png)

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

### 4-1-3. Cloud9環境を削除する

- ステップ1-1で作成したCloud9環境の右上の丸を選択し「Delete」ボタンをクリックする
![4-1-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-3_1.png)

- 入力欄に「Delete」を入力し「Delete」をクリックする
![4-1-3_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-3_2.png)

※ バックグラウンドで削除処理が進み、時間が経てば削除されます

## 4-2. AWS Amplifyアプリケーションを削除する

AWS Amplifyアプリケーションを削除します。

### 4-2-1. Amplifyサービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「ampl」と入力し、候補から「AWS Amplify」を選択してください
![4-2-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-2-1_1.png)

### 4-2-2. AWS Amplifyアプリケーションを削除する

- ステップ1-3で作成したAmplifyアプリケーションをクリックする
![4-2-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-2-2_1.png)

- 右上の「アクション」メニューを開いて「アプリの削除」をクリックする
![4-2-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-2-2_2.png)

- 入力欄に「delete」を入力し「Delete」をクリックする
![4-2-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-2-2_3.png)

※ Amplifyアプリケーションが削除されます

## 4-3. Amazon S3バケットを削除する

S3バケットを削除します。

### 4-3-1. S3サービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「s3」と入力し、候補から「S3」を選択してください

### 4-3-2. Amplifyデプロイ用のS3バケットを削除する

ステップ1-2-5で作成したデプロイファイルを格納するためのバケットを削除します。

- バケット検索欄にステップ1-2-5で作成したバケット名の一部を入力し検索する
![4-3-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-3-2_1.png)

- 対象バケットの左側にチェックをつけ「削除」ボタンをクリックする
例）yamada-reko-handson-deployment
![4-3-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-3-2_2.png)

- 削除するバケットの中にオブジェクトがあるため、最初に空にすることを求められます
「空のバケット設定」をクリックする
![4-3-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-3-2_3.png)

- 空にする対象のバケット名を入力して「空にする」をクリックする
![4-3-2_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-3-2_4.png)

- 空になったので「バケットの削除設定」をクリックする
![4-3-2_5](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-3-2_5.png)

- 削除するバケット名を入力して「バケットを削除」をクリックする
![4-3-2_6](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-3-2_6.png)

- 上記と同様の手順で、ステップ2-1で作成したコレクション登録用に作成したバケットを削除してください
（例）yamada-rekognition-collection-source

## 4-4. AWS Lambdaを削除する

ステップ3−1で作成したAWS Lambdaを削除します。

### 4-4-1. Lambdaサービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「lambda」と入力し、候補から「Lambda」を選択してください

### 4-4-2. AWS Lambdaを削除する

- キーワード検索欄に3-1で作成した関数名の一部を入力し検索する
![4-4-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-4-2_1.png)

- 対象の関数の横のチェックをつけて「アクション」メニュの「削除」をクリックする
![4-4-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-4-2_2.png)

- 削除確認画面で「削除」ボタンをクリックする
![4-4-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-4-2_3.png)

※ 削除確認画面に記載があるようにLambda削除時にはロールとログは削除されませんので、別途削除する必要があります。

## 4-5. IAM情報を削除する

ステップ3−1で作成したロール・ポリシー、ステップ3-2で作成したLambda実行用のIAMユーザーを削除します。


### 4-5-1. IAMサービスに移動する

- 画面上部の「サービス」をクリックしてください
- 検索窓に「iam」と入力し、候補から「IAM」を選択してください

### 4-5-2. IAMユーザーを削除する

- キーワード検索欄にステップ3-2で作成したユーザー名の一部を入力し検索する
![4-5-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-5-2_1.png)

- 削除対象のIAMユーザーの横にチェックをつけ「ユーザーの削除」をクリックする
![4-5-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-5-2_2.png)

- 「はい、削除します」をクリックする
![4-5-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-5-2_3.png)

- 同様の手順で左メニューのロール、ポリシーでもキーワード検索で作成したポリシー・ロールを削除してください

### 以上で全てのステップが完了です

- [トップページ](https://iotkyoto.github.io/soracom-ug-reko-handson/)に戻ってください
