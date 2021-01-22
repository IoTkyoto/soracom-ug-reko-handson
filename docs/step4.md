# ステップ４. SORACOMメタデータサービスの設定を行う（SORACOM回線を使ったスマートフォンとAWSサービスを用いた画像認識サービスを構築する）

*当コンテンツは、エッジデバイスとしてスマートフォン、クラウドサービスとしてAWSを利用し、エッジデバイスとクラウド間とのデータ連携とAWSサービスを利用した画像認識を体験し、IoT/画像認識システムの基礎的な技術の習得を目指す方向けのハンズオン(体験学習)コンテンツ「[SORACOM回線を使ったスマートフォンとAWSサービスを用いた画像認識サービスを構築する](https://iotkyoto.github.io/soracom-ug-reko-handson/)」の一部です。*

# ステップ４. SORACOMメタデータサービスの設定を行う

![ステップ４アーキテクチャ図](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/architecture_step4.png)

ステップ４では、対象のSIMに[メタデータサービス](https://dev.soracom.io/jp/start/metadata/)の設定を行い、デバイス側からメタデータサービスを利用する仕組みを構築します。

メタデータサービスの設定は、SORACOM管理コンソールから設定することが可能です。
まずは、SIMグループを作成しメタデータサービスの有効化を行い、対象のSIMに作成したSIMグループを割り当てます。

---

### 目的

- SORACOMメタデータサービスの設定方法を知る
- メタデータサービスの使い方を知る

### 概要

- SORACOM管理コンソールからSIMグループを作成する
- SIMグループにメタデータサービスの設定を行う
- 対象のSIMにSIMグループを割り当てる
- メタデータサービスを利用するプログラムを作成する

---

### ＜SORACOM メタデータサービスとは？＞

SORACOM Air for セルラーのメタデータサービスは、デバイス自身が使用している IoT SIM の情報を HTTP 経由で取得、更新することができます。
また、書き込みアクセスが許可されている場合には、速度の変更、タグの追加など、各種操作が行えます。

- デバイス単体でAPIコールをする場合にも、SDKを使用する必要なく、非常に単純なコードでAPIコールが行える
- デバイスにクレデンシャルを持たせる必要がなくなる
- メタデータサービスの利用は、グループ単位で設定する
- 許可されたグループに属する IoT SIM はメタデータサービスを利用することができる

メタデータに対する読み込み・書き込みリクエストは、内部的には https://api.soracom.io/v1/subscribers/{SIMのIMSI} 配下のAPIリクエストにマッピングされる仕組みとなっています。API リファレンスに掲載されている subscribers/{imsi} 配下のものであれば全てのAPIを実行可能です。

メタデータサービスの設定方法、ユースケースは、[SORACOM開発者向けサイト](https://dev.soracom.io/jp/start/metadata/)をご確認ください。

---

## 4-1. SIMグループを作成しメタデータのユーザデータを設定する

SORACOM管理コンソールにログインし、SIMグループを作成します。
続いて、メタデータサービスの有効化とユーザデータの設定を行います。

### 4-1-1. SORACOM管理コンソールにログインする

まずは、[SORACOM管理コンソール](https://console.soracom.io/#/?coverage_type=jp)にアクセスし、ログインしてください。
ルートアカウント、SAMユーザーのいずれでも問題ありません。

- ルートアカウントログイン
![4-1-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-1_1.png)

- SAMユーザーログイン
![4-1-1_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-1_2.png)

### 4-1-2. SIMグループを作成する

メタデータサービスを設定するためのSIMグループを作成します。

- SORACOM管理コンソールの左端のメニューをクリックしてください。
![4-1-2_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-2_1.png)

- メニューのSIMグループをクリックしてください。
![4-1-2_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-2_2.png)

- SIMグループ画面の「＋追加」をクリックしてください。
![4-1-2_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-2_3.png)

- グループ名を入力し「グループ作成」をクリックしてください。
  - グループ名：任意(例：handson_metadata)
![4-1-2_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-2_4.png)

### 4-1-3. SIMグループにメタデータサービスの設定を行う

メタデータサービスの設定を行っていきます。

- 「SORACOM Air for Cellular 設定」をクリックし入力エリアを表示してください。
![4-1-3_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-3_1.png)

- 「メタデータサービス」のスイッチをクリックし有効化してください。
- 「読み取り専用」にチェックをつけてください。
![4-1-3_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-3_2.png)

※ 「読み取り専用」チェックを外せば、メタデータを更新することも可能です

- CORS対応で「許可するオリジン」にメタサービス呼び出し元のURLとして下記URLを入力してください。
    - 許可するオリジン：http://soracom-ug-reko-handson.s3-website-ap-northeast-1.amazonaws.com
![4-1-3_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-3_3.png)

- API接続情報を「ユーザーデータ」にJSON形式で入力し、「JSON形式で保存」にチェックしてください。
  - JSONデータ
    - apiEndpoint：後述の「APIのエンドポイントの確認方法」を参考に設定してください。
    - apiKey：後述の「APIキーの確認方法」を参考に設定してください。
    ![4-1-3_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-3_4.png)
      ```json
      {
        "apiEndpoint": "https://xxxxxxxx.execute-api.ap-northeast-1.amazonaws.com/prod/search",
        "apiKey": "xxxxxxxxxxxxxxxxxxx"
      }
      ```

- その他の項目は変更を行わずに下方の「保存」をクリックする
![4-1-3_5](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-3_5.png)

- SIMグループへのメタデータの設定は以上で完了

---

**APIのエンドポイントの確認方法**

AWSのコンソールで、ステップ3-2-6でデプロイしたAPIのステージを選択すると、「URLの呼び出し」の箇所にAPIのリソースパスが表示されます。
その後ろに「リソース名（指定通りに作成した場合は「/search」）」を不可してください。
（例：https://xxxxxxxx.execute-api.ap-northeast-1.amazonaws.com/prod/search）

![3-2-8-1_1](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-8-1_1.png)

**APIキーの確認方法**

AWSのコンソールで、ステップ3-2-7で作成したAPIキーを[表示]します。

![3-2-8-1_2](https://s3.amazonaws.com/docs.iot.kyoto/img/Rekognition-Handson/step2/2-2-8-1_2.png)

### ＜CORSとは？＞

オリジン間リソース共有機能（CORS＝Cross-Origin Resource Sharing）

セキュリティ上の理由から、ブラウザーは、スクリプトによって開始されるオリジン間 HTTPリクエストを制限しています。
追加の HTTP ヘッダーを使用して、あるオリジンで動作しているウェブアプリケーションに、異なるオリジンにある選択されたリソースへのアクセス権を与えるようブラウザーに指示するための仕組みです。

https://developer.mozilla.org/ja/docs/Web/HTTP/CORS

### ＜メタデータサービス入力項目 補足説明＞

- メタデータサービス設定
サービス自体を有効とするか否かのボタンです。
ONにすることで、メタデータサービスが有効となります。

- 読み取り専用チェックボックス
デバイスからのアクセス(API操作)を読み込みのみとしたい場合には、ここにチェックを付けてください。

- 許可するオリジン
CORS(Cross-Origin Resource Sharing) 用のオリジン設定です。
外部サイトから Ajax 等でアクセスを行う際に設定が必要です。
Access-Control-Allow-Origin ヘッダーに指定するドメインとなります。

- ユーザーデータ
ユーザー独自のデータを任意に定義できます。

---

### 4-1-4. 対象SIMにSIMグループを割り当てる

ステップ4-1-2で作成したSIMグループを、対象のSIMに割り当てます。

- SORACOM管理コンソールの左上のメニューをクリックし、メニューの「SIM管理」をクリックする
![4-1-4_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-4_1.png)

- 対象のSIMのチェックボックスをONにし、画面上部の「操作」から「所属グループ変更」をクリックする
![4-1-4_2](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-4_2.png)

- 「新しい所属グループ」にステップ4-1-2で作成したSIMグループを選択し「グループ変更」をクリックする
![4-1-4_3](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-4_3.png)

- SIM一覧表示画面で対象SIMのグループに選択したSIMグループ名が表示されていれば設定は完了
![4-1-4_4](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-4_4.png)

### 4-1-5. 対象SIMの速度クラスを変更する

今回使用するWebアプリでは、スマートフォンから画像をWeb API経由でAWSに送信しますので、速度クラスをfast以上に設定しておくことを推奨します。
速度が遅い場合は、タイムアウトが発生します。

- 対象SIMの速度クラスの選択ボックスを開いて「s1.fast」を選択してください。
![4-1-5_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-5_1.png)

- 変更後の速度クラスが「s1.fast」になっていることを確認し「速度クラスを変更する」をクリックしてください。
![4-1-5_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-5_2.png)

- 対象SIMの速度クラスが「s1.fast」に変わっていることを確認してください。
![4-1-5_1](https://s3.amazonaws.com/docs.iot.kyoto/img/SoracomUG-Reko-Handson/step4/4-1-5_3.png)

## 4-2. 【参考】メタデータサービスを利用するプログラムの作成

今回はWebアプリケーションは構築済みですので、参考情報としてどのようにWebアプリケーション（Vue.jsプログラム）側を実装するのかをご紹介します。

デプロイしたWebアプリケーションにはすでにAPIにアクセスするためのプログラムが組み込まれていますので、こちらの章ではコードを適宜引用しながら、APIにアクセスしている部分の解説を行います。

- Webアプリケーションのリポジトリを開き、以下のファイルを開いてください
  - https://github.com/IoTkyoto/soracom-ug-reko-handson/blob/master/webapp/src/components/SearchFacesSoracom.vue


#### SORACOMメタデータの取得方法

- 188行目〜212行目がSORACOMメタデータサービスでユーザーデータを取得しているメソッドとなります。
  - 197行目で「http://metadata.soracom.io/v1/userdata」に対しGetメソッドを実行しています
  - 201〜202行目で取得したレスポンスからユーザーデータを取り出し、キーを指定し個別データの読み込みを行っています。

```javascript:SearchFacesSoracom.vue
      /**
       * SORACOMメタデータ(userdata)取得
       */
      getSoracomMetadata() {
        // API接続情報の初期化
        this.apiEndpoint = '';
        this.apiKey = '';
        // HTTP非同期通信
        axios
          .get("http://metadata.soracom.io/v1/userdata", { timeout : 1000 })
          .then(response => {
            if (response.status == 200) {
              // SIMグループから取得したuserdataを内部変数に保存
              this.apiEndpoint = response.data.apiEndpoint;
              this.apiKey = response.data.apiKey;
            } else {
              console.log('レスポンスステータス：' + response.status);
              this.errorMessage = 'メタデータの取得に失敗しました。API接続情報を手動で入力してください。';
            }
          })
          .catch(error => {
            // メタデータ取得時にエラーが発生した場合はエンドポイント・ApiKeyクリア
            this.errorMessage = 'メタデータの取得に失敗しました。API接続情報を手動で入力してください：' + error;
          });
      },
```

#### メタデータ取得メソッドの呼び出しと保存

- 109行目〜116行目が画面表示(生成)時に実行される処理となっています。
- 115行目でメタデータ取得メソッドを呼び出し内部変数に保存しています。

```javascript:SearchFacesSoracom.vue
// 画面作成時にコンポーネント内で利用する変数の初期値を設定する
    created() {
      // Configミックスインの情報を設定
      this.apiEndpoint = this.config.searchConfig.apiEndpoint;
      this.apiKey = this.config.searchConfig.apiKey;
      this.threshold = this.config.searchConfig.threshold;
      // SORACOMメタデータサービスにアクセスしAPI接続情報を取得
      this.getSoracomMetadata();
    },
```



### 次のステップへ進んでください

- ここまでの作業で事前の準備作業は終了です
- [トップページ](https://iotkyoto.github.io/soracom-ug-reko-handson/)に戻って次のステップに進んでください
