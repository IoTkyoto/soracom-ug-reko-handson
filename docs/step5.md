# ステップ５. スマートフォンから顔認識を行う（SORACOM回線を使ったスマートフォンとAWSサービスを用いた画像認識サービスを構築する）

*当コンテンツは、エッジデバイスとしてスマートフォン、クラウドサービスとしてAWSを利用し、エッジデバイスとクラウド間とのデータ連携とAWSサービスを利用した画像認識を体験し、IoT/画像認識システムの基礎的な技術の習得を目指す方向けのハンズオン(体験学習)コンテンツ「[SORACOM回線を使ったスマートフォンとAWSサービスを用いた画像認識サービスを構築する](https://iotkyoto.github.io/soracom-ug-reko-handson/)」の一部です。*

# ステップ5. スマートフォンから顔認識を行う

![ステップ5アーキテクチャ図](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/architecture_overall.png)

テップ５では、SORACOM回線での接続が可能なスマートフォンを使い、スマートフォンのカメラで撮影した画像で顔認識を行ってみましょう。
SORACOM回線での接続が可能なパソコンからでも実施することが出来ます。

---

### 目的

- スマートフォンで顔認識を行う
- 作成した顔認識が正しく機能することを確認する

### 概要

- スマートフォンでWebアプリケーションにアクセスする
- 登録済みの人物の顔をカメラで撮影し顔認識を行ってみる
- 登録していない人物の顔をカメラで撮影し顔認識を行ってみる

---

## 5-1. スマートフォンでWebアプリケーションにアクセスする

各自のスマートフォンのブラウザを立ち上げて顔認識Webアプリケーションにアクセスしてください。

- 以下のURLにブラウザでアクセスするか、QRコードをカメラで読み取り対象のWebアプリケーションを開いてください
  - URL：http://soracom-ug-reko-handson.s3-website-ap-northeast-1.amazonaws.com/
![QRコード](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step5/qrcode.png)

- 以下の画面が表示されることを確認してください
![5-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step5/5-1_1.png)

## 5-2. 顔画像認識画面を表示する

顔認識APIを呼び出す画面に移動します。

- ホーム画面の「顔画像認識画面(SORACOM)へ」の部分をタッチする
![5-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step5/5-2_1.png)

- 以下の画面が表示されることを確認してください
![5-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step5/5-2_2.png)

#### 画面表示時にエラーが表示された場合

「メタデータの取得に失敗しました。」のエラーメッセージが表示された場合、メタデータの取得が出来ていません。
![5-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step5/5-2_3.png)

SORACOM管理コンソールにログインし、以下のことを確認してください。
- スマートフォンが使用するSIMカードの設定を行っていること
- 対象のSIMにメタデータを設定してSIMグループが割り当たっていること
- SIMグループのメタデータ設定がステップ４の内容通りに設定されていること
  - 「許可するオリジン」のURLが下記の通りであること
  - http://soracom-ug-reko-handson.s3-website-ap-northeast-1.amazonaws.com
  - 最後に「/」があるとエラーとなります

## 5-3. メタデータ情報が正しく取得出来ているか確認

通常のアプリケーション稼働時には不要ですが、メタデータが正しく取得出来ていることを確認するための画面を用意しています。

そちらを確認し、SORACOM管理コンソールで設定した内容が正しく取得されていることを確認してください。

- 顔画像認識画面の右上の「人物」アイコンをタッチする
![5-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step5/5-3_1.png)

- 表示されたAPIエンドポイントとAPIキーがメタデータサービスに設定した内容で同じであることを確認する
![5-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step5/5-3_2.png)

#### APIエンドポイントとAPIキーが正しく表示されない場合

- APIエンドポイントあるいはAPIキーのいずれかがブランクの場合
  - 設定したユーザーデータのJSON形式のキーが間違っている可能性があります
  - 「"apiEndpoint": 」「"apiKey": 」となっていることを確認してください

- APIエンドポイントあるいはAPIキーの両方ともブランクの場合
  - １つ前の「画面表示時にエラーが表示された場合」を確認してください

## 5-4. 登録済みの人物を撮影し顔認識を実施する

それでは、実際にスマートフォンからWebアプリケーションを操作して顔認証を行ってみましょう。
まずは、コレクションに登録した人物を撮影し、顔画像認識を行ってみましょう。

- [画像ファイルを選択]をタッチし、写真を撮るのか、撮影済みの画像を選択してください
![5-4_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step5/5-4_1.png)

- [顔画像認識実行]をタッチし、顔認識処理を行ってください
![5-4_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step5/5-4_2.png)

- 画像の下に認識出来た人物名が表示されます
![5-4_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step5/5-4_3.png)

## 5-4. 登録されていない人物を撮影し顔認識を実施する

最後に、コレクションに登録していない人物を撮影し、顔画像認識を行ってみましょう。

- [画像ファイルを選択]をタッチし、写真を撮るのか、撮影済みの画像を選択してください
![5-4_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step5/5-4_1.png)

- [顔画像認識実行]をタッチし、顔認識処理を行ってください
![5-4_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step5/5-4_4.png)

- 画像の下の「認識結果」のボックスに「人物を特定できませんでした」と表示されます
![5-4_5](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step5/5-4_5.png)

- 余裕があれば、AWSのコンソールに移動し、CloudWatchでAPIへのアクセス履歴やLambdaのログを確認してみましょう。


### 次のステップへ進んでください

- [トップページ](https://iotkyoto.github.io/soracom-ug-reko-handson/)に戻って次のステップに進んでください
