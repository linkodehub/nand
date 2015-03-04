# Nand [![Gem Version](https://badge.fury.io/rb/nand.svg)](http://badge.fury.io/rb/nand) [![Code Climate](https://codeclimate.com/github/linkodehub/nand/badges/gpa.svg)](https://codeclimate.com/github/linkodehub/nand)

## 概要

Nand は Nandemo(ナンデモ) daemon にすることができるRubyで作られたシンプルなコマンドラインツールです。

ここで言う"ナンデモ"とは、シェルコマンドや実行形式のファイル、
Rubyファイル(ライブラリやnandのplugin)になります。

デーモン化するには、シンプルに `nand start TARGET`をコマンドラインから実行するだけです。
停止させるには、もちろん`nand stop TARGET`です。
動作状態の確認は`nand status TARGET`で確認できます。

## インストール

    $ gem install nand

## 簡単な利用方法

### コマンド

	$ nand SUB_COMMAND TARGET [オプション]

`SUB_COMMAND` と デーモンプロセスのターゲットを指定します。

### 起動

	$ cd /any/path
	$ nand start sleep 1000
	sleep is Start Success [85596]

ターゲット以降で、Nandのオプションとして認識されないものは、
デーモンプロセスへ引き渡されます。
なお、`sleep 1000` がデーモンプロセスとして動作し、`sleep`がデーモンプロセス名としてnandに認識されます。

### 状態確認

ターゲット`sleep`の動作状況を確認するためには、以下のコマンドを実行します。

	$ cd /any/path
	$ nand status sleep
	sleep is Running [85596] by USER in /any/path

`start`と同一ディレクトリであれば、デーモンプロセス名としての`sleep`は省略できます。

### 停止

	$ nand stop sleep
	sleep is Stopped [85596]

`stop`も`status`と同様に`start`と同一ディレクトリであれば、
デーモンプロセス名としての`sleep`は省略もできます。

	$ nand status sleep
	sleep is Not Running in /any/path


## Rubyファイルのデーモン化

カレントディレクトリに 以下の様な `forever_sleep.rb` というファイルが存在する場合

```ruby:forever_sleep.rb
require 'nand/plugin'

module Sample
  class ForeverSleep
    extend Plugin
    def self.executor(*argv)
      new(*argv)
    end
    def exec
      sleep
    end
  end
end
```

	$ nand start forever_sleep.rb -p Sample::ForeverSleep
	forever_sleep.rb is Start Success [86326]

	$ nand stop forever_sleep.rb
	forever_sleep.rb is Stopped [86326]

実行可能ファイルでないRubyのファイルを指定する場合は、Nand::Pluginをextendしたクラスの
クラス名を`-p`オプションで指定する必要があります。
ただし、`-p`オプションが未指定の場合、ファイル名からからクラス名を類推しようとします。
この例の場合、
ファイル名が _forever_sleep.rb_ のため、`ForeverSleep` クラスとして検索します。
残念ながらこの例では、失敗します。

もし、上記のようなファイルをsample-VERSION.gemとしてインストールした場合は、
Rubyのファイル名ではなく、パッケージ名を指定することで、デーモン化できます。
ただし、Pluginファイルを指定されたディレクトリとファイル名で
(sample/nand/plugin.rb)配置する必要があります。


## 様々な利用方法

### Nandオプションと重複する場合

Nandオプションと重複する場合は、2通りの方法で回避できます。

一つめは、"や'(クォーテーション)でオプションを囲む方法

	$ nand start any.sh "--run_dir /tmp"

なお、`"--run_dir /tmp"`は内部では `--run_dir`, `/tmp`に分割されますので、
分割されないようにするためには、`'"--run_dir /tmp"'`などのようにする必要があります。

二つめは 2つのダッシュ(--)の後に記述する方法

	$ nand start any.sh -- --run_dir /tmp

これらの方法で、nandと重複するオプションを指定したターゲットに引き渡すことができます。

### デーモンプロセスへのパイプ


```sh
#!/bin/sh
sleep $1
echo $2
```

sleep_echo.shという実行形式のファイルがあった場合、

	$ nand start sleep_echo.sh 100 '"foo bar baz"' --out out.log
	
	$ cat out.log
	foo bar baz

なお、STDINは`--in`、STDERRは `--err`にそれぞれパイプをつなぐことができます。


### 動作ディレクトリの変更

Nandにとって、動作ディレクトリは非常に重要です。
PIDファイルを出力したり、デーモンプロセスは動作ディレクトリに移動して動作します。

動作ディレクトリは基本的にnandコマンドを実行したディレクトリですが、
オプションで指定もできます。

	$ nand start sleep_echo.sh 100 abc --run_dir /tmp --out out.log

これにより、`out.log`は`/tmp/out.log`に出力されます。


### 二重起動の禁止

原則として同じターゲットを指定して、デーモン化できません。

	$ nand start sleep 1000
	sleep is Start Success [97649]
	$ nand start sleep 1000
	sleep is Start Failed [PID file exist /any/path/.nand_sleep.pid]

これを回避する必要がある場合は、前述の動作ディレクトリを変更するか、
`-n` オプションを利用してデーモンプロセス名を指定する方法があります。

	$ nand start sleep 1000 -n sleep1
	sleep1 is Start Success [97649]
	$ nand status
	sleep is Running [97649] by USER in /run/dir
	sleep1 is Running [97765] by USER in /run/dir


### 制限時間で自動停止させる


制限時間を秒で設けて、自動停止させることができます。

	$ nand start vmstat 5 --sec 600

上記の例では、600秒後に自動で停止します。

### 自動再起動

デーモンプロセスが停止した場合、`-r` オプションを設定しておくことで、
自動で再起動させることができます。

	$ nand start sleep 100 -r

この例では、100秒後に停止した`sleep 100`が、再度`sleep 100`で
再起動します。

## 注意事項


`stop`時はデーモンプロセスが管理するプロセスグループに対して、SIGTERMを送信します。
デーモンプロセスは送信したプロセスグループの終了を待ち合わせます。
デーモン化したい処理については、必ずSIGTERMで終了するようにしてください。

動作ディレクトリにおいて、`.nand_デーモンプロセス名.pid`というファイルが生成されます。
このファイルは二重起動抑制のために利用される他、`stop/status`時の
整合性確認にも利用されます。
もし、このファイルを誤って削除した場合は、`stop/status`がエラーを出力します。
その指示に従って、不要なプロセスであることをpsコマンドなどで確認して、
手動でプロセスを停止させてください。
	
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
