# Roblox Obby Prototype

Roblox Studio と Rojo で動かす、小学生向けのかんたんな Obby 風ゲームです。

プレイヤーは足場を進み、赤い障害物をジャンプで避けます。緑のチェックポイントに触ると、落ちたときにそこからやり直せます。
赤い障害物に触るとキャラクターが倒れ、最後のチェックポイントから再開します。Goalに着くと、プレイヤーの近くに花吹雪が出ます。

## 動かし方

1. Roblox Studio を開きます。
2. Rojo プラグインを入れておきます。
3. このフォルダで Rojo を起動します。

```powershell
rojo serve
```

4. Roblox Studio の Rojo プラグインから接続します。
5. Studio の再生ボタンでテストします。

## ファイルの役割

### `default.project.json`

Rojo が「どのフォルダを Roblox のどのサービスに入れるか」を決める設定ファイルです。

このプロジェクトでは、次のように入ります。

- `src/ReplicatedStorage/Shared` -> `ReplicatedStorage.Shared`
- `src/ServerScriptService` -> `ServerScriptService`
- `src/StarterPlayer/StarterPlayerScripts` -> `StarterPlayer.StarterPlayerScripts`

### `src/ReplicatedStorage/Shared/ObbyConfig.lua`

ゲームの共通設定です。

歩く速さ、ジャンプ力、落ちたと判定する高さ、足場・障害物・チェックポイントの場所をまとめています。

サーバー側とクライアント側の両方から読みます。

### `src/ServerScriptService/ObbyServer.server.lua`

サーバー側のメイン処理です。

主に次のことをします。

- Obby の足場、障害物、チェックポイントを作る
- プレイヤーのチェックポイントを記録する
- 赤い障害物に触れたプレイヤーを倒す
- プレイヤーが落ちたら、最後に触ったチェックポイントへ戻す
- Goal に着いたら花吹雪を出す
- 右上の `Stage` 表示用の値を作る

### `src/StarterPlayer/StarterPlayerScripts/ObbyClient.client.lua`

プレイヤー本人のパソコン側で動く処理です。

主に次のことをします。

- 歩く速さとジャンプ力を設定する
- 画面上に今のチェックポイント名を表示する

## 最初に変えやすい場所

難しいコードをたくさん触らなくても、まずは `ObbyConfig.lua` を変えるのがおすすめです。

- `WalkSpeed` を大きくすると、速く歩けます。
- `JumpPower` を大きくすると、高くジャンプできます。
- `Checkpoints` を増やすと、チェックポイントを増やせます。
- `Platforms` を増やすと、足場を増やせます。
- `Obstacles` を増やすと、ジャンプで避ける赤い障害物を増やせます。

## 開発環境セットアップ（Windows + Roblox Studio + Rojo）

このプロジェクトは、Roblox Studio と Rojo を使って開発します。  
ローカルのファイルを編集し、Rojo経由でRoblox Studioへ同期して動作確認します。

### 前提

- Windows
- Roblox Studio インストール済み
- Git インストール済み
- mise インストール済み
- Rojo v7.6.1

### Rojo CLI のインストール

この環境では `mise` を使ってRojoをインストールしています。

```powershell
mise use -g github:rojo-rbx/rojo
rojo --version
```

このプロジェクトでは、Roblox Studio用プラグインとバージョンを合わせるため、Rojo CLI は **v7.6.1** を使います。

### Rojo Studioプラグインのインストール

`rojo plugin install` で以下のエラーが出る場合があります。

```text
[ERROR rojo] Couldn't find registry keys, Roblox might not be installed.
```

この場合は、Rojo Studioプラグインを手動で配置します。

1. GitHub Releases を開く  
   https://github.com/rojo-rbx/rojo/releases

2. Rojo CLI と同じバージョンのリリースを開く  
   例: `v7.6.1`

3. `Rojo.rbxm` をダウンロードする

4. 次のフォルダに配置する

```text
C:\Users\<ユーザー名>\AppData\Local\Roblox\Plugins
```

この環境では以下に配置しました。

```text
C:\Users\takat\AppData\Local\Roblox\Plugins\Rojo.rbxm
```

5. Roblox Studioを再起動する

6. 新規プロジェクトを開き、上部の **Plugins** タブに **Rojo** が表示されれば成功です

注意:  
手動配置した `Rojo.rbxm` は、Roblox Studioの「プラグイン管理」には表示されない場合があります。  
確認する場所は「プラグイン管理」ではなく、上部リボンの **Plugins** タブです。

## 開発時の起動方法

プロジェクトフォルダでPowerShellを開きます。

```powershell
rojo serve
```

Rojoサーバーが起動すると、次のような表示になります。

```text
Rojo server listening on port 34872
```

このPowerShellは閉じずに開いたままにします。

次にRoblox Studioで以下を行います。

1. Roblox Studioを開く
2. 新規プロジェクト、または既存プロジェクトを開く
3. 上部の **Plugins** タブを開く
4. **Rojo** をクリックする
5. **Connect** を押す
6. `localhost:34872` に接続する
7. 同期内容を確認して反映する

これで、ローカルファイルの構成がRoblox Studio上に反映されます。

## コード変更時の反映方法

CodexやVS Codeでローカルファイルを変更した場合、`rojo serve` が起動していればRoblox Studioへ同期されます。

ただし、プレイ中に変更したコードは、実行中のセッションには反映されない場合があります。

そのため、変更後は次の流れで確認します。

```text
1. Codexでコードを修正する
2. RojoがRoblox Studioへ同期する
3. Roblox Studioで実行中のプレイをStopする
4. 再度Playする
5. 修正内容が反映されていることを確認する
```

つまり、**コードを書き直したら、Studioで一度StopしてからPlayし直す**のが基本です。

## 推奨開発ループ

```text
1. Codexに修正指示を出す
2. ローカルファイルが更新される
3. RojoでRoblox Studioへ同期される
4. Roblox StudioでPlayして確認する
5. 問題があればStopする
6. Codexに状況を伝えて再修正する
7. 動いた状態をGitにコミットする
```

## Gitでの保存

動く状態になったら、こまめにコミットします。

```powershell
git status
git add .
git commit -m "Update Roblox prototype"
```

特に、Roblox Studio上で動作確認できたタイミングではコミットしておくと、後から壊れたときに戻しやすくなります。

## トラブルシュート

### PluginsタブにRojoが出ない

以下を確認します。

- `Rojo.rbxm` が正しい場所にあるか
- ファイル名が `Rojo.rbxm` になっているか
- `Rojo.rbxm.download` や `Rojo.rbxm.txt` になっていないか
- Roblox Studioを再起動したか
- Rojo CLIとRojo Studioプラグインのバージョンが合っているか

配置場所:

```text
C:\Users\<ユーザー名>\AppData\Local\Roblox\Plugins\Rojo.rbxm
```

### プラグイン管理にRojoが出ない

手動配置したRojoプラグインは、プラグイン管理に表示されない場合があります。  
上部の **Plugins** タブにRojoボタンが出ていれば問題ありません。

### `rojo plugin install` が失敗する

次のようなエラーが出ることがあります。

```text
[ERROR rojo] Couldn't find registry keys, Roblox might not be installed.
```

この場合は、Roblox Studioのインストール情報をRojoがWindowsレジストリから見つけられていません。  
GitHub Releasesから `Rojo.rbxm` をダウンロードし、手動でPluginsフォルダへ配置します。

### 変更したコードが反映されない

Roblox Studioでプレイ中の場合、変更が即時反映されないことがあります。  
一度 **Stop** してから、再度 **Play** してください。
