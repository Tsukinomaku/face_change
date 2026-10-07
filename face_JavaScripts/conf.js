const nothing = -1; // 操作対象ID：-1は選択なし。両方選択と背景は配列の添字へ変換して使う
const leftEye = 0; // 左目
const rightEye = 1; // 右目
const leftEyebrow = 2; // 左眉
const rightEyebrow = 3; // 右眉
const leftupperEyelid = 4; // 左上瞼
const rightupperEyelid = 5; // 右上瞼
const leftlowerEyelid = 6; // 左下瞼
const rightlowerEyelid = 7; // 右下瞼
const bothEyes = 8; // 両目
const bothEyebrows = 9; // 両眉
const bothupperEyelids = 10; // 両上瞼
const bothlowerEyelids = 11; // 両下瞼
const backgroundTarget = 12; // 背景
const minI_d = leftEye; // 最小値
const maxI_d = backgroundTarget; // 最大値
let targetI_d = leftEye; // 現在の操作対象。起動時は左目

const number_of_parts = 9; // 配列の要素数；左目～背景用データまでの9個
const number_of_presets = 7; // プリセットの個数
const trans_index = 5; // transformsの1パーツ当たりの要素数
const rgb_index = 3; // RGB入力欄・JSONの成分数

const rgb_R = 0; // 色の成分番号：R=0、G=1、B=2
const rgb_G = 1;
const rgb_B = 2;

const transf_x = 0; // 変形配列の項目番号：X・Y・角度・幅・高さ
const transf_y = 1;
const transf_angle = 2;
const transf_width = 3;
const transf_height = 4;

const input_R = 0; // 入力欄の番号：RGBは0〜2、角度は3、X・Y・幅・高さは4〜7
const input_B = 2;
const input_angle = 3;
const input_x = 4;
const input_y = 5;
const input_width = 6;
const input_height = 7;
const input_nothing = -1; // 入力欄を選択していない状態

const screen_width = 800; // 画面全体の幅（px）
const screen_height = 880; // 画面全体の高さ（px）
const screen_fps = 30; // 1秒あたりの描画・録画枚数

const canvas_x = 0; // 顔を描画する領域
const canvas_y = 0;
const canvas_width = 600;
const canvas_height = 700;
const canvas_center_x = canvas_x + canvas_width / 2.0; // 線対称と補助線の基準

const right_panel_x = canvas_x + canvas_width; // 右側UIパネル
const right_panel_y = canvas_y;
const right_panel_width = screen_width - canvas_width;
const right_panel_height = screen_height;

const under_panel_x = canvas_x; // 下部UIパネル
const under_panel_y = canvas_y + canvas_height;
const under_panel_width = canvas_width;
const under_panel_height = screen_height - canvas_height;

const japanese_font = "sans-serif"; // ブラウザで使用する日本語対応フォント
const default_font_size = 14;

const move_step = 5; // キー操作・数値入力；移動キー1回あたりの移動量
const rotation_step = 3; // 回転キー1回あたりの角度
const input_max_length = 8; // 数値入力の最大文字数

const black = rgb(0); // 基本色
const white = rgb(255);

const right_panel_color = rgb(30); // UI表示色
const under_panel_color = rgb(40);
const normal_button_color = rgb(4);
const selected_button_color = rgb(100, 200, 100);
const text_color = white;
const sub_text_color = rgb(220);
const warning_text_color = rgb(255, 100, 100);
const input_background_color = rgb(15);
const ui_stroke_color = rgb(100);
const red_slider_color = rgb(255, 60, 60);
const green_slider_color = rgb(60, 255, 60);
const blue_slider_color = rgb(60, 60, 255);
const guide_line_color = rgb(150, 150, 150, 100); // 描画で使う固定色
const symmetry_guide_color = rgb(100, 150, 200, 120);
const eyelid_button_color = rgb(80, 80, 100);
const guide_button_color = rgb(100, 100, 120);
const locked_button_color = rgb(180, 100, 100);
const unlocked_button_color = rgb(100, 120, 180);
const saved_preset_color = rgb(60, 140, 180);
const empty_preset_color = rgb(80);
const reset_button_color = rgb(180, 80, 80);
const save_button_color = rgb(80, 120, 180);
const load_button_color = rgb(80, 160, 100);
const recording_button_color = rgb(200, 50, 50);
const record_button_color = rgb(80, 120, 80);
const export_video_button_color = rgb(150, 100, 180);
const help_text_color = rgb(160);
const active_input_color = rgb(60, 60, 100);
const active_input_stroke_color = rgb(100, 150, 255);
const input_stroke_color = rgb(70);

const targetNames = ["左目","右目","左眉","右眉","左上瞼","右上瞼","左下瞼","右下瞼","両目","両眉","両上瞼","両下瞼","背景"]; // 操作対象の名前

const uiGrid = [ // UIボタンの並び順 3列 × 5行
  leftEye,           bothEyes,          rightEye,
  leftEyebrow,       bothEyebrows,      rightEyebrow,
  leftupperEyelid,   bothupperEyelids,  rightupperEyelid,
  leftlowerEyelid,   bothlowerEyelids,  rightlowerEyelid,
  nothing,           backgroundTarget,        nothing
];

const face_draw_order = [ // 重なりを保つための顔パーツ描画順。
  leftEye, rightEye,
  leftupperEyelid, rightupperEyelid,
  leftlowerEyelid, rightlowerEyelid,
  leftEyebrow, rightEyebrow
];

const input_box_radius = 4; // 共通ボタン・入力欄の見た目
const system_button_radius = 4;
const input_text_y_offset = -2;
const button_text_y_offset = -2;
const input_border_width = 1;
const active_input_border_width = 2;
const button_hover_brightness = 30;

const guide_line_width = 1; // 補助線の見た目
const symmetry_guide_width = 1.5;
const guide_dash_step = 10;
const guide_dash_length = 5;

const default_colors = [ // 初期化用の色 [パーツ番号]
  rgb(100, 150, 255), // 左目
  rgb(255, 100, 150), // 右目
  white, white,       // 左眉・右眉
  black, black,       // 左上瞼・右上瞼
  black, black,       // 左下瞼・右下瞼
  black               // 背景
];

let colors = default_colors.slice(); // 現在の色。初期値をコピーし、初期化用配列は変更しない。

const default_transforms = [ // 初期値：[パーツ番号][X, Y, 角度, 幅, 高さ]。背景データは最後の行。
  [200, 300,   0,  80, 140], // 左目
  [400, 300,   0,  80, 140], // 右目
  [200, 180,  15, 100,   8], // 左眉
  [400, 180, -15, 100,   8], // 右眉
  [200, 230,   0, 200, 200], // 左上瞼
  [400, 230,   0, 200, 200], // 右上瞼
  [200, 370,   0, 200, 200], // 左下瞼
  [400, 370,   0, 200, 200], // 右下瞼
  [canvas_x, canvas_y, 0, 0, 0] // 背景（移動・回転には使わない）
];

let transforms = default_transforms.map(row => row.slice()); // 現在の位置・角度・サイズ。各行もコピーして初期値と独立させる。

const target_grid_column = 3; // パーツ選択ボタン
const target_button_start_x = right_panel_x + 10;
const target_button_start_y = 20;
const target_button_width = 55;
const target_button_height = 30;
const target_button_step_x = 60;
const target_button_step_y = 38;
const target_button_radius = 5;
const target_button_text_size = 11;

const rgb_base_y = 210; // RGBスライダー
const rgb_row_step_y = 45;
const rgb_label_x = right_panel_x + 15;
const rgb_label_y_offset = 10;
const rgb_Label_text_size = 13;
const rgb_slider_x = right_panel_x + 15;
const rgb_slider_y_offset = 22;
const rgb_slider_width = 115;
const rgb_slider_height = 12;
const rgb_slider_radius = 6;
const rgb_input_x = right_panel_x + 140;
const rgb_input_y_offset = 17;
const rgb_input_width = 45;
const rgb_input_height = 22;
const rgb_min = 0;
const rgb_max = 255;

const warning_text_x = right_panel_x + 15; // 注意メッセージ
const warning_text_y = rgb_base_y + 145;
const warning_text_size = 11;

const rotation_dial_x = right_panel_x + 100; // 回転角度ダイヤル
const rotation_dial_y = 425;
const rotation_dial_radius = 35;
const rotation_dial_title_y_offset = -48;
const rotation_dial_title_size = 13;
const rotation_dial_mark_step = 30;
const rotation_dial_mark_length = 4;
const rotation_dial_hit_margin = 10;
const rotation_dial_angle_offset = 90;
const rotation_dial_border_width = 2;
const rotation_dial_pointer_width = 4;
const rotation_input_x = 678;
const rotation_input_y = rotation_dial_y + 42;
const rotation_input_width = 45;
const rotation_input_height = 22;

const coordinate_labels = ["位置 X:", "位置 Y:", "幅 W:", "高さ H:"]; // 座標・大きさ入力欄
const coordinate_input_ids = [input_x, input_y, input_width, input_height];
const coordinate_channels = [transf_x, transf_y, transf_width, transf_height]; // X・Y・幅・高さの入力欄に対応する変形項目
const coordinate_base_y = 515;
const coordinate_label_x = right_panel_x + 20;
const coordinate_input_x = right_panel_x + 75;
const coordinate_row_step_y = 30;
const coordinate_label_y_offset = 11;
const coordinate_input_width = 50;
const coordinate_input_height = 22;

const symmetry_check_x = right_panel_x + 20; // 線対称チェックボックス
const symmetry_check_y = 640;
const symmetry_check_size = 18;
const symmetry_check_radius = 3;
const symmetry_check_border_width = 1;
const symmetry_check_line_width = 3;
const symmetry_text_x = right_panel_x + 45;
const symmetry_text_y = symmetry_check_y + 8;
const symmetry_text_size = 13;

const eyelid_button_y = 680; // 瞼形状・補助線ボタン
const eyelid_button_width = 90;
const eyelid_button_height = 28;
const upperEyelid_button_x = right_panel_x + 10;
const lowerEyelid_button_x =  right_panel_x + 105;
const guide_button_x = right_panel_x + 10;
const guide_button_y = 715;
const guide_button_width = 185;
const guide_button_height = 28;

const colorLock_button_start_x = right_panel_x + 10; // 色固定ボタン
const colorLock_button_y = 750;
const colorLock_button_width = 58;
const colorLock_button_height = 28;
const colorLock_button_step_x = 63;
const moveLock_button_start_x = right_panel_x + 10; // 移動固定ボタン
const moveLock_button_y = 785;
const moveLock_button_width = 58;
const moveLock_button_height = 28;
const moveLock_button_step_x = 63;

const preset_title_x = under_panel_x + 20; // 下部パネル：プリセット
const preset_title_y = under_panel_y + 25;
const preset_button_start_x = under_panel_x + 20;
const preset_button_y = under_panel_y + 40;
const preset_button_width = 35;
const preset_button_height = 30;
const preset_button_step_x = 40;

const anim_duration_min = 100; // 下部パネル：アニメーション速度；所要時間の下限（ms）
const anim_duration_max = 5000; // 所要時間の上限（ms）
const anim_duration_default = 1500; // 起動・初期化時の所要時間（ms）
const speed_title_x = under_panel_x + 20;
const speed_title_y = under_panel_y + 95;
const speed_slider_x = under_panel_x + 20;
const speed_slider_y = under_panel_y + 110;
const speed_slider_width = 260;
const speed_slider_height = 15;
const speed_slider_radius = 6;
const speed_slider_border_width = 1;

const system_title_x = under_panel_x + 350; // 下部パネル：システムボタン
const system_title_y = under_panel_y + 25;
const system_button_y = under_panel_y + 40;
const system_button_width = 65;
const system_button_height = 30;
const reset_button_x = under_panel_x + 350;
const save_button_x = under_panel_x + 425;
const load_button_x = under_panel_x + 500;

const video_title_x = under_panel_x + 350; // 下部パネル：動画作成
const video_title_y = under_panel_y + 95;
const record_button_x = under_panel_x + 350;
const record_button_y = under_panel_y + 110;
const record_button_width = 150;
const record_button_height = 30;
const exportVideo_button_x = under_panel_x + 505;
const exportVideo_button_y = under_panel_y + 110;
const exportVideo_button_width = 60;
const exportVideo_button_height = 30;

const help_text_x = under_panel_x + 20; // 下部パネル：操作説明
const help_text_y = under_panel_y + 155;
const help_text_size = 11;

const coordinate_label_text_size = 13; // 共通の文字サイズ
const input_text_size = 13;
const system_button_text_size = 12;
const ui_title_text_size = 12;
const recording_text_size = 16;

const recording_mark_x = canvas_x + 25;
const recording_mark_y = canvas_y + 25;
const recording_mark_size = 16;
const recording_bright_alpha = 255;
const recording_dim_alpha = 100;
const recording_text_x_offset = 15;
const recording_text_y_offset = -3;


let active_text_box = input_nothing; // 現在選択している入力欄
let input_text = ""; // 入力中の文字列
let symmetry_mode = true; // trueなら両方選択時に左右を線対称にする
const eyelidEllipse_shape = 0; // 瞼形状の番号：楕円=0、四角=1
const eyelid_rectangle_shape = 1;
let upperEyelid_shape = eyelidEllipse_shape; // 上瞼の形状
let lowerEyelid_shape = eyelidEllipse_shape; // 下瞼の形状
let showGuide_line = true; // trueなら補助線を表示（録画中は非表示）

let lock_bg_color = false; // 色固定状態。trueならプリセット遷移で現在色を保つ。
let lockEye_color = false;
let lock_brow_color = false;

let lockLid_move = false; // 移動固定状態。trueならプリセット遷移で位置・形を保つ。
let lockEye_move = false;
let lock_brow_move = false;

let start_transforms = createArray(number_of_parts, trans_index); // アニメーション開始時の位置・形
let target_transforms = createArray(number_of_parts, trans_index); // アニメーションの目標位置・形
let start_colors = createArray(number_of_parts); // アニメーション開始時の色
let target_colors = createArray(number_of_parts); // アニメーションの目標色
let anim_start_time = 0; // アニメーションを開始した時刻
let anim_duration = anim_duration_default; // 現在のアニメーション所要時間（ms）
let animating = false; // trueの間だけアニメーションを更新

let preset_transforms = createArray(number_of_presets, number_of_parts, trans_index); // プリセット；[プリセット番号][パーツ番号][変形項目]
let preset_colors = createArray(number_of_presets, number_of_parts); // [プリセット番号][パーツ番号]
let preset_saved = Array(number_of_presets).fill(false); // 各プリセットが登録済みかどうか

let recording = false; // trueなら顔領域を動画として録画
let record_start_time = 0; // 録画開始時刻（ms）。経過時間の表示に使う

let exporting_video = false; // 録画終了のデータ確定中は新しい録画を開始しない
let labels = ["R (赤)", "G (緑)", "B (青)"]; // RGBスライダーの表示名
