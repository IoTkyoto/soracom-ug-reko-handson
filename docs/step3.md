---
layout: default
title: ステップ3. 顔認証のWeb APIを作成する
---

# ステップ3. 顔認証のWeb APIを作成する（SORACOM回線を使ったスマートフォンとAWSサービスを用いた画像認識サービスを構築する）

*当コンテンツは、エッジデバイスとしてスマートフォン、クラウドサービスとしてAWSを利用し、エッジデバイスとクラウド間とのデータ連携とAWSサービスを利用した画像認識を体験し、IoT/画像認識システムの基礎的な技術の習得を目指す方向けのハンズオン(体験学習)コンテンツ「[SORACOM回線を使ったスマートフォンとAWSサービスを用いた画像認識サービスを構築する](https://iotkyoto.github.io/soracom-ug-reko-handson/)」の一部です。*

# ステップ3. 顔認証のWeb APIを作成する

![ステップ3アーキテクチャ図](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/architecture_step3.png)

ステップ3では、アップロードされた画像を分析し、「事前登録済みの人物が写っているか、写っている場合は誰かを判定する」機能を持ったWeb APIを作成し、デバイス側からAPIを呼び出す仕組みを構築します。

まずは、「**[Amazon Rekognition（以下、Rekognition）](https://aws.amazon.com/jp/rekognition/)**」を利用して「コレクション」を作成し、認識対象となる顔を登録します。
次に、作成したコレクションを使って顔の認識を行う「**[AWS Lambda（以下、Lambda）](https://aws.amazon.com/jp/lambda/)**」を作成します。
さいごに、作成したLambdaにHTTPでアクセスするために「**[Amazon API Gateway（以下、API Gateway）](https://aws.amazon.com/jp/api-gateway/)**」を作成します。

---

### 目的

- デバイスから外部APIに利用する方法を学ぶ
- JSON形式のファイルの取り扱いを学ぶ
- AWSでのAPI構築方法を学ぶ
- AWSの画像認識機能を知る

### 概要

- 顔認証用のWebAPIを作成し、デバイスからWebAPIを利用する
 - APIのリクエスト・レスポンスを取り扱う
 - WebAPIの認証はAPIキーを使う
- 顔認識用のコレクションを作成し、対象者が画像に写っているかどうかの画像認識を行う

---

### ＜Web APIとは？＞

HTTPプロトコルを利用してインターネットを介したアプリケーション間のやりとりを行うためのインターフェースです。
Web APIの代表的な実装方式として、RESTとSOAPが存在しており、今回作成するWeb APIはREST APIとなります。

- REST
  - RESTとはRepresentational State Transferの略称
  - 以下のRESTの思想に従って実装されたAPIをRESTful API（またはREST API）と呼ぶ
    - HTTPのメソッド（命令）でデータ操作種別（CRUD）を表す
    - ステートレス
    - URIで操作対象のリソースを判別可能にする
    - レスポンスとしてXMLもしくはJSONで操作結果を戻す
- SOAP
  - SOAPは、XMLを利用したWebサービス連携プロトコル
  - XMLで記述された「SOAPメッセージ」と呼ばれるデータをやりとりすることで、メッセージを交換する

様々な公開Web APIが提供されていることや、わかりやすいデータのやり取りから、Web APIを利用してモノリシックなシステムをマイクロサービス化することが現在の潮流となっています。


### ＜AWS Lambdaとは？＞

AWS Lambdaは、サーバーをプロビジョニングしたり管理する必要なくコードを実行できるサーバーレスコンピューティングサービスです。これは他のAWSサービスをトリガーとして実行することができ、実際に処理にかかった時間やリクエスト数に対して従量課金されます。Lambda関数はJavaやPythonをはじめとした一般的なプログラミング言語で作成することができます。

- サーバー管理が不要
- 実行時のメモリ量を指定することで、それに比例したCPUパワー/ネットワーク帯域/ディスクIOが割り当てられる
- リクエスト受信の回数に合わせて自動的にスケールする
- コードが実行されている間のコンピューティング時間に対しての[ミリ秒単位の課金](https://aws.amazon.com/jp/lambda/pricing/)
- Java、Go、PowerShell、Node.js、C#、Python、Rubyのコードをサポート
- カスタムランタイムで上記以外の言語の使用も可能(COBOLなど)

より詳しく知りたい場合は[公式サイト](https://aws.amazon.com/jp/lambda/)をご確認ください。

### ＜Amazon API Gatewayとは？＞

Amazon API Gatewayは、開発者があらゆる規模でAPIの公開、保守、モニタリング、セキュリティ保護、運用を簡単に行えるフルマネージドサービスです。
セキュアで信頼性の高いAPIを大規模に稼働させるために、差別化にはつながらない面倒な作業を処理する従量制のサービスです。
AWS、または他のウェブサービス、AWSクラウドに保存されているデータにアクセスするAPIを作成できます。ユースケースとしては、モバイルアプリやWebアプリケーションのバックエンドAPIとして、API GatewayとLambdaを連携させて、サーバレスなREST API環境を構築するケースでよく使われます。

- スケーラブル
    - 最大数十万規模の同時APIコールの受け入れと処理に伴うすべてのタスクを取り扱うことが可能
    - 内部でCloudFrontの仕組みを利用しており、スケーラビリティやアベイラビリティの面でCloudFrontの特徴を享受している
- APIの作成およびデプロイが容易
    - APIのステージング管理が可能
    - Canaryリリースのデプロイが可能
- ステートフル(WebSocket)およびステートレス(REST)なAPIのサポート
- 強力で柔軟性に優れた認証メカニズム
    - IAMポリシー、Lambdaオーソライザー関数やCognitoユーザープールなどでの認証が可能
- APIリクエスト数に応じた安価な[従量課金](https://aws.amazon.com/jp/api-gateway/pricing/)

より詳しく知りたい場合は[公式サイト](https://aws.amazon.com/jp/api-gateway/)をご確認ください。

### ＜APIキー認証とは？＞

API Gatewayがサポートする認証方式の１つで、所定のキー(文字列)をHTTPヘッダ(x-api-keyヘッダ)に含めたリクエストであればアクセスを許可、無ければアクセスを拒否する機能です。APIキーの発行・管理は、API Gateway側で行われます。
また、ユーザごとにAPIキーを発行し、ユーザごとに呼び出し回数に制限をかけるというような使用法も可能です。
ただし、APIキーはヘッダー解析などをされることで漏洩する可能性がありますので、認証の唯一の手段としてAPIキーを使用することはベストプラクティスではありません。
認証機能が必要な場合は、IAMロール、Lambdaオーソライザー、または Amazon Cognitoユーザープールを使用するようにしてください。
https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/api-gateway-api-usage-plans.html


## 3-1. Lambdaを作成

ここでは、スマホからAPI Gatewayを通して受け取った顔画像が、ステップ２で作成したRekognitionのコレクションに登録済みの人物とマッチするかどうか、マッチする場合は誰であるかリターン値として返すLambdaファンクションを作成します。

### 3-1-1. Lambda関数を作成する

- AWSのコンソール画面で、「Lambda」を検索・選択し、[関数の作成]をクリックしてください。
![3-1-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-1_1.png)

- 以下の項目をそれぞれ選択・入力し、[関数の作成]をクリックしてください。
  - 一から作成
  - 関数名： {名前}_lambda_authentication（例：yamada_lambda_authentication）
  - ランタイム： `Python 3.8`
![3-1-1_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-1_2n_2.png)
  - アクセス権限：[ ▼ 実行ロールの選択または作成]を開き、**「基本的なLambdaアクセス権限で新しいロールを作成」** が選択されていることを確認してください。
![3-1-1_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-1_3n.png)

「基本的なLambdaアクセス権限」を指定することで、Lambda実行時のログをCloudWatch Logsにアップロードするためのロールが自動的に付与されます。
次のステップで、Lambdaのソースコードから使用するAWSサービスに対する必要な権限をカスタムで追加します。


### 3-1-2. Lambdaに必要な権限を付与する
LambdaからRekognitionのAPIにアクセスができるように、以下の手順で権限をインラインポリシーとして追加してください。

- 画面上部の「アクセス権限タブ」をクリックしてください。
![3-1-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-2_1n.png)

- 実行ロール欄のロール名のリンク「xxxxxxxxx-role-xxxxxxxx」をクリックしてください。
![3-1-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-2_2n.png)

- このLambdaに紐づいたロール詳細画面が開きますので、「インラインポリシーの追加」をクリックしてください。
![3-1-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-2_3n.png)

- サービスの「サービスの選択」をクリックしてください。
![3-1-2_4_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-2_4_1.png)

- サービスの検索窓に「Reko」を入力し、候補から「Rekognition」を選択してください。
![3-1-2_4_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-2_4_2.png)

- アクションの検索窓に「Sea」を入力し、候補から「SearchFacesByImage」を選択し、リソースの「collection リソース ARN を指定します。 SearchFacesByImage アクション」をクリックしてください。
![3-1-2_4_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-2_4_3.png)

- リソースの「指定」がチェックされていることを確認し「ARNの追加」をクリックしてください。
![3-1-2_4_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-2_4_4.png)

- ARNの追加ウィンドウで以下の内容を設定し「追加」をクリックしてください。
  - Region： `ap-northeast-1`
  - Account： 「すべて」にチェック
  - Collection Id：ステップ2-3-1で作成したコレクション名 (例： `yamada-authentication-collection`)
![3-1-2_4_5](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-2_4_5.png)

- 「ポリシーの確認」をクリックしてください。
![3-1-2_4_6](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-2_4_6.png)


- ポリシーの名前「{名前}-handson-rekognition-policy」(例： `yamada-handson-rekognition-policy`)を入力して「ポリシーの作成」をクリックしてください。
![3-1-2_5](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-2_5n.png)

- 作成したポリシーが紐づいたことを確認してください。
![3-1-2_6](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-2_6n.png)

### 3-1-3. Pythonの関数コードを作成する
    
Lambdaが実行するPythonコードを作成します。

- Lambdaの関数画面に戻り「設定」タブを開き「関数コード」欄を表示してください。
![3-1-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-3_1n.png)


- 関数コード部分にはデフォルトのコードが記載されていますので、コードを一度削除して下さい。
![3-1-3_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-3_2n.png)

- 以下のサンプルプログラムのソースをコピー＆ペーストしてください。
サンプルプログラムは[こちら](https://github.com/IoTkyoto/soracom-ug-reko-handson/blob/master/sources/step3/lambda_authentication.py)の `lambda_authentication.py`を使用してください。
「Raw」をクリックするとソースコードが別タブで表示されますのでコピーしやすい状態になります。
![3-1-3_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-1_3n_1.png)

- コードの15行目の以下の部分の「`{collection_id}`」を、ステップ1-3-1で作成したコレクション名（例：`yamada-authentication-collection`）に変更してください

```python:変更前
  # Rekognitionで作成したコレクション名を入れてください
  COLLECTION_ID = '{collection_id}'
```
```python:変更後
  # Rekognitionで作成したコレクション名を入れてください
  COLLECTION_ID = 'yamada-authentication-collection'
```

- 右上の「デプロイ」をクリックしてください
![3-1-3_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-3_3n.png)

### 3-1-4. Lambdaのタイムアウト時間の設定を行う

今回のLambdaの関数コードでは、パラメータで受け取った画像データをRekognitionに渡して画像認識を実行します。  
画像のサイズによっては処理時間がかかることを想定し、タイムアウト設定をデフォルトの3秒から20秒に変更します。  

- 画面上部の「設定」タブをクリックしてください。
![3-1-4_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-6_1.png)

- 画面を下の方にスクロールさせて、基本設定項目の「編集」をクリックしてください。
![3-1-4_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-6_2.png)

- タイムアウトの値を「0分3秒」から「0分20秒」に変更し「保存」をクリックしてください。
![3-1-4_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-6_3.png)

- 基本設定項目のタイムアウト項目が「0分20秒」にへんこうされていることを確認してください。
![3-1-4_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-6_4.png)


### 3-1-5. Lambdaのテストを実行する

Lambdaの関数コードを保存したら、API Gatewayから渡されてくる想定のイベントデータを用意し、Lambdaに渡して、実際の動きをテストしてみましょう。

- 関数画面右上の[テスト]をクリックしてください
![3-1-4_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-4_1n.png)

- テストイベントの設定画面で以下の内容を入力して「作成」をクリックしてください。
  - 新しいテストイベントの作成：チェック
  - イベントテンプレート：Hello World（デフォルト）
  - イベント名：任意の名前（例：AuthTest）
  - テストデータ：以下のjsonファイルの内容。画像のデータや閾値を適宜変更してください。

- テストデータは[こちら](https://github.com/IoTkyoto/soracom-ug-reko-handson/blob/master/sources/step3/lambda_authentication_event_example.json)の `lambda_authentication_event_example.json`をご確認ください。

- テストデータの内容をコピーし、テストイベントのコード欄に貼り付けてください
![3-1-4_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-4_2.png)

- 作成したら、[テスト]をクリックし、実行結果を確認しましょう。  
関数の実行結果は、中をスクロールして見ることが可能です。  
また、一部ブラウザでは実行結果が改行されていない状態で表示されることもござます。その際はメモ帳等にコピー＆ペーストしてご確認ください。
![3-1-4_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-4_3.png)
![3-1-4_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-4_4.png)
![3-1-4_5](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-1-4_5.png)

- 今回テストとして送信した画像はコレクションに未登録の人物ですので、テストの結果として、「statusCode:200」と「FaceMatches」として空の配列が返ってきていれば成功です。

###  3-1-6. 作成プログラムの解説

今回使用するLambdaコードの解説となります。

- import一覧
    - 必要なライブラリをimportしてください

```python:lambda_function.py
  import json                      # JSONフォーマットのデータを扱うために利用します
  import boto3                     # AWSをPythonから操作するためのSDKのライブラリです
  from typing import Union, Tuple  # 変数や引数・返り値などの型定義に利用します
  from datetime import datetime    # この関数を動かした（＝顔の認証を行なった）時間をtimestampとして作成するのに利用します
  import botocore.exceptions       # boto3の実行時に発生する例外クラスです
  import base64                    # base64フォーマットの画像データをRekognitionが認識できる形に変換するのに利用します
```

- API Gatewayに投げ込まれたデータは、 `lambda_handler`の引数となっている `event`の中に `body`として渡されます
	- `body`はJSON形式で渡されますので、Pythonで処理できる形にするために `json.loads`メソッドを利用しましょう
	- 今回、APIが呼ばれる際のパラメーターとして、以下のデータを受け取ることを想定して実装します
		- `image_base64str`：認証を行いたい顔画像ファイル(pngもしくはjpeg)をbase64でエンコードしたデータ(文字列型)
		- `threshold`：Rekognition実行時、コレクションに登録している顔との一致度合いがいくら以上の時に結果を返すか、という閾値(%)(数値型)。オプション項目なので、設定しない場合はRekognitionが持つデフォルト値の80%が自動的にセットされます

- base64のメソッド `b64decode`を使用し、base64でエンコードされたデータをバイナリデータに変換する
  - APIが受け取ったデータ `image_base64str`の形式のままでは、下で説明するRekognitionへのアクセスに利用できません
  - 画像データをbase64フォーマットに変換すると、ツールによってはHTMLに埋め込む際などに便利な"data URI scheme"に沿った形式で出力されます（例： `data:image/png;base64,{base64のデータ}`。こちらの記述はRekognitionに渡す必要がないので、カンマ部分より前に何かあれば取り出す処理を行います

```python:lambda_function.py
  # 画像データから不要な値を抜き出す(コンマがない場合は不要な値がないとし、全文字列を利用)
  image_base64str = image_base64str[image_base64str.find(',') + 1 :]
  return base64.b64decode(image_base64str)
```

- boto3 client `rekognition`のメソッド `search_faces_by_image`を使用する
	- 引数として、APIから受け取るデータの他に対象のコレクションIDの指定が必要です。
	- こちらのドキュメントを参考に、実装してください：
		- https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/rekognition.html#Rekognition.Client.search_faces_by_image
	- `Image`パラメーター内の `'Bytes'`は、画像のバイナリデータを指定します
	- `MaxFaces`は、指定した画像から検出する顔の最大数を指定します
  - `FaceMatchThreshold`は、一致と判断する閾値(%)を指定します

```python:lambda_function.py
  # RekognitionのClientを生成
  REKOGNITION_CLIENT = boto3.client('rekognition')
  # 画像とマッチする人物を特定する
  search_result = REKOGNITION_CLIENT.search_faces_by_image(
      CollectionId=self.collection_id,
      Image={
            'Bytes': image_binary
      },
      MaxFaces=self.max_faces,
      FaceMatchThreshold=threshold
  )
```

- Lambdaの実行結果として返すレスポンスのボディとして、実際のデータを意味する `'payloads'`という辞書型のデータを作成しましょう
	- `'payloads'`の中に、`search_faces_by_image`の戻り値（辞書型）と `'timestamp'`属性を入れましょう
	- 下記の例のように `update`メソッドを利用すると、辞書型の中に辞書型のデータを入れることができます
		- `payloads.update(data)`（引数 `data`は `search_faces_by_image`の戻り値が格納されている変数）
	- `'timestamp'`の作成には、import一覧（例）にある標準モジュールの `datetime`が利用できます
	- `'timestamp'`の値のフォーマットは、可視化をする場合などに使いやすい`'YYYY-MM-DD hh:mm:ss'`が良いでしょう
	- レスポンスデータは `json.dumps`メソッドを利用してJSON形式にして返しましょう

```python:lambda_function.py
  # タイムスタンプ生成
  date_now = datetime.now()
  # 辞書型の変数定義
  payloads: dict = {}
  # タイムスタンプを設定
  payloads['timestamp'] = str(date_now.strftime('%Y-%m-%d %H:%M:%S'))
  # search_faces_by_imageの戻り値を設定
  payloads.update(search_result)
  # レスポンス用のBodyを生成
  body = json.dumps({'msg': msg, 'payloads': payloads})
```

- エラーハンドリングを実装する
try文を用いるなどして、Rekognitionへのアクセスの成否を反映したレスポンスを実装してみましょう。
なお、Lambda関数コード内で実装した `print()`メソッドによる出力は、CloudWatchのログで確認でき、通常はデバッグの用途で利用します。


## 3-2. API Gatewayを作成する

デバイス側から作成したLambdaを使用するために、API GatewayでREST APIを作成します。

### 3-2-1. APIを作成する

- AWSのコンソール画面で「API Gateway」を検索し、API Gatewayのコンソール画面を開いてください。

- 【作成済みのAPIが１つも存在しない場合】画面下部の「REST API」の「構築」をクリックしてください。
![3-2-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-1_1n.png)
![3-2-1_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-1_2n.png)

- 【作成済みのAPIが存在している場合】API一覧画面右上部の「APIを作成」をクリックし、次画面でREST APIの「構築」をクリックしてください。
![3-2-1_2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-1_2n2.png)
![3-2-1_2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-1_2n3.png)


- 「新しいAPI」を選択します
![3-2-1_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-1_3n.png)

- 以下の項目をそれぞれ入力し、[APIの作成]をクリックします。
    - API名： 任意の名前（例：yamada-rekognition-api）
    - エンドポイントタイプ： **リージョン**
![3-2-1_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-1_4n.png)

### 3-2-2. APIにリソースを追加する

作成直後のAPIには、具体的なアクセス先のリソースが存在していない状態です。
APIにリソースを追加し、ステップ3-1で作成したLambdaを呼び出すAPIリソースを作成します。

- 左メニューのAPI一覧で3-2-1で作成したAPIが選択されていることを確認する
- 「リソース」を選択する
- `/`が選択されている状態で「アクション」をクリックし「リソースの作成」を選択する
![3-2-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-2_1.png)

- 新しい子リソース画面で以下の内容を入力し「リソースの作成」をクリックする
  - プロキシリソースとして設定する：チェックなし
  - リソース名：search
  - リソースパス：search
  - API Gateway CORSを有効にする：チェック
![3-2-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-2_2.png)

---

#### ＜リソースとは？＞

Amazon API Gatewayでは、API Gatewayリソースと呼ばれるプログラム可能なエンティティのコレクションとして REST API を構築できます。各 Resource エンティティは、Method リソースを 1 つ以上持つことができます。リクエストパラメーターと本文で表された Method は、クライアントが公開された Resource にアクセスするためのアプリケーションプログラミングインターフェイスを定義し、クライアントによって送信された受信リクエストを表します。
https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/how-to-create-api.html

#### ＜CORSとは？＞

Cross-origin resource sharing (CORS) は、ブラウザで実行されているスクリプトから開始されるクロスオリジン HTTP リクエストを制限するブラウザのセキュリティ機能です。
REST API のリソースが非シンプルクロスオリジンの HTTP リクエストを受け取る場合、CORS サポートを有効にする必要があります。
Web APIは、元来パブリックに公開されず、リソースのオリジンが共有された一つのサービスの内部機能として利用されていました。
そのことから、オリジンが異なるリソースからのアクセスを受けた際、デフォルトではアクセスを拒否してしまいます。
CORSを設定することで、どのアクセス元からのアクセスを許可するかを制御することができるようになります。
https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/how-to-cors.html

---

### 3-2-3. APIにメソッドを追加する

APIにはHTTPメソッドが必要です。
ステップ3-1-3で作成したLambda実行コードに必要なデータをAPI経由で渡す必要があるため、レスポンスボディが使用できる`POST`にします。

- リソースで「`search`」が選択されている状態で「アクション」をクリックし「メソッドの作成」を選択してください。
![3-2-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-3_1.png)

- メソッド欄の「OPTIONS」の下にコンボボックスが表示されるため、「POST」を選択し☑️をクリックしてください。

### 3-2-4. APIの統合先をセットする

APIメソッドを設定したら、バックエンドのエンドポイントに統合する必要があります。
バックエンドのエンドポイントは、統合エンドポイントとも呼ばれ、Lambda関数、HTTPウェブページ、または AWSのサービスアクションとして使用できます。
今回は、前ステップで作成したLambdaと統合しましょう。

- 「/search - POST - セットアップ」画面で以下の内容を入力し「保存」をクリックしてください。
  - 統合タイプ：Lambda 関数  
  - Lambda プロキシ統合の使用：チェックを入れる
  - Lambda リージョン：`ap-northeast-1`
  - Lambda 関数：ステップ3-1-1で作成したLambda関数を入力（例：yamada_lambda_authentication）
  - デフォルトタイムアウトの使用：チェックを入れる
![3-2-4_1](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-4_1.png)

- [保存]をクリックすると、当該APIリソースが上で指定したLambda関数にアクセスするための権限を自動で作成するか確認されるため[OK]をクリックしてください。
![3-2-4_2](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-4_2.png)

#### ＜Lambdaプロキシ統合とは？＞

Amazon API Gateway Lambdaプロキシ統合は、単一のAPIメソッドのセットアップでAPIを構築するシンプル、強力、高速なメカニズムです。
Lambdaプロキシ統合は、クライアントが単一のLambda関数をバックエンドで呼び出すことを可能にします。
クライアントがAPIリクエストを送信すると、API Gatewayは、統合されたLambda関数にリクエストをそのまま渡します。
このリクエストデータには、リクエストヘッダー、クエリ文字列パラメータ、URLパス変数、ペイロード、および API設定データが含まれます。
バックエンドLambda関数では、受信リクエストデータを解析して、返すレスポンスを決定します。

詳細は[公式ドキュメント](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html)をご確認ください。

### 3-2-5. APIへのアクセスにAPIキーを必要とする設定にする

APIを公開すると、エンドポイントURLを知っている人は誰でもアクセス可能となります。
今回作成するAPIには、簡易な認証機能としてAPIキーによる認証を追加しましょう。

- 対象のメソッドを選択して「メソッドリクエスト」をクリックしてください。
![3-2-5_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-5_1n.png)

- APIキーの必要性の鉛筆マークをクリックしてください。
![3-2-5_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-5_1_2.png)

- 「APIキーの必要性」を `true`に変更し、☑️をクリックしてください。
☑️をクリックしないと反映されませんのでご注意ください。
![3-2-5_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-5_1_3.png)

*OPTIONSメソッドの「APIキーの必要性」は `true`にする必要はありません。*

#### ＜OPTIONSメソッドとは？＞

OPTIONSメソッドは、リソース作成時にCORSを有効にすることで自動的に作成されます。
このメソッドは、リソースに対するアクセスの際に、必ず最初に経由されます。
これにより、受け取ったリクエストのオリジンをOPTIONSのものと置き換えることで、オリジンの違いによるアクセス拒否を回避しています。

### 3-2-6. APIをデプロイする

作成したAPIは、デプロイすることで外部からアクセスすることが可能となります。
作成したAPIをデプロイしてみましょう。

- 対象APIのリソース「`/`」を選択した状態で、「アクション」をクリックし「APIのデプロイ」を選択する
![3-2-6_1](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-6_1.png)

- APIのデプロイウィンドウで、以下の項目を入力し「デプロイ」をクリックする
  - デプロイされるステージ：新しいステージ
  - ステージ名：任意のステージ名（例：prod）
  - ステージの説明：任意
  - デプロイメントの説明：任意
![3-2-6_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-6_1n.png)

- prodステージエディターが表示されればデプロイは完了
![3-2-6_3](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-6_3.png)

ステージは、APIを公開後も安定してAPIのエンドポイントを供給しながら開発を行う上で必須の機能です。

#### ＜API Gatewayのステージとは？＞

ステージは、デプロイに対して名前を付けたAPIのスナップショットとなります。
API Gatewayでは、ステージごとに別の設定やステージごとの変数を定義することが出来ます。
また、APIにアクセスするエンドポイントURLにはステージ名が含まれますので、例えば「v1.0」「v2.0」というステージを用意して
過去バージョンを保証したデプロイや、ステージを利用したカナリアリリースが可能となります。
詳細は[公式サイト](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/set-up-stages.html)をご確認ください。

### 3-2-7. APIの使用量プランとAPIキーを作成する

APIキーに対して使用量プランを設定しましょう。
以下の説明を参考に紐付けるAPIキーでのアクセスの頻度を想定して、使用量を設定してください。

---

#### ＜使用量プランとは？＞
API Gatewayでは、使用量プランに紐付けたAPIキーの利用頻度を測定・制限することが可能です。
APIキーは使用できる回数分だけ「トークンバケット」に補給され、ここにある分だけがAPIへのアクセスに利用できます。
ページ内項目の「スロットリング」の「レート」は1秒ごとにトークンバケットに登録されるAPIキーを、「バースト」はバケットに入るトークンの最大数を表しています。
「クォータ」はある期間中にAPIキーが利用できる回数を示します。
この他にも様々な方法でAPIの利用を監視・制限できます。
詳細は[公式ドキュメント](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/api-gateway-request-throttling.html)をご確認ください。

---

- 左のメニュー欄から「使用量プラン」を選択し「作成」をクリックする

- 使用量プランの作成画面で以下のように入力し「次へ」をクリックする
  - 名前：任意の名前（例：yamada-authentication-api-plan）
  - 説明：任意
  - スロットリングの有効化：チェックを入れる
    - レート：50
    - バースト：200
  - クォータを有効にする：チェックを入れる
    - クォータ：2000/ 月
  
  ![3-2-7_1n](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-7_1n.png)

- 関連付けられたAPIステージ画面で「APIのステージの追加」をクリックする
![3-2-7_1](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-7_1.png)

- APIの選択ボックスで作成したAPI（例：`yamada-rekognition-api`）を選択する
- ステージの選択ボックスで先ほどデプロイしたステージ（例：`prod`）を選択する
- 右端の☑️をクリックする
![3-2-7_2](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-7_2.png)

- 「次へ」をクリックする
![3-2-7_3](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-7_3.png)


- 「APIキーを作成して使用量プランに追加」をクリックする
![3-2-7_4](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-7_4.png)

- APIキー画面で以下を入力し「保存」をクリックする
  - 名前：任意の名称（例：test-user）
  - APIキー：自動生成
  - 説明：任意
![3-2-7_5](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-7_5.png)

- 「完了」をクリックする
![3-2-7_6](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-7_6.png)

- これで、作成した使用量プランとデプロイしたAPIのステージ、そしてAPIキーが紐づきました。
  APIの使用量プランは、デプロイしたAPI Gatewayのステージと紐づきますので、ご注意ください。

### 3-2-8. cURLでAPIをテストする

APIGAtewayが正常に稼働することを確認するために、cURLの `curl`コマンドを利用して、前のステップで作成したAPIにアクセスしてみましょう。

今回のケースでは、画像のBase64形式データの文字数が多く、コマンドラインからの直接入力は大変なため、shellファイルを修正してコマンドラインから実行します。

### 3-2-8-1. Shellファイルを編集する

- AWSコンソールからステップ1で作成したCloud9を開いてください

- 画面左のディレクトリツリーから「soracom-ug-reko-handson/sources/step3/curl_authentication_test_format.sh」をダブルクリックして開いてください

- 下記の解説に従い、shellファイルの中身を確認し、１行目〜４行目の変数部分を自分の環境の値に変更して保存してください。
  - API_ID：下記の「API IDの確認方法」に沿って確認してください。
  - STAGE：ステップ3-2-6で作成したAPIをデプロイしたステージ名。（例：prod）
  - RESOURCE：ステップ3-2-6で作成したAPIをデプロイしたステージ名。（例：prod）
  - API_KEY：ステップ3-2-7で作成したAPIキー。下記「APIキーの確認方法」に沿って確認してください。

#### ＜curlコマンドの解説＞

- shellファイルは[こちら](https://github.com/IoTkyoto/soracom-ug-reko-handson/blob/master/sources/step3/curl_authentication_test_format.sh)の `curl_authentication_test_format.sh`をご確認ください。

**echoコマンドについて**

- 画像データが大きいため、`echo`コマンドを利用してAPIのリクエストボディに含めたいデータを出力します
- `echo`の引数である文字列内の`threshold`や `image_base64str`の値を書き換え、APIに投げ込むデータを適宜変更してください
- パイプ（ `|`）はデータの受け渡しを行います。今回の場合、 `echo`が出力したデータを次のコマンド、つまり `curl`に渡します

**curlコマンドについて**

- `-X`でHTTPメソッド `POST`を指定します
- POSTの後ろにアクセスするAPIのURLを記述します。URLは文字列としてダブルクォーテーションで囲みます。
- `-H`でヘッダーを表します。今回はヘッダー情報として、X-Api-Key項目としてAPIキーを設定します。
- `-d`でデータを表します。ここでは、パイプ経由で渡された値を表す `-@`を指定します

**API IDの確認方法**

- AWSのコンソールで、API Gatewayサービスを開いてください。
- 画面左のメニューから「API」をクリックしAPI一覧を表示してください。
- 対象のAPI（例:yamada-rekognition-api）のID欄に表示されているIDがAPI IDとなります。
  ![3-2-8-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-8-1_1.png)

**APIキーの確認方法**

AWSのコンソールで、ステップ3-2-7で作成したAPIキーを[表示]します。

![3-2-8-1_2](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-8-1_2.png)

- 変数の入力が終わったら、ファイルを保存し、実行します
```shell:実行コマンド例
$ sh soracom-ug-reko-handson/sources/step3/curl_authentication_test_format.sh
```

- コマンドを実行すると、以下のようなレスポンスが返ってきます。
Curlで送信した画像データは、サンプル画像（フリー素材モデルの[大川 竜弥](https://www.pakutaso.com/web_ookawa.html)さん）のため、各自で登録した自分の顔画像一致することはありません。
レスポンスデータの中身が以下のようになっていることを確認してください
  - msgが「[SUCCEEDED]Rekognition done」（Rekognition実行成功）であること
  - timestampが実行時の日時（UTC表記のため現在日時の-9時間）であること
  - FaceMatchesが「[]」（該当顔データなし）であること

```shell:実行結果
{"msg": "[SUCCEEDED]Rekognition done", "payloads": {"timestamp": "2021-01-21 00:30:17", 
"SearchedFaceBoundingBox": {"Width": 0.38512182235717773, "Height": 0.4992198646068573, 
"Left": 0.34464046359062195, "Top": 0.27895471453666687}, "SearchedFaceConfidence": 99.99970245361328, 
"FaceMatches": [], "FaceModelVersion": "5.0", "ResponseMetadata": {"RequestId": "241e83cb-57c3-478b-a57b-b408aa04b5eb", 
"HTTPStatusCode": 200, "HTTPHeaders": {"content-type": "application/x-amz-json-1.1", 
"date": "Thu, 21 Jan 2021 00:30:16 GMT", "x-amzn-requestid": "241e83cb-57c3-478b-a57b-b408aa04b5eb", 
"content-length": "223", "connection": "keep-alive"}, "RetryAttempts": 0}}
```

---

#### ＜cURLとは？＞

URLの書き方でファイルの送受信が行えるオープンソースのコマンドラインツールです。
WebサイトやAPIサーバーのポート疎通確認によく利用され、HTTP/HTTPSの他にも様々なプロトコルに対応しています。コマンドラインで `curl`コマンドとして利用します。

#### ＜Base64とは？＞

Base64とは、データを64種類の印字可能な英数字のみを用いて、それ以外の文字を扱うことの出来ない通信環境にてマルチバイト文字やバイナリデータを扱うためのエンコード方式です。
具体的には、A–Z, a–z, 0–9 までの62文字と、記号2つ (+, /)、さらにパディング（余った部分を詰める）のための記号として = が用いられる。

---

## 3-3. 【参考】 Web APIを利用するプログラム

### 3-3-1. 顔認証を行うWeb APIにアクセスするプログラムを作成する

今回はWebアプリケーションは構築済みですので、参考情報としてどのようにWebアプリケーション（Vue.jsプログラム）側を実装するのかをご紹介します。

デプロイしたWebアプリケーションにはすでにAPIにアクセスするためのプログラムが組み込まれていますので、こちらの章ではコードを適宜引用しながら、APIにアクセスしている部分の解説を行います。

- Webアプリケーションのリポジトリを開き、以下のファイルを開いてください
  - https://github.com/IoTkyoto/soracom-ug-reko-handson/blob/master/webapp/src/components/SearchFacesSoracom.vue

### APIアクセス用のプログラムの解説

SORACOMメタデータを使用する箇所の解説は、次のステップで行いますので、こちらでは省略します。

#### `<template></template>`タグ内の要素について

- 画面のコンポーネントにはマテリアルデザインコンポーネントフレームワークの「[Vuetify](https://vuetifyjs.com/ja/)」を使用しています。

- templateタグ内には、画面に表示する要素をHTMLで記述します

- コードの２６行目〜２７行目のv-container内のテキストフィールドタグ( `v-textarea`)内にある「`v-model="xxxxx"`」の `v-model`は、このフィールドに入力された値をプロパティ値「`apiEndpoint`(APIのエンドポイント)」「`apiKey`(APIキー)」としてリアルタイムに反映・保持します。

- コードの２８行目のselectタグ(`v-select`)内でも、 `v-model`を利用し「 `threshold`(閾値)」の値を保持します。
選択可能な要素は、`:items="[10,20,30,40,50,60,70,80,90,100]"`で指定しています。

- コードの４６行目のinputタグ( `v-file-input`)内にある「 `@change="onFileChange"`」は、ここに要素が入力されたことをトリガーに実行したい関数を表しています。

- コードの７９行目のbuttonタグ( `v-btn`)内にある「 `@click="execRekognition"`」は、ボタンクリック時に実行したい関数を表しています。

#### `<script></script>`タグ内の要素について

- 必要なライブラリのimport定義をします。
  - [axios](https://github.com/axios/axios)はブラウザとnode.js用のPromiseベースのHTTPクライアントとなります。

```javascript:SearchFaces.vue
  import axios from 'axios';
```

##### APIへのアクセスに必要なパラメータを準備する

**リクエストヘッダー情報**

APIキーを、`'x-api-key': 'xxxxxxxxxxxxxxxxxxxxxxxx'`という形式で、ヘッダー情報に組み込みます。

また、やり取りするデータ形式を指定するため `'Content-type': 'application/json'`も入れましょう。

`this.apiKey`で、このコンポーネントが持つ`apiKey`プロパティの値を取得できます。ここでは、コードの２７行目で画面から入力された値が最新値として代入されます。

this.apiKeyには画面生成時にCofigファイル(Mixins)の値を初期値として設定しています。
https://github.com/IoTkyoto/soracom-ug-reko-handson/blob/master/webapp/src/mixins/ConfigMixin.js


```javascript:SearchFaces.vue
// 画面作成時にコンポーネント内で利用する変数の初期値を設定する
created() {
  ・・・(省略)・・・
  this.apiKey = this.config.searchConfig.apiKey
  ・・・(省略)・・・
},

// ヘッダー情報を設定する
const config = {headers: {
  'Content-Type': 'application/json',
  'x-api-key': this.apiKey,
}};
```

**リクエストボディ情報**

ステップ3-1-3で作成したLambda関数コードが想定しているパラメータデータの値を用意します。

`base64data`には、 `createImage()`関数内の `FileReader`メソッドの実行結果として画像ファイルのbase64データ（data URI scheme形式）を利用します。

`threshold`では、`this.threshold`で、コードの３１行目で画面で選択された値を最新値として利用します。

```javascript:SearchFaces.vue
// コンポーネント内で利用する変数の初期値を設定する
created() {
  ・・・(省略)・・・
  this.threshold = this.config.searchConfig.threshold
},

// リクエストボディ情報を作成する
const querydata = {
  'image_base64str': this.uploadedImage,
  'threshold': this.threshold,
};

// 入力されたファイルをFileReaderでbase64(data URI scheme)にエンコードする
createImage(file) {
  const reader = new FileReader();
  
  reader.onload = e => {
    // ここにファイルの読み込み処理(readAsDataURL())実行後の処理を記述
    // 以下は画面表示・APIアクセスに利用します
    this.uploadedImage = e.target.result;
  };
  // data URI scheme形式でファイルを読み込む
  reader.readAsDataURL(file);
},
```

- APIにアクセスする

最後に、`axios`を利用してリクエストを投げます。

POSTするURLは、`this.apiEndpoint`で、コードの26行目で画面に入力された値を最新値として利用します。

リクエストボディのデータは `JSON.stringify()`メソッドでJSON形式に変換しましょう。

```javascript:SearchFaces.vue
// API呼び出し
axios
  .post(this.apiEndpoint, JSON.stringify(querydata), config)
  .then(response => {
      const faceMatches = response.data.payloads.FaceMatches;
      if (faceMatches.length == 0) {
        this.noTarget = '人物を特定できませんでした'
      } else {
        this.createAuthenticationData(faceMatches[0]);
      }
      this.overlay = false;
  })
  .catch(error => {
    this.errorMessage = error;
    this.overlay = false;
  });
```

- ここまでの作業でWebAPIの作成は終了です
- [トップページ](https://iotkyoto.github.io/soracom-ug-reko-handson/)に戻って次のステップに進んでください
