# ASIC Tutorial

## 0. 事前準備 (Environment Setup)

0.1. チュートリアルをクローンする。
```cmd
git clone https://github.com/k-awaki/tomlab-asic-tutorial.git
cd tomlab-asic-tutorial
```

0.2. Cadenceツールのパスを通すために、ホームディレクトリの `.bashrc` を設定する。
```bash
cat ~/.bashrc
```

ファイルの末尾に以下の設定がない場合は、`vi ~/.bashrc` 等で追記し、`source ~/.bashrc` を実行。

```bash
# Cadence License
export CDS_LIC_FILE=/opt/cadence/license/license.dat
export CDS_AUTO_64BIT=ALL

# DDI
export DDI_INST_DIR=/opt/cadence/DDI/DDI231
export PATH=$DDI_INST_DIR/bin:$PATH

# SSV
export SSV_INST_DIR=/opt/cadence/SSV/SSV231
export PATH=$SSV_INST_DIR/bin:$PATH

# QUANTUS
export QUANTUS_INST_DIR=/opt/cadence/QUANTUS/QUANTUS231
export PATH=$QUANTUS_INST_DIR/bin:$PATH

# XCELIUM
export XCELIUM_INST_DIR=/opt/cadence/XCELIUM/XCELIUM2309
export PATH=$XCELIUM_INST_DIR/tools.lnx86/bin:$PATH
```
| 動作確認: `which genus` を実行し、パスが表示されればOK。

0.3 `tree.bash`を実行し、ディレクトリ構成を確認。
```cmd
$ ./tree.bash
.
├── README.md
├── mmmc
│   └── enc_default.view
├── model
│   └── counter.v
├── script
│   ├── genus.tcl
│   ├── genus_config.tcl
│   ├── innovus.tcl
│   ├── innovus_config.tcl
│   ├── run_xrun_gate
│   ├── run_xrun_layout
│   ├── run_xrun_rtl
│   ├── tempus.tcl
│   ├── tempus_config.tcl
│   ├── wave_gate.tcl
│   ├── wave_layout.tcl
│   └── wave_rtl.tcl
├── sdc
│   └── clk.sdc
├── sim
├── tb
│   ├── counter_gate_tb.v
│   ├── counter_layout_tb.v
│   └── counter_rtl_tb.v
└── tree.bash
```

## 1. RTLシミュレーションと波形確認 (RTL Simulation & Waveform Check)

1.1. RTLシミュレーションの実行
```cmd
./script/run_xrun_rtl
```
終了後、必ず以下の項目をチェックしてください。
- [ ] ログに tb, model どちらも `errors: 0` を確認。
- [ ] ログの最後に `... Done` を確認。

以下のコマンドで`SimVision`を起動します。

```bash
simvision &
```

> ディスプレイが見つからない等のエラーが出た場合、「TeraTerm & Xlaunch」で検索（windows）。

### 波形の表示手順 (Steps to view waveforms)

1. SimVisionのメニューから 「File」→「Open Database...」 をクリック。（アイコン：<img width="30" height="25" alt="Image" src="https://github.com/user-attachments/assets/d521736f-7283-4964-a557-b95ecdc97440" />）
2. `sim/waves_rtl.shm` を選択して開く。
3. 左側のDesign Browserから `counter_rtl_tb` 等を選択。
4. 右側のSignals一覧から見たい信号を選び、右クリック → 「Send to Waveform Window」 をクリック。(アイコン：<img width="25" height="28" alt="Image" src="https://github.com/user-attachments/assets/639b4693-d5a0-4ddd-8d12-6fb3ef551944" />)

## 2. 論理合成 (Logic Synthesis - Genus)

2.1. RTLコードからゲートレベルのネットリストを生成する。
```bash
genus -legacy_ui -files script/genus.tcl
```

終了後、必ず以下の項目をチェックしてください。
- [ ] ログに `Synthesis Finished .........` と表示されていること。
- [ ] `genus/logs_power/genus.log` を確認し、`error` や `Error` がないこと。
- [ ] `genus/reports_power/final.rpt` 内のタイミングレポートを確認し、Slack違反がないこと。

2.2. pre-layout Gate-Level シミュレーションの実行
```cmd
./script/run_xrun_gate
```
終了後、必ず以下の項目をチェックしてください。
- [ ] ログに tb, model どちらも `errors: 0` を確認。
- [ ] ログの最後に `... Done` を確認。

以下のコマンドで`SimVision`を起動します。

```bash
# 既に開いていたら、実行不用
# simvision &
```

> ディスプレイが見つからない等のエラーが出た場合、「TeraTerm & Xlaunch」で検索（windows）。

### 波形の表示手順 (Steps to view waveforms)

1. SimVisionのメニューから 「File」→「Open Database...」 をクリック。（アイコン：<img width="30" height="25" alt="Image" src="https://github.com/user-attachments/assets/d521736f-7283-4964-a557-b95ecdc97440" />）
2. `sim/waves_gate.shm` を選択して開く。
3. 左側のDesign Browserから `counter_rtl_tb` 等を選択。
4. 右側のSignals一覧から見たい信号を選び、右クリック → 「Send to Waveform Window」 をクリック。(アイコン：<img width="25" height="28" alt="Image" src="https://github.com/user-attachments/assets/639b4693-d5a0-4ddd-8d12-6fb3ef551944" />)

## 3. 配置配線 (Place & Route - Innovus)

3.1. 論理合成後のネットリストをもとに、チップ上の物理的な配置と配線を行います。
```bash
innovus -files script/innovus.tcl
```

終了後、`innovus/reports/` フォルダ内のレポートで以下の3点に違反がないか確認してください。
* [ ] ジオメトリ違反の確認 (DRC Check): `geomafterroute.rpt` を確認し、配線ルール違反がないこと (`Total Violations : 0`)。
* [ ] 接続違反の確認 (LVS Check): `connafterroute.rpt` を確認し、ショートや未結線がないこと (`Total Violations : 0`)。
* [ ] タイミング違反の確認 (Timing Check): `timingReports/` 内のサマリ (`.summary.gz` 等) を確認し、セットアップ/ホールド時間のSlackがプラス（Positive）であること。

3.2. Post-Layout Gate-Level Simulation

配置配線で付加された遅延（SDF）を加味した高精度なシミュレーションを実行します。

```bash
./script/run_xrun_layout
```
終了後、必ず以下の項目をチェックしてください。
- [ ] ログに tb, model どちらも `errors: 0` を確認。
- [ ] ログの最後に `... Done` を確認。

以下のコマンドで`SimVision`を起動します。

```bash
# 既に開いていたら、実行不用
# simvision &
```

> ディスプレイが見つからない等のエラーが出た場合、「TeraTerm & Xlaunch」で検索（windows）。

### 波形の表示手順 (Steps to view waveforms)

1. SimVisionのメニューから 「File」→「Open Database...」 をクリック。（アイコン：<img width="30" height="25" alt="Image" src="https://github.com/user-attachments/assets/d521736f-7283-4964-a557-b95ecdc97440" />）
2. `sim/waves_layout.shm` を選択して開く。
3. 左側のDesign Browserから `counter_rtl_tb` 等を選択。
4. 右側のSignals一覧から見たい信号を選び、右クリック → 「Send to Waveform Window」 をクリック。(アイコン：<img width="25" height="28" alt="Image" src="https://github.com/user-attachments/assets/639b4693-d5a0-4ddd-8d12-6fb3ef551944" />)
