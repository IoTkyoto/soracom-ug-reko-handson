# ステップ2. 顔認識用のコレクションを作成する（SORACOM回線を使ったスマートフォンとAWSサービスを用いた画像認識サービスを構築する）

*当コンテンツは、エッジデバイスとしてスマートフォン、クラウドサービスとしてAWSを利用し、エッジデバイスとクラウド間とのデータ連携とAWSサービスを利用した画像認識を体験し、IoT/画像認識システムの基礎的な技術の習得を目指す方向けのハンズオン(体験学習)コンテンツ「[SORACOM回線を使ったスマートフォンとAWSサービスを用いた画像認識サービスを構築する](https://iotkyoto.github.io/soracom-ug-reko-handson/)」の一部です。*

# ステップ2. 顔認識用のコレクションを作成する

![ステップ2アーキテクチャ図](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/architecture_step2.png)

ステップ2では、画像に写っている人物を特定するために必要なコレクションを作成します。

AWS Rekognitionサービスでは、コレクションの情報を使って、画像内に誰が写っているのかを特定する機能があります。

まずは、画像のアップロード先として「[**Amazon S3（以下、S3）**](https://aws.amazon.com/jp/s3)」にバケットを作成し、登録したい人物が１人で写っている画像をAWSコンソールからアップロードします。

AWSのCLI(コマンド・ライン・インターフェース)ツールを使って、「**[Amazon Rekognition（以下、Rekognition）](https://aws.amazon.com/jp/rekognition/)**」の「コレクション」を作成し、認識対象となる顔を登録します。

---

### 目的

- AWSコンソールからクラウドにファイルをアップロードする
- AWS CLIの使い方を学ぶ

### 概要

- AWSコンソールからS3のバケットを作成し画像をアップロードする
- AWS CLIでRekognitionのコレクションを作成し画像を登録する

---

### ＜Amazon S3とは？＞

Amazon Simple Storage Service（Amazon S3）は、AWSによって提供されるクラウド型のオブジェクトストレージサービスです。容量無制限・高耐久性と低コストが大きな特徴です。

- 容量無制限
- [従量課金制](https://aws.amazon.com/jp/s3/pricing)
    - ユースケースに応じたさまざまなストレージクラスが存在している（IA,1ゾーンIA,Glacier etc）
    - 適したストレージクラスを使用することでコスト最適化が可能
- 高耐久性（99.999999999%）
    - 自動的に３箇所以上のAZ(アベイラビリティゾーン)に冗長に保存される
- バケット単位、オブジェクト単位の詳細なアクセス権限の設定が可能
- 保存期間を設定したライフサイクル設定が可能
- ファイルの世代管理が可能

より詳しく知りたい場合は[公式サイト](https://aws.amazon.com/jp/s3/)をご確認ください。

### ＜AWS CLIとは？＞

AWSコマンドラインインターフェースの略で、AWSサービスをコマンドラインから操作し管理するためのオープンソースツールです。

コマンドラインから複数のAWSサービスを制御し、スクリプトを使用してこれらの作業を自動化することができます。

- Windows/Mac/Linuxなどの様々なOSで使用可能
  - Windowsの場合、PowerShell または Windowsコマンドプロンプトでコマンドを実行
  - Mac/Linux/Unixの場合、bash/zsh/tcshなどの一般的なシェルプログラムでコマンドを実行
- 使い方やリファレンスは以下を参照
  - [AWSコマンドラインインターフェースのユーザーガイド](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-chap-welcome.html)
  - [AWS CLIコマンドリファレンス](https://docs.aws.amazon.com/cli/latest/reference/)

より詳しく知りたい場合は[公式サイト](https://aws.amazon.com/jp/cli/)をご確認ください。

### ＜Amazon Rekognitionとは？＞

Amazon Rekognitionは、ディープラーニング技術を利用したフルマネージド型の画像認識サービスです。

画像や動画を対象に、画像のシーンやアクティビティの検出、顔認識、有名人の検出、顔の分析、テキスト抽出といった機能を提供します。

Rekognition APIに対象の画像を登録・送信するだけで、これらの機能を自身のアプリケーションに簡単に組み込み利用することが可能です。

- Amazon Rekognition Imageでは以下の機能が利用可能
    - 物体とシーンの検出
    - 顔認識
    - 顔分析
    - 顔の比較
    - 危険画像の検出
    - 有名人の認識
    - 画像内のテキスト検出
- Amazon Rekognition Videoでは以下の機能が利用可能
    - ストリーミングビデオのリアルタイム解析
    - 人物の識別と追跡
    - 顔認識
    - 顔分析
    - 物体、シーン、動作の検出
    - 不適切な動画の検出
    - 有名人の認識

より詳しく知りたい場合は[公式サイト](https://aws.amazon.com/jp/rekognition/)をご確認ください。

### ＜Amazon Rekognitionでの顔認識＞

顔認識を行うためにAmazon Rekognitionの機能のひとつである `SearchFacesByImage` という機能を使います。

Amazon Rekognitionでは、検出した顔に関する情報を `コレクション` というサーバー側のコンテナに保存できます

コレクションにはイメージが格納されているのではなく、顔ごとに顔の特徴を特徴ベクトルに抽出し、その特徴ベクトルが保存されています。

コレクションに保存された顔の情報を使用して、イメージ、保存済みビデオ、およびストリーミングビデオ内の既知の顔を検索することができます。

また、コレクション内の画像にタグをつけて「コレクションの中に登録されている顔であれば、登録した顔画像のタグを返す」といった使い方ができます。

詳細は、公式ドキュメント「[コレクション内での顔の検索](https://docs.aws.amazon.com/ja_jp/rekognition/latest/dg/collections.html)」をご確認ください。

---

## 2-1. コレクションに登録する画像をアップロードするためのS3バケットを作成

この項目ではAWSのS3というサービスを用いて、コレクションに登録するための画像の保存先となる「バケット」を作成していきます。

以下の手順でS3のバケットを用意します。

---

### ＜S3バケットとは？＞

Amazon S3に格納されるすべてのオブジェクト(ファイル)は、バケット（バケツ）と呼ばれる入れ物の中に存在します。

バケットの用途には、Amazon S3の最上位の名前空間を形成する、ストレージとデータ転送の課金アカウントを特定する、アクセスコントロールに使用する、使用状況レポートの集計単位として使用するなど、さまざまなものがあります。

もっとも重要な役割は「オブジェクトに対して名前空間を提供する」ことです。  
名前空間はすべてのAWSアカウントによって共有されますので、グローバルに一意である必要があります。

https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/UsingBucket.html

---

### 2-1-1. AWSのコンソール画面で「S3」を検索・選択し[バケットを作成する]をクリックする

- 以下のURLをクリックし、AWSのコンソール画面を表示してください。
https://console.aws.amazon.com/console/home

- コンソール画面上部の検索欄に「S3」と入力し、表示されたサービスから「S3」をクリックしてください。
![2-1-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step2/2-1-1_1_2.png)

- バケット一覧画面から「バケットを作成」をクリックしてください。
![2-1-1_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step2/2-1-1_2_2.png)

### 2-1-2. バケット名とリージョンを入力する

- 一般的な設定に以下の内容を入力してください。
    - バケット名：{名前}-rekognition-collection-source（例：yamada-rekognition-collection-source）
    ※ バケット名が他の人と重複して作成出来ない場合は、名前の後ろに本日の日付などを付けるようにしてください。
    - リージョン：アジアパシフィック（東京）
    - 既存のバケットから設定をコピー：何もしない

- **ここで入力したバケット名は後続処理で使用しますのでメモしておいてください。**

![2-1-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step2/2-1-2_1.png)

**【注意】 バケット名の一意性**

Amazon S3のバケット名はグローバルに一意であり、名前空間はすべてのAWSアカウントによって共有されています。

そのためバケット名は世界で一意のものを指定する必要があります。  
重複するバケット名がすでに他の誰かに作成されている場合、その名前は利用できません。

S3バケットの命名のガイドラインについては[バケットの制約と制限](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/BucketRestrictions.html)のサイトを参照してください。

**【注意】 リージョン指定**

リージョンが「アジアパシフィック(東京)」になっていることを確認してください。

今回はすべてのAWSサービスを東京リージョンで構築します。  
リージョンが異なると、サービス間連携の遅延や他のAWSサービスと連携する上での困難等が生じることがございます。

### 2-1-3. ブロックパブリックアクセスのバケット設定の「パブリックアクセスをすべてブロック」にチェックが入っていることを確認する

アクセス許可の設定では、S3バケットに対してアクセスできる権限を指定します。

「**パブリックアクセスをすべてブロック**」にチェックが入っていることを確認してください。

**【注意】 S3バケットのパブリックアクセスについて**

「パブリックアクセスが有効」な状態のS3バケットは、世界中の人々に公開されている状態となります。

S3バケットのパブリックアクセスが原因となった顧客情報の漏洩などの事件も発生しておりますので、アクセス権限の設定はお気をつけください。
![2-1-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step2/2-1-3_1.png)

### 2-1-4. バケットのバージョニングの「無効にする」にチェックが入っていることを確認する

今回はバケット内オブジェクトのバージョン管理は行いませんので、「無効にする」にチェックが入っていることを確認してください。

![2-1-4_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step2/2-1-4_1.png)

---

### ＜バージョニングとは？＞

バージョニングとは、同じバケット内でオブジェクトの複数のバージョンを保持する手段です。

バージョニングの設定をONにすることで、Amazon S3バケットに格納されたあらゆるオブジェクトのあらゆるバージョンを格納、取得、復元することができます。

オブジェクトを誤って削除した場合でも復元することが可能です。

https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/Versioning.html

---

### 2-1-5. デフォルトの暗号化の「無効にする」にチェックが入っていることを確認し、「バケットを作成」をクリックする

今回はバケット内オブジェクトの暗号化は行いませんので、「無効にする」にチェックが入っていることを確認し、「バケットを作成」をクリックしてください。

![2-1-5_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step2/2-1-5_1.png)

- ここまでの作業で新しいバケットが作成されます。
バケット一覧に作成したバケットが存在していることを確認してください。

## 2-2. S3バケットに画像をアップロードする

作成したバケットに、事前準備として用意した自分の顔が写った画像をアップロードします。
画像認識のベースとなる画像は１枚のみで問題ございません。

### 2-2-1. 対象のバケットを検索し選択する

- バケット一覧画面の「バケットを名前で検索」欄にステップ2-1で作成したバケット名の一部を入力してください（例：yamada）

- 対象のバケット名をクリックしてください。

### 2-2-2. 対象画像をアップロードする

- 「アップロード」ボタンをクリックしてください。
![2-2-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step2/2-2-2_1_2.png)

- アップロード画面の「ここにファイルとフォルダをここにドラッグアンドドロップする」部分に顔認識のベースとなる画像をドロップしてください。
![2-2-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step2/2-2-2_2_2.png)

- ドロップしたファイルが表示されていることを確認し、画面下部の「アップロード」をクリックしてください。
![2-2-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step2/2-2-2_3_2.png)

- アップロード:ステータス画面が表示されますので、画像名とステータスが「成功しました」になっていることを確認し、「終了」ボタンをクリックしてください。
![2-2-2_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step2/2-2-2_4_2.png)

- 対象の画像ファイルがバケット内にリスト形式で表示されたことを確認してください。
![2-2-2_5](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step2/2-2-2_5_2.png)

- **ここでアップロードした画像ファイル名は後続処理で使用しますのでメモしておいてください。**

## 2-3. コレクションを作成する

顔認証サービスを利用するために、認証の対象となる顔データの登録先となるコレクションを作成します。

コレクションには、 `--collection-id`パラメーターで名前をつける必要があります。
使用目的が分かるように「{名前}-authentication-collection」というコレクション名をつけましょう。  
（例：yamada-authentication-collection）

### 2-3-1. コレクションを作成する

- AWSコンソールからステップ1-1で作成したCloud9を開いてください
- ターミナル上で以下のコマンドを実行しコレクションを作成してください  
- 「--collection-id」の後ろ文字列がコレクション名となりますので各自のコレクション名に変更してください
- コマンドの詳細は、公式ドキュメント「[コレクションの作成](https://docs.aws.amazon.com/ja_jp/rekognition/latest/dg/create-collection-procedure.html)」をご確認ください。

```shell:実行コマンド例
$ aws rekognition create-collection --collection-id "yamada-authentication-collection"
```

- 出力結果が以下のようにStatusCodeが200となれば、コレクションが正常に作成できています

```shell:実行結果
{
    "StatusCode": 200,
    "CollectionArn": "aws:rekognition:ap-northeast-1:XXXXXXXXXXXX:collection/yamada-authentication-collection",
    "FaceModelVersion": "5.0"
}
```

- **ここで作成したコレクション名は後続処理で使用しますのでメモしておいてください。**

### 2-3-2. コレクションの作成を確認する

- `list-collections`コマンドを実行することで、対象のAWSアカウントで管理されているコレクションの一覧を確認することができます

```shell:実行コマンド
$ aws rekognition list-collections
```

- 実行結果
```shell:実行結果
{
    "CollectionIds": [
        "yamada-authentication-collection"
    ],
    "FaceModelVersions": [
        "5.0"
    ]
}
```

## 2−4. コレクションに顔を登録する

前のステップで作成したコレクションに対して、「aws rekognition index-faces」コマンドで対象の顔画像を登録します。

### 2-4-1. コマンドを編集する

コマンドが長くなりますので、shellファイルを準備しています。  
Cloud9の左側ディレクトリから「/soracom-ug-reko-handson/sources/step2/rekognition_index_faces.sh」をダブルクリックして、ファイルを開いてください。

- **コマンド内容**
> aws rekognition index-faces --image '{"S3Object":{"Bucket":"'${BUCKET_NAME}'","Name":"'${PICTUER_NAME}'"}}' --collection-id "${COLLECTION_ID}" --max-faces 1 --quality-filter "AUTO"  --detection-attributes "ALL" --external-image-id "${EXTERNAL_IMAGE_ID}"

- 下記パラメーターの説明を参考にファイルの１〜４行目のコマンド実行パラメータを編集し保存してください。
    - BUCKET_NAME：ステップ2-1-2で作成したバケット名（例：yamada-rekognition-collection-source）
    - PICTUER_NAME：ステップ2-2-2でアップロードした画像名(拡張子含む)（例：yamada.jpg）
    - COLLECTION_ID：ステップ2-3-1で作成したコレクション名（例：yamada-authentication-collection）
    - EXTERNAL_IMAGE_ID：対象者のタグ/人物名（例：Taro_Yamada）

- **パラメーターの説明**  
  コマンドの詳細は、[こちら](https://docs.aws.amazon.com/ja_jp/rekognition/latest/dg/add-faces-to-collection-procedure.html)の公式ドキュメントをご参考ください。

  - `--image`
      - パラメーター内の `"Bucket"`属性の値には、ステップ2-1で作成したバケット名、 
      - `"Name"`属性の値には、ステップ2-2でアップロードした画像ファイル名を、それぞれ入力します

  - `--collection-id`
      - 前のステップで作成したコレクション名を入力します

  - `--max-faces 1`
      - これは、登録に利用した画像に複数人写っていた場合、「顔である」確率が最も高いものから最大何人分の顔を一度に登録するかを指定しています。
      - Rekognitionのコレクションへの顔の登録では、画像に写っている顔を最大100人まで一度に登録できますが、その際につけられるタグは1つだけです。
      - 今回は、顔とタグを一対一で対応させたいので、 `max-faces`を `1`にしてください。。

  - `--external-image-id`
      - オプション指定例: `external-image-id "Taro_Yamada"`
      - これは、登録に利用した画像データに対して、タグ付けを行う機能です。
      - 上記の `--max-faces`を `1`と指定し、画像に写っている人物名を `external-image-id`で設定することで、コレクションを利用した顔認証の際に、判定結果の人物名を取得することが可能となります。
      - **external-image-idは、英数字および記号(_.\-:)しか使用することは出来ません**

### 2-4-2. コマンドを実行する
ファイルを [File] - [Save] で保存したら、Terminal画面からシェルを実行します。

```sh
$ sh soracom-ug-reko-handson/sources/step2/rekognition_index_faces.sh
```

- コレクションに顔の登録が成功した場合は、対象の顔の特徴情報のJSONが表示されます

```shell:登録成功時
{
    "FaceRecords": [
        {
            "Face": {
                "FaceId": "XXXXX-XXXX-XXXX-XXXX-XXXXXXX",
                "BoundingBox": {
                    "Width": 0.40926530957221985,
                    "Height": 0.446433961391449,
                    "Left": 0.2812435030937195,
                    "Top": 0.12307235598564148
                },
                "ImageId": "XXXXX-XXXX-XXXX-XXXX-XXXXXXX",
                "ExternalImageId": "Taro_Yamada",
                "Confidence": 100.0
            },
          ・・・
```


### 2-4-3. コレクションの内容を確認する
`list-faces` コマンドを実行することで、対象のコレクションに含まれる顔の一覧を確認することができます  
  実行時には対象のコレクションIDを指定する必要があります

```shell:実行コマンド
$aws rekognition list-faces --collection-id yamada-authentication-collection
```
```shell:実行結果
{
    "Faces": [
        {
            "FaceId": "XXXXX-XXXX-XXXX-XXXX-XXXXXXX",
            "BoundingBox": {
                "Width": 0.40926501154899597,
                "Height": 0.44643399119377136,
                "Left": 0.2812440097332001,
                "Top": 0.12307199835777283
            },
            "ImageId": "XXXXX-XXXX-XXXX-XXXX-XXXXXXX",
            "ExternalImageId": "Taro_Yamada",
            "Confidence": 100.0
        }
    ],
    "FaceModelVersion": "4.0"
}
```

## 2-5. コレクションをテストする

ステップ2-1で作成したバケットとアップロードした画像を利用して、コレクションに登録した顔とマッチするかテストします。

コレクションに登録した顔のデータと、そのデータの元となる画像を比較するため、マッチ率は100%に限りなく近い数値となります。

- 「aws rekognition search-faces-by-image」コマンドを実行し、指定した画像の中にコレクション内の顔と一致する顔があるか確認します

### 2-5-1. コマンドを編集する

コマンドが長くなりますので、shellファイルを準備しています。  
Cloud9の左側ディレクトリから「/soracom-ug-reko-handson/sources/step2/search_faces_by_image.sh」をダブルクリックして、ファイルを開いてください。

- **コマンド内容**
> aws rekognition search-faces-by-image --image '{"S3Object":{"Bucket":"'${BUCKET_NAME}'","Name":"'${PICTUER_NAME}'"}}' --collection-id "${COLLECTION_ID}"

- 下記パラメーターの説明を参考にファイルの１〜３行目のコマンド実行パラメータを編集し保存してください。
    - BUCKET_NAME：ステップ2-1-2で作成したバケット名（例：yamada-rekognition-collection-source）
    - PICTUER_NAME：ステップ2-2-2でアップロードした画像名(拡張子含む)（例：yamada.jpg）
    - COLLECTION_ID：ステップ2-3-1で作成したコレクション名（例：yamada-authentication-collection）

- **パラメーターの説明**  
  コマンドの詳細は、[こちら](https://docs.aws.amazon.com/ja_jp/rekognition/latest/dg/search-face-with-image-procedure.html)の公式ドキュメントをご参考ください。

  - `--image`
      - パラメーター内の `"Bucket"`属性の値には、ステップ2-1で作成したバケット名、 
      - `"Name"`属性の値には、ステップ2-2でアップロードした画像ファイル名を、それぞれ入力します

  - `--collection-id`
      - 前のステップで作成したコレクション名を入力します
 
- 出力結果から、指定したS3バケット内の画像の中に顔があるかどうか、顔がコレクション内の顔とどの程度マッチするかがわかります
    -  `FaceMatches`内の要素のうち `Similarity`が、マッチ度を表し、マッチした顔は `Face`内の `ExternalImageId`で確認できます

### 2-5-2. コマンドを実行する
ファイルを保存したら、Terminal画面からシェルを実行します。

```sh
$ sh soracom-ug-reko-handson/sources/step2/search_faces_by_image.sh
```

- 以下のように実行結果が返ってきます。
    - Similarityで合致度
    - ExternalImageIdで人物につけたタグが表示されています

```shell:実行結果
{
    "SearchedFaceBoundingBox": {
        "Width": 0.40926530957221985,
        "Height": 0.446433961391449,
        "Left": 0.2812435030937195,
        "Top": 0.12307235598564148
    },
    "SearchedFaceConfidence": 100.0,
    "FaceMatches": [
        {
            "Similarity": 99.99918365478516,
            "Face": {
                "FaceId": "XXXXX-XXXX-XXXX-XXXX-XXXXXXX"",
                "BoundingBox": {
                    "Width": 0.40926501154899597,
                    "Height": 0.44643399119377136,
                    "Left": 0.2812440097332001,
                    "Top": 0.12307199835777283
                },
                "ImageId": "XXXXX-XXXX-XXXX-XXXX-XXXXXXX",
                "ExternalImageId": "Taro_Yamada",
                "Confidence": 100.0
            }
        }
    ],
    "FaceModelVersion": "5.0"
}
```

- 判定元と判定対象に同じ画像ファイルを使用していますので、Similarityが非常に高い数値（95%以上）の判定結果が出ていることを確認してください。
ただし、使用した画像の鮮明ぐあいによってはSimilarityの数値は下がる可能性があります。

---

### 次のステップへ進んでください

- ここまでの作業で事前の準備作業は終了です
- [トップページ](https://iotkyoto.github.io/soracom-ug-reko-handson/)に戻って次のステップに進んでください
