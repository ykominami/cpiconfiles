# Cpiconfiles

TODO: Delete this and the text below, and describe your gem

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/cpiconfiles`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

## Usage

    $ bundle exec ruby bin/cmd  yaml "top_dir" -o ”YAMLファイル”
    指定ディレクトリ下のアイコンファイルの一覧をYAML形式で出力する

    $ bundle exec ruby bin/cmd  yaml "top_dir" -o ”JSONファイル”
    指定ディレクトリ下のアイコンファイルの一覧をJSON形式で出力する

    $ bundle exec ruby bin/cmd  fyaml "top_dir" - a5.yml

    bundle exec ruby bin/cmd gem install UPDATE_WITH_YOUR_GEM_NAME_PRIOR_TO_RELEASE_TO_RUBYGEMS_ORG

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ykominami/cpiconfiles. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ykominami/cpiconfiles/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cpiconfiles project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ykominami/cpiconfiles/blob/main/CODE_OF_CONDUCT.md).


● a.rb（ルートディレクトリ）

  Google OAuth2 / サービスアカウント認証用のJSONデータを StringIO で構築するスクリプトです。

  処理の流れ：

  1. hash0 / sio（ハードコード版） — OAuth2クライアント情報（client_id, client_secret
  など）をハードコードしたハッシュをJSONに変換し StringIO に格納（後で sio は上書きされるので実質未使用）
  2. hash / sio（環境変数版） — 同じ構造のハッシュを .env ファイルの環境変数（CLIENT_ID, PROJECT_ID,
  CLIENT_SECRET）で組み立て、StringIO に格納
  3. sio1 — hash0 と同内容をインラインで直接 StringIO に格納（参照用の別バリアント）
  4. sio2 — サービスアカウント用の認証情報を環境変数（GOOGLE_CLIENT_EMAIL_FOR_GA,
  GOOGLE_PRIVATE_KEY_FOR_GA）から組み立て。private_key の \n をリテラル改行に変換する処理が含まれる
  5. p sio — 最終的に sio（環境変数版）の内容を出力

  要点： 実際に使う値は sio（環境変数から組み立てたOAuth2認証情報）のみで、他は開発・参照用の断片です。本番では GoogleDrive
  クラスがこの形式の StringIO を受け取って認証に使います。

  ---
  bin/a.rb

  Thor を使った簡易CLIのサンプルです。

  - echo — 引数のテキストを表示
  - ls — カレントディレクトリのファイル一覧を表示（-l オプションで隠しファイルも含む）

  こちらは実験・学習用のスクリプトで、本体のgemとは無関係です。

❯ bin/cmdの動作を説明して

  Searched for 2 patterns, read 3 files (ctrl+o to expand)

● bin/cmd の動作

  bin/cmd は Cpiconfiles::Cmd.start(ARGV) を呼び出すだけのエントリポイントです。実体は lib/cpiconfiles/cmd.rb の Cmd
  クラス（Thor サブクラス）です。

  ---
  サブコマンド一覧

  yaml <top_dir> -o <output.yaml> [-c <csv>] [-d <dump>] [-x]

  指定ディレクトリ下のアイコンファイルを収集してYAMLに出力。

  1. Appenv.set_dump_file でダンプファイルを設定
  2. Cli#yaml でスキャン・解析を実行
  3. Yamlstore.save でYAMLファイルに書き出し

  オプション -x でダンプファイルを使わず強制再スキャン。

  ---
  csv <top_dir> -o <output.csv>

  アイコンファイルの一覧をCSV出力。

  1. Cli#csv でスキャン・解析
  2. CSVファイルに書き出し

  ---
  csv_upload <top_dir>

  CSVを生成してGoogle Driveにアップロード。

  1. Cli#csv でCSV生成（pciconfile.csv 固定）
  2. タイムスタンプ付きのファイル名（例: pciconfile-20260410-120000）で GDrive#upload を呼び出す

  ---
  cp2 <top_dir> [-o <output_dir>] [-d <dump>] [-x]

  アイコンファイルを指定ディレクトリにコピー。

  1. 出力ディレクトリが存在すれば中身を一旦削除、なければ作成
  2. Cli#copy_to でコピー実行

  ---
  json <top_dir> -o <output.json> [-d <dump>] [-x]

  アイコンファイルの一覧をJSON出力。

  1. Cli#json でスキャン・解析
  2. File.write でJSONファイルに書き出し

  ---
  fyaml -o <yaml_file>

  既存のYAMLファイルを読み込んで復元（再解析）。Yamlstore.load → loadx → restorex の順で処理。

  ---
  fjson -d <json_file>

  既存のJSONファイルを読み込んで JSON.parse するだけ（結果は現状未使用）。

  ---
  備考

  - csvi サブコマンドはCSVを読み込んで解析する実装途中のコマンド（TODO状態）
  - bin/cmd.bat はWindows用のラッパーで、引数をそのまま bin/cmd に渡すだけ