# ステップ3. 顔認証用のファンクションを作成しSORACOM Funk経由で呼び出す（スマートフォンとSORACOM FunkとAWSサービスを用いた画像認識サービスを構築する）

*当コンテンツは、エッジデバイスとしてスマートフォン、クラウドサービスとしてAWSを利用し、エッジデバイスとクラウド間とのデータ連携とAWSサービスを利用した画像認識を体験し、IoT/画像認識システムの基礎的な技術の習得を目指す方向けのハンズオン(体験学習)コンテンツ「[スマートフォンとSORACOM FunkとAWSサービスを用いた画像認識サービスを構築する](https://iotkyoto.github.io/soracom-ug-reko-handson/)」の一部です。*

# ステップ3. 顔認証用のファンクションを作成しSORACOM Funk経由で呼び出す

![ステップ3アーキテクチャ図](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/architecture_step3.png)

ステップ3では、前ステップでS3バケットにアップロードされた画像を分析し「事前登録済みの人物が写っているかを判定し、写っている場合は誰なのかを判定する」という機能を持ったクラウドファンクションを作成し、デバイス側からSORACOM Funk経由で呼び出す仕組みを構築します。

まずは、「**[Amazon Rekognition（以下、Rekognition）](https://aws.amazon.com/jp/rekognition/)**」を利用して「コレクション」を作成し、認識対象となる顔を登録します。

次に、作成したコレクションを使って顔の認識を行う「**[AWS Lambda（以下、Lambda）](https://aws.amazon.com/jp/lambda/)**」を作成します。

さいごに、作成したLambdaにアクセスするために「**[SORACOM Funk（以下、Funk）](https://soracom.jp/services/funk/)**」を作成します。

---

### 目的

- デバイスからSORACOM Funk経由でクラウド側のファンクションを利用する方法を学ぶ
- JSON形式のファイルの取り扱いを学ぶ
- AWS Lambdaの作成方法を知る
- AWSの画像認識サービスを知る

### 概要

- 顔認証用のLambdaを作成し、SORACOM Funk経由でアクセスする
 - 認証情報はIAMを使用する
- 顔認識用のコレクションを作成し、対象者が画像に写っているかどうかの画像認識を行う

---

### ＜AWS Lambdaとは？＞

AWS Lambdaは、サーバーをプロビジョニングしたり管理する必要なくコードを実行できるサーバーレスコンピューティングサービスです。これは他のAWSサービスをトリガーとして実行することができ、実際に処理にかかった時間やリクエスト数に対して従量課金されます。Lambda関数はJavaやPythonをはじめとした一般的なプログラミング言語で作成することができます。

- サーバー管理が不要
- 実行時のメモリ量を指定することで、それに比例したCPUパワー/ネットワーク帯域/ディスクIOが割り当てられる
- リクエスト受信の回数に合わせて自動的にスケールする
- コードが実行されている間のコンピューティング時間に対しての[ミリ秒単位の課金](https://aws.amazon.com/jp/lambda/pricing/)
- Java、Go、PowerShell、Node.js、C#、Python、Rubyのコードをサポート
- カスタムランタイムで上記以外の言語の使用も可能(COBOLなど)

より詳しく知りたい場合は[公式サイト](https://aws.amazon.com/jp/lambda/)をご確認ください。

### ＜SORACOM Funkとは？＞

SORACOM Funkは、クラウドサービスの Function を直接実行できるサービスです。

一般的にIoTデバイスは電力消費などを抑える目的からシンプルな構成であることが多く、そのような場合はデバイス側での複雑なデータ処理が難しい場合があります。また、デバイス側がこのような複雑なデータ処理が可能な場合も、多くの電力を消費します。

そのような場合、FaaSと連携することで、IoTデバイスのリソースを使用することなく、クラウドの膨大なリソースで複雑な処理を実行することができます。

- クラウドが提供する FaaS として、以下の3つに対応
  - AWS Lambda
  - Azure Functions
  - GCP Cloud Functions
- Funk の料金体系は、Funk 経由のリクエスト数に応じた完全な従量課金
  - 初期費用、基本料金は不要
- 様々なデバイス、通信プロトコルを利用してクラウドサービスの Function を直接実行
  - 3G/LTE, LoRaWAN, Sigfox といったデバイス
  - TCP, UDP, HTTP, SMS, USSD, LPWA 通信プロトコルに対応

より詳しく知りたい場合は[公式サイト](https://soracom.jp/services/funk/)をご確認ください。

## ３-1. Lambdaを作成

ここでは、スマートフォンからSORACOM Funk経由で受け取った顔画像が、ステップ2で作成したRekognitionのコレクションに登録済みの人物に合致するかどうか、合致した場合は誰なのかをリターン値として返すLambdaファンクションを作成します。

### 3-1-1. Lambda関数を作成する

- AWSのコンソール画面で、「Lambda」を検索・選択し、[関数の作成]をクリックします。
![3-1-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-1_1%E6%9E%9A%E7%9B%AE.png)

- 以下の項目をそれぞれ選択・入力し、[関数の作成]をクリックします。
  - 一から作成
  - 関数名： 任意の名前（例：yamada_lambda_authentication）
  - ランタイム： `Python 3.7`
  - アクセス権限：[ ▼ 実行ロールの選択または作成]を開き、**「基本的なLambdaアクセス権限で新しいロールを作成」** を選択する
![3-1-1_2](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-1_2%E6%9E%9A%E7%9B%AE.png)
![3-1-1_3](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-1_3%E6%9E%9A%E7%9B%AE.png)

「基本的なLambdaアクセス権限」を指定することで、Lambda実行時のログをCloudWatch Logsにアップロードするためのロールが自動的に付与されます。
次のステップで、Lambdaのソースコードから使用するAWSサービスに対する必要な権限をカスタムで追加します。


### 3-1-2. Lambdaに必要な権限を付与する

- 関数が作成された関数の画面に遷移します。
- 画面下部の実行ロール欄の「xxxxxxxxx-role-xxxxxxxxロールを表示」をクリックします。
- このLambdaに紐づいたロール詳細画面が開きます。
![3-1-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-2_1%E6%9E%9A%E7%9B%AE.png)
![3-1-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-2_2%E6%9E%9A%E7%9B%AE.png)
![3-1-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-2_3%E6%9E%9A%E7%9B%AE.png)

- ロール詳細画面の「インラインポリシーの追加」をクリック
- Rekognitionのコレクションへのアクセスができるように、以下の権限をインラインポリシーとして追加し、任意の名前で登録しましょう

  - **Rekognitionのコレクションにアクセスする**

    - サービス： `Rekognition`
    - アクション：[読み込み] `SearchFacesByImage`
    - リソース：[指定]を選択し、collection欄の[ARNを指定]をクリックし、それぞれ登録します
      - Region： `ap-northeast-1`
      - Account： すべてにチェック
      - Collection Id：ステップ2-3で作成したコレクション名 (例： `yamada-authentication-collection`)


![3-1-2_5](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-2_0.png)
![3-1-2_6](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-2_%E7%A2%BA%E8%AA%8D.png)


### 3-1-3. Pythonの関数コードを作成する
    
Lambdaが実行するPythonコードを作成します。

- Lambdaの関数画面に戻ってください

- 「関数コード」欄のヘッダー部の右端に「ハンドラ」として `lambda_function.lambda_handler`がデフォルトで指定されています。
  これは、当Lambdaが呼び出された際に実行される関数が `lambda_function.py`の中の`lambda_handler`という関数だ、という意味です。

- サンプルプログラムは[こちら](https://github.com/IoTkyoto/iot-handson-rekognition/blob/master/step2/lambda_authentication.py)の `lambda_authentication.py`をご確認ください。

- サンプルプログラムの内容をコピーし、関数コード欄にペーストしてください

<!-- TODO: 行数確認 -->
- コードの14行目の以下の部分の「`{collection_id}`」を、ステップ1-6-1で作成したコレクション名（例：`yamada-authentication-collection`）に変更してください

```python:変更前
  # Rekognitionで作成したコレクション名を入れてください
  COLLECTION_ID = '{collection_id}'
```
```python:変更後
  # Rekognitionで作成したコレクション名を入れてください
  COLLECTION_ID = 'yamada-authentication-collection'
```

- 右上の「保存」をクリックしてください
![3-1-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-3.png)

#### 作成プログラムの解説

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

### 3-1-4. Lambdaのテストを実行する

Lambdaの関数コードを保存したら、API Gatewayから渡されてくる想定のイベントデータを用意し、Lambdaに渡して、実際の動きをテストしてみましょう。

- 関数画面右上の[テスト]をクリックしてください。
![3-1-4_1](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-4_1.png)

- テストイベントの設定画面で以下の内容を入力して「作成」をクリックしてください。
  - 新しいテストイベントの作成：チェック
  - イベントテンプレート：Hello World（デフォルト）
  - イベント名：任意の名前（例：AuthTest）
  - テストデータ：以下のjsonファイルの内容。画像のデータや閾値を適宜変更してください。

- テストデータは[こちら](https://github.com/IoTkyoto/iot-handson-rekognition/blob/master/step2/lambda_authentication_event_example.json)の `lambda_authentication_event_example.json`をご確認ください。

- テストデータの内容をコピーし、テストイベントのコード欄に貼り付けてください

![3-1-4_2](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-4_2.png)

- 作成したら、[テスト]をクリックし、実行結果を確認しましょう。関数の実行結果は、中をスクロールして見ることが可能です
![3-1-4_3](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-4_3.png)
![3-1-4_4](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-4_4.png)
![3-1-4_5](https://s3.amazonaws.com/docs.iot.kyoto/img/iot-handson-zybo-and-aws/step2/2-2-4_5.png)

- テストの結果として、「statusCode:200」と「ExternalImageId」として対象者のタグが返ってきていれば成功です。

## 3-2. Lambda実行用のIAMユーザーを作成する

SORACOM Funkから作成したLambdaを使用するために、対象のLambdaの実行権限のみを持たせたIAMユーザーを作成します。

ステップ3-1で作成したLambdaファンクションを実行するアクションのみを許可するポリシーをアタッチした「**[IAMユーザー](https://aws.amazon.com/jp/iam/)**」を作成します。  
加えて、アクセスできるLambdaファンクションを指定することでアクセス権限を最小限にし、セキュリティレベルを高めます。

IAMポリシーでアクセス権限を設定し、これをIAMユーザーにアタッチすることでユーザーにアクセス権限が付与されます。

---

### ＜IAMとは？＞
AWS Identity and Access Management (IAM) は、AWSのサービスやリソースへのアクセスを安全に管理するためのサービスです。
IAMを使用することで、AWSのユーザーとグループを作成および管理し、アクセス権を使用して AWSリソースへのアクセスを許可および拒否できます。
権限管理は非常に重要な部分ですので[IAMのベストプラクティス](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/best-practices.html)をご確認いただく事を推奨します。

より詳しく知りたい場合は[公式サイト](https://aws.amazon.com/jp/iam/)をご確認ください。

---

### 3-2-1. AWSのコンソール画面で「IAM」を検索・選択し[ポリシー] -> [ポリシーの作成]をクリックする

- AWSコンソールでIAMサービスを検索し開く
![3-2-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-1_1.png)
- ポリシーの作成をクリックする
![3-2-1_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-1_2.png)

### 3-2-2. ビジュアルエディタでサービス・アクション・リソースを設定する

ビジュアルエディタもしくはJSON形式での指定により、アクセス権限を任意に作成できます。

今回はビジュアルエディタで以下の設定を行います。  
- サービス： `Lambda`
- アクション：[書き込み]の `InvokeFunction`
- リソース：ステップ3-1で作成したLambdaのARN

---

**【注意】 リソースの指定について**
S3の「オブジェクト」とは、S3バケット内のアイテムのすべてを指します。  
また[ARN](https://docs.aws.amazon.com/ja_jp/general/latest/gr/aws-arns-and-namespaces.html)とは*Amazon Resource Name*の略で、AWSのサービスやサービス内で作成したリソースを一意に識別するための特殊な表記のことです。  
ARNの表記はAWSサービスによって異なります。

- LambdaのARNの場所  
作成したLambdaファンクションを開いた画面の右上に記載されている値がARNとなります。
![3-2-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-2_1.png)

---

#### 3-2-2-1. 「ビジュアルエディタ」を選択し、サービス/アクションを入力する

- サービスでLambdaを検索し選択する
![3-2-2-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-2-1_1.png)

- アクションに「書き込み」の「InvokeFunction」を選択する
![3-2-2-1_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-2-1_2.png)

#### 3-2-2-2. リソースを指定する

- リソースの「指定」を選択し[ARNの追加]をクリックする
![3-2-2-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-2-2_1.png)

- リージョン・ファンクション名を入力し[追加]をクリックする
![3-2-2-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-2-2_2.png)

    - Region：Lambdaを作成したリージョン（例：ap-northeast-1(東京リージョン)
    - Account：自分のAWSアカウントID(デフォルトのまま変更なし)
    - Function name：3-1で作成したLambdaファンクションの名前（例：yamada_lambda_authentication）

#### 3-2-2-3. 「ポリシーの確認」をクリックする
![3-2-2-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-2-3_1.png)

### 3-2-3. ポリシーに名前をつけて[ポリシーの作成]をクリックする
ポリシーの確認画面で[ポリシーの作成]のクリックを忘れがちですのでご注意ください。

- 名前：任意の名称（例：yamada_lambda_authentication_invoke_policy）
- 説明：任意

![3-2-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-2-3_1.png)

#### 【参考】 JSON形式で記述で記述する場合は以下のようになります

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "arn:aws:lambda:ap-northeast-1:XXXXXXXXXXXX:function:yamada_lambda_authentication"
        }
    ]
}
```

## 3-3. 作成したS3バケットにアクセスできる権限を作成(IAMユーザ編)

ステップ3-2で作成したポリシーを、ここで作成するIAMユーザーにアタッチします。

### 3-3-1. ユーザーを追加する

- 左のメニューからユーザーを選び[ユーザーを追加]をクリックする
![3-3-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-3-1_1.png)


### 3-3-2. ユーザーの詳細情報を入力する

このステップで作成するユーザーは、SORACOM FunkからLambdaファンクションにアクセスするためのユーザとなりますので、AWSコンソールへのログインは不要としプログラムによるアクセスのみ有効としましょう。

- ユーザー名：任意の名称（例：yamada_funk_lambda_user）
- プログラムによるアクセス：チェック
- AWSマネジメントコンソールへのアクセス：チェックなし
![3-3-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-3-2_1.png)

### 3-3-3. 作成したポリシーをアタッチする

- アクセス許可の設定欄の「既存のポリシーを直接アタッチ」をクリックする
- ステップ1-3-3で作成したポリシー（例：yamada_upload_target_image_policy）を検索しチェックを付与する
- 「次のステップ：タグ」をクリックする
![3-3-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-3-3_1.png)

### 3-3-4. [次のステップ:確認]をクリックする

- 今回はタグ機能を使用しない為、タグの追加は行わずに次のステップに進んでください
![3-3-4_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-3-4_1.png)

#### ＜タグとは？＞
タグとは、AWSリソースを整理するためのメタデータとして使用されるキーと値のペア値のことです。
タグを使用して[リソースグループ](https://docs.aws.amazon.com/ja_jp/ARG/latest/userguide/welcome.html)を作成すると、複数のリージョンやサービスをまたいでプロジェクト別にAWSリソースを視覚化できます。
タグを使用してAWSの請求を整理して視覚化する方法については「[コスト配分タグの使用](https://docs.aws.amazon.com/ja_jp/awsaccountbilling/latest/aboutv2/cost-alloc-tags.html)」を参照してください。

### 3-3-5. 内容を確認する

- 最後の確認画面で表示されている内容に問題がなければ[ユーザーの作成]をクリックする
![3-3-5_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-3-5_1.png)

### 3-3-6. CSVファイルをダウンロードする

- AWSにコマンドラインからアクセスするための認証（クレデンシャル）情報として、アクセスキーとシークレットアクセスキーが生成されます。  
- 次のステップで利用しますので必ずダウンロードしてください。
![3-3-6_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-3-6_1.png)

## 3-4. SORACOM Funkの設定を行う

TODO:未作成






## 3-5. スマートフォンで使用するWebアプリケーションを作成する

最後に、前のステップで作成したLambdaファンクションにアクセスするためのVue.jsのプログラムを作成します。
今回は、ステップ1でデプロイしたWebアプリケーションにすでに組み込まれていますので、処理内容の解説のみを行います。

- ソースコードはGithubに公開しています
https://github.com/IoTkyoto/soracom-ug-reko-handson/blob/master/webapp/src/components/SearchFacesFunk.vue

#### 作成プログラムの解説

##### `<template></template>`タグ内の要素について

- templateタグ内には、画面に表示する要素をHTMLで記述します
- コードの26行目のTextフィールドタグ( `v-text-field`)内にある「`v-model="soracomEndPoint"`」の `v-model`は、このフォームに入力された値を " `soracomEndPoint`(SORACOMエンドポイント)" 変数値としてリアルタイムに反映・保持します
- コードの27行目のselectタグ( `v-select`)内でも、 `v-model`を利用し" `threshold`(閾値)"の値を保持します。  
選択可能な要素は、 `:items="[100,90,80,70,60,50,40,30,20,10]"`で指定しています
- コードの45行目のファイルINPUTタグ( `v-file-input`)内にある「 `@change="onFileChange"`」は、ファイルが更新されたことをトリガーに実行したい関数を記述しています
- コードの78行目のbuttonタグ( `v-btn`)内にある「 `@click="execRecognition"`」は、ボタンクリック時に実行したい関数を記述しています

##### `<script></script>`タグ内の要素について

- 必要なライブラリのimport定義をします

```javascript
  import axios from 'axios'; // SORACOMエンドポイントにアクセスするのに利用します"
```

- SORACOMエンドポイントへのアクセスに必要なパラメータを準備する

**リクエストヘッダー情報**

リクエストのデータ形式を指定するため `'Content-type': 'application/json'`を設定しています。

```javascript
// ヘッダー情報を作成する
const config = {headers: {
  'Content-Type': 'application/json',
}};
```

**リクエストボディ情報**

ステップ3-1で作成したLambdaファンクションに渡すデータを構築します。  
`base64data`には、 `createImage()`関数内の `FileReader`メソッドの実行結果として画像ファイルのbase64データ（data URI scheme形式）を利用します。  
`threshold`では、`this.threshold`で、コードの30行目で画面で選択された値を最新値として利用します。

```javascript
// コンポーネント内で利用する変数の初期値を設定する
data: () => ({
  // --他のデータ定義は省略--
  base64data: '',
  // デフォルト値として初期値に80を設定
  threshold: 80,
}),

// リクエストボディ情報を作成する
const querydata = {
  'image_base64str': this.base64data,
  'threshold': this.threshold,
};

// 入力されたファイルをFileReaderでbase64(data URI scheme)にエンコードする
createImage(file) {
  const reader = new FileReader();
  
  reader.onload = e => {
    // ここにファイルの読み込み処理(readAsDataURL())実行後の処理を記述
    // 以下は画面表示のための要素に利用します
    this.uploadedImage = e.target.result;
    // 以下をAPIアクセスに利用します
    this.base64data = e.target.result;
  };
  // data URI scheme形式でファイルを読み込む
  reader.readAsDataURL(file);
},
```

- SORACOM Funkにアクセスする

最後に、`axios`を利用してリクエストを投げます。
`soracomEndpoint`では、`this.soracomEndpoint`で、コードの26行目で画面に入力された値を最新値として利用します。
リクエストボディのデータは `JSON.stringify()`メソッドでJSON形式に変換しましょう。

```javascript
// コンポーネント内で利用する変数の初期値を設定する
data: () => ({
  // --他のデータ定義は省略--
  soracomEndpoint: '',
}),

axios
// SORACOMエンドポイント、リクエストボディ、ヘッダーを引数にPOSTします
.post(this.soracomEndpoint, JSON.stringify(querydata), config)
// アクセス成功時の処理です
.then(response => {
    const faceMatches = response.data.payloads.FaceMatches;
    if (faceMatches.length == 0) {
      this.noTarget = '人物を特定できませんでした'
    } else {
      this.createAuthenticationData(faceMatches[0]);
    }
    this.overlay = false;
})
// エラーハンドリングを実装します
.catch(error => {
  this.errorMessage = error;
  this.overlay = false;
});
```

- 実行結果を編集する  
  通信の実行結果を整形し画面表示用の変数に設定します
```javascript
/**
 * 顔認識結果編集処理
 */
createAuthenticationData(faceMatch) {
  this.faceMatch = faceMatch.Face.ExternalImageId;
  this.faceMatchConf = Math.round(faceMatch.Similarity * 100) / 100 + '%';
}
```

## 3-6. スマートフォンから顔認証を実行する

それでは、実際にスマートフォンからWebアプリケーションを操作して顔認証を行ってみましょう。

### 3-6-1 Webアプリケーションにアクセスする

- スマートフォンのWebブラウザからデプロイしたWebアプリケーションにアクセスする
- 「人物認識画面(SORACOM FUNK)へ」をクリックする
![3-6-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-6-1_1.png)

### 3-6-2 設定内容を確認する

- 右上のアイコンをクリックし、設定内容を確認する
  - SORACOMエンドポイント：リクエストの送信先 SORACOM Funkのエンドポイントが設定されている
  - しきい値：Collectionの画像と何％の近似の場合に同一人物とするかのしきい値（デフォルト設定は８０％）
![3-6-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-6-2_1.png)

### 3-6-3 判定を行いたい人物の写真を撮る

- [画像ファイルを選択]をクリックし、写真を撮るのか、撮影済みの画像を選択してください
![3-6-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-6-3_1.png)

### 3-6-4 人物認識を実行する

- 画像のプレビューが表示されたら、[人物認識実行]をクリックしてください
![3-6-4_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-6-4_1.png)

### 3-6-5 実行結果を確認する

- 画像内に、Rekognitionのコレクションに登録した人物が発見された場合、マッチした人物と信頼度が表示されます。
- 見つからなかった場合、「認識結果」のボックスに「人物を特定できませんでした」と表示されます。
![3-6-5_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step3/3-6-5_1.png)

- また、余裕があれば、AWSのコンソールに移動し、CloudWatchでAPIへのアクセス履歴やLambdaのログを確認してみましょう。


