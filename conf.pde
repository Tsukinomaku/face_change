OscP5 oscP5; // OSC受信を管理するオブジェクト

final int nothing = -1;          // 操作対象ID：-1は選択なし両方選択と背景は配列の添字へ変換して使う
final int leftEye = 0;           // 左目
final int rightEye = 1;          // 右目
final int leftEyebrow = 2;       // 左眉
final int rightEyebrow = 3;      // 右眉
final int leftupperEyelid = 4;   // 左上瞼
final int rightupperEyelid = 5;  // 右上瞼
final int leftlowerEyelid = 6;   // 左下瞼
final int rightlowerEyelid = 7;  // 右下瞼
final int bothEyes = 8;          // 両目
final int bothEyebrows = 9;      // 両眉
final int bothupperEyelids = 10; // 両上瞼
final int bothlowerEyelids = 11; // 両下瞼
final int background = 12;       // 背景
final int minI_d = leftEye;      // 最小値
final int maxI_d = background;   // 最大値
int targetI_d = leftEye;         // 起動時の操作対象は左目

final int number_of_parts = 9;   // 配列の要素数；左目～背景用データまでの9個
final int number_of_presets = 7; // プリセットの個数
final int trans_index = 5; // transformsの1パーツ当たりの要素数
final int rgb_index = 3;   // RGB入力欄・JSONの成分数

// 色の成分番号：R=0、G=1、B=2
final int rgb_R = 0; 
final int rgb_G = 1;
final int rgb_B = 2;

// 変形配列の項目番号：X・Y・角度・幅・高さ
final int transf_x = 0; 
final int transf_y = 1;
final int transf_angle = 2;
final int transf_width = 3;
final int transf_height = 4;

// 入力欄の番号：RGBは0〜2、角度は3、X・Y・幅・高さは4〜7
final int input_R = 0;
final int input_G = 1;
final int input_B = 2;
final int input_angle = 3;
final int input_x = 4;
final int input_y = 5;
final int input_width = 6;
final int input_height = 7;
final int input_nothing = -1; // 入力欄を選択していない状態

final int screen_width = 800; // 画面全体の幅
final int screen_height = 880;// 画面全体の高さ
final int screen_fps = 30;    // 1秒あたりの描画・録画枚数

// 顔を描画する領域
final int canvas_x = 0;
final int canvas_y = 0;
final int canvas_width = 600;
final int canvas_height = 700;
final float canvas_center_x = canvas_x + canvas_width / 2.0; // 線対称と補助線の基準

// 右側UIパネル
final int right_panel_x = canvas_x + canvas_width;
final int right_panel_y = canvas_y;
final int right_panel_width = screen_width - canvas_width;
final int right_panel_height = screen_height;

// 下部UIパネル
final int under_panel_x = canvas_x;
final int under_panel_y = canvas_y + canvas_height;
final int under_panel_width = canvas_width;
final int under_panel_height = screen_height - canvas_height;

// フォントと、OSC・ファイル操作の処理上限
final String japanese_font = "Meiryo";
final int default_font_size = 14;
final int osc_port = 12000;               // OSCの受信ポート番号
final int osc_queue_limit = 256;          // OSCメッセージの最大待機数
final int osc_process_limit = 64;         // 1フレームで処理するOSCの最大件数
final int file_action_process_limit = 16; // 1フレームで処理する保存・読込の最大件数

final float move_step = 5;      // キー操作・数値入力；移動キー1回あたりの移動量
final float rotation_step = 3;  // 回転キー1回あたりの角度
final int input_max_length = 8; // 数値入力の最大文字数

// 基本色
final color black = color(0);
final color white = color(255);

// UI表示色
final color right_panel_color = color(30);
final color under_panel_color = color(40);
final color normal_button_color = color(4);
final color selected_button_color = color(100, 200, 100);
final color text_color = white;
final color sub_text_color = color(220);
final color warning_text_color = color(255, 100, 100);
final color input_background_color = color(15);
final color ui_stroke_color = color(100);
final color red_slider_color = color(255, 60, 60);
final color green_slider_color = color(60, 255, 60);
final color blue_slider_color = color(60, 60, 255);
final color guide_line_color = color(150, 150, 150, 100);
final color symmetry_guide_color = color(100, 150, 200, 120);
final color eyelid_button_color = color(80, 80, 100);
final color guide_button_color = color(100, 100, 120);
final color locked_button_color = color(180, 100, 100);
final color unlocked_button_color = color(100, 120, 180);
final color saved_preset_color = color(60, 140, 180);
final color empty_preset_color = color(80);
final color reset_button_color = color(180, 80, 80);
final color save_button_color = color(80, 120, 180);
final color load_button_color = color(80, 160, 100);
final color recording_button_color = color(200, 50, 50);
final color record_button_color = color(80, 120, 80);
final color export_video_button_color = color(150, 100, 180);
final color help_text_color = color(160);
final color active_input_color = color(60, 60, 100);
final color active_input_stroke_color = color(100, 150, 255);
final color input_stroke_color = color(70);
final color recording_mark_color = color(255, 0, 0);

//表示名
final String[] targetNames = {"左目", "右目", "左眉", "右眉", "左上瞼", "右上瞼", "左下瞼", "右下瞼", "両目", "両眉", "両上瞼", "両下瞼", "背景"}; // 操作対象の名前
String[] labels = {"R (赤)", "G (緑)", "B (青)"}; // RGBスライダーの表示名

final int[] uiGrid = { // UIボタンの並び順 3列 × 5行
  leftEye,         bothEyes,         rightEye,
  leftEyebrow,     bothEyebrows,     rightEyebrow,
  leftupperEyelid, bothupperEyelids, rightupperEyelid,
  leftlowerEyelid, bothlowerEyelids, rightlowerEyelid,
  nothing,         background,       nothing
};

// 重なりを保つための顔パーツ描画順
final int[] face_draw_order = { 
  leftEye, rightEye,
  leftupperEyelid, rightupperEyelid,
  leftlowerEyelid, rightlowerEyelid,
  leftEyebrow, rightEyebrow
};

// 共通ボタン・入力欄
final float input_box_radius = 4; 
final float system_button_radius = 4;
final float input_text_y_offset = -2;
final float button_text_y_offset = -2;
final float input_border_width = 1;
final float active_input_border_width = 2;
final float button_hover_brightness = 30;

// 補助線
final float guide_line_width = 1; 
final float symmetry_guide_width = 1.5;
final int guide_dash_step = 10;
final float guide_dash_length = 5;

final color[] default_colors = { // 初期化用の色 [パーツ番号]
  color(100, 150, 255), // 左目
  color(255, 100, 150), // 右目
  white, white, // 左眉・右眉
  black, black, // 左上瞼・右上瞼
  black, black, // 左下瞼・右下瞼
  black               // 背景
};

color[] colors = default_colors.clone(); // 現在の色初期値をコピーし、初期化用配列は変更しない

final float[][] default_transforms = { // 初期値：[パーツ番号][X, Y, 角度, 幅, 高さ]背景データは最後の行
  {200, 300, 0, 80, 140}, // 左目
  {400, 300, 0, 80, 140}, // 右目
  {200, 180, 15, 100, 8}, // 左眉
  {400, 180, -15, 100, 8}, // 右眉
  {200, 230, 0, 200, 200}, // 左上瞼
  {400, 230, 0, 200, 200}, // 右上瞼
  {200, 370, 0, 200, 200}, // 左下瞼
  {400, 370, 0, 200, 200}, // 右下瞼
  {canvas_x, canvas_y, 0, 0, 0} // 背景（移動・回転には使わない）
};

float[][] transforms = copyValues(default_transforms); // 現在の位置・角度・サイズ各行もコピーして初期値と独立させる

// パーツ選択ボタン
final int target_grid_column = 3; 
final float target_button_start_x = right_panel_x + 10;
final float target_button_start_y = 20;
final float target_button_width = 55;
final float target_button_height = 30;
final float target_button_step_x = 60;
final float target_button_step_y = 38;
final float target_button_radius = 5;
final float target_button_text_size = 11;

// RGBスライダー
final float rgb_base_y = 210; 
final float rgb_row_step_y = 45;
final float rgb_label_x = right_panel_x + 15;
final float rgb_label_y_offset = 10;
final float rgb_Label_text_size = 13;
final float rgb_slider_x = right_panel_x + 15;
final float rgb_slider_y_offset = 22;
final float rgb_slider_width = 115;
final float rgb_slider_height = 12;
final float rgb_slider_radius = 6;
final float rgb_input_x = right_panel_x + 140;
final float rgb_input_y_offset = 17;
final float rgb_input_width = 45;
final float rgb_input_height = 22;
final float rgb_min = 0;
final float rgb_max = 255;

// RGBスライダー
final float warning_text_x = right_panel_x + 15;
final float warning_text_y = rgb_base_y + 145;
final float warning_text_size = 11;

// 回転角度ダイヤル
final float rotation_dial_x = right_panel_x + 100; 
final float rotation_dial_y = 425;
final float rotation_dial_radius = 35;
final float rotation_dial_title_y_offset = -48;
final float rotation_dial_title_size = 13;
final int rotation_dial_mark_step = 30;
final float rotation_dial_mark_length = 4;
final float rotation_dial_hit_margin = 10;
final float rotation_dial_angle_offset = 90;
final float rotation_dial_border_width = 2;
final float rotation_dial_pointer_width = 4;
final float rotation_input_x = 678;
final float rotation_input_y = rotation_dial_y + 42;
final float rotation_input_width = 45;
final float rotation_input_height = 22;

// 座標・大きさ入力欄
final String[] coordinate_labels = {"位置 X:", "位置 Y:", "幅 W:", "高さ H:"}; 
final int[] coordinate_input_ids = {input_x, input_y, input_width, input_height};
final int[] coordinate_channels = {transf_x, transf_y, transf_width, transf_height}; // X・Y・幅・高さの入力欄に対応する変形項目
final float coordinate_base_y = 515;
final float coordinate_label_x = right_panel_x + 20;
final float coordinate_input_x = right_panel_x + 75;
final float coordinate_row_step_y = 30;
final float coordinate_label_y_offset = 11;
final float coordinate_input_width = 50;
final float coordinate_input_height = 22;

// 線対称チェックボックス
final float symmetry_check_x = right_panel_x + 20; 
final float symmetry_check_y = 640;
final float symmetry_check_size = 18;
final float symmetry_check_radius = 3;
final float symmetry_check_border_width = 1;
final float symmetry_check_line_width = 3;
final float symmetry_text_x = right_panel_x + 45;
final float symmetry_text_y = symmetry_check_y + 8;
final float symmetry_text_size = 13;

// 瞼形状・補助線ボタン
final float eyelid_button_y = 680; 
final float eyelid_button_width = 90;
final float eyelid_button_height = 28;
final float upperEyelid_button_x = right_panel_x + 10;
final float lowerEyelid_button_x =  right_panel_x + 105;
final float guide_button_x = right_panel_x + 10;
final float guide_button_y = 715;
final float guide_button_width = 185;
final float guide_button_height = 28;

// 色固定ボタン
final float colorLock_button_start_x = right_panel_x + 10; 
final float colorLock_button_y = 750;
final float colorLock_button_width = 58;
final float colorLock_button_height = 28;
final float colorLock_button_step_x = 63;

// 移動固定ボタン
final float moveLock_button_start_x = right_panel_x + 10; 
final float moveLock_button_y = 785;
final float moveLock_button_width = 58;
final float moveLock_button_height = 28;
final float moveLock_button_step_x = 63;

 // 下部パネル：プリセット
final float preset_title_x = under_panel_x + 20;
final float preset_title_y = under_panel_y + 25;
final float preset_button_start_x = under_panel_x + 20;
final float preset_button_y = under_panel_y + 40;
final float preset_button_width = 35;
final float preset_button_height = 30;
final float preset_button_step_x = 40;

// 下部パネル：アニメーション速度
final int anim_duration_min = 100; //所要時間の下限（ms）
final int anim_duration_max = 5000; // 所要時間の上限（ms）
final int anim_duration_default = 1500; // 起動・初期化時の所要時間（ms）
final float speed_title_x = under_panel_x + 20;
final float speed_title_y = under_panel_y + 95;
final float speed_slider_x = under_panel_x + 20;
final float speed_slider_y = under_panel_y + 110;
final float speed_slider_width = 260;
final float speed_slider_height = 15;
final float speed_slider_radius = 6;
final float speed_slider_border_width = 1;

// 下部パネル：システムボタン
final float system_title_x = under_panel_x + 350; 
final float system_title_y = under_panel_y + 25;
final float system_button_y = under_panel_y + 40;
final float system_button_width = 65;
final float system_button_height = 30;
final float reset_button_x = under_panel_x + 350;
final float save_button_x = under_panel_x + 425;
final float load_button_x = under_panel_x + 500;

// 下部パネル：動画作成
final float video_title_x = under_panel_x + 350; 
final float video_title_y = under_panel_y + 95;
final float record_button_x = under_panel_x + 350;
final float record_button_y = under_panel_y + 110;
final float record_button_width = 150;
final float record_button_height = 30;
final float exportVideo_button_x = under_panel_x + 505;
final float exportVideo_button_y = under_panel_y + 110;
final float exportVideo_button_width = 60;
final float exportVideo_button_height = 30;

// 下部パネル：操作説明
final float help_text_x = under_panel_x + 20; 
final float help_text_y = under_panel_y + 155;
final float help_text_size = 11;

final float coordinate_label_text_size = 13; // 共通の文字サイズ
final float input_text_size = 13;
final float system_button_text_size = 12;
final float ui_title_text_size = 12;
final float recording_text_size = 16;

// 録画表示
final float recording_border_margin = 2; 
final float recording_mark_x = canvas_x + 25;
final float recording_mark_y = canvas_y + 25;
final float recording_mark_size = 16;
final float recording_border_width = 4;
final int recording_bright_alpha = 255;
final int recording_dim_alpha = 100;
final float recording_text_x_offset = 15;
final float recording_text_y_offset = -3;

// 録画ファイル・動画書き出し
final String frames_folder_name = "frames"; 
final String video_file_name = "output.mp4";
final String ffmpeg_command = "ffmpeg";
final String frame_file_prefix = "frame-";
final String frame_file_extension = ".png";
final int frame_number_digits = 4;
final String frame_file_pattern = frame_file_prefix + "%0" + frame_number_digits + "d" + frame_file_extension;

// 現在選択している入力欄
int active_text_box = input_nothing; 
String input_text = ""; // 入力中の文字列
boolean symmetry_mode = true; // trueなら両方選択時に左右を線対称にする
final int eyelidEllipse_shape = 0; // 瞼形状の番号：楕円=0、四角=1
final int eyelid_rectangle_shape = 1;
int upperEyelid_shape = eyelidEllipse_shape; // 上瞼の形状
int lowerEyelid_shape = eyelidEllipse_shape; // 下瞼の形状
boolean showGuide_line = true; // trueなら補助線を表示（録画中は非表示）

// 色固定状態trueならプリセット・OSC遷移で現在色を保つ
boolean lock_bg_color = false; 
boolean lockEye_color = false;
boolean lock_brow_color = false;

// 移動固定状態trueならプリセット・OSC遷移で位置・形を保つ
boolean lockLid_move = false; 
boolean lockEye_move = false;
boolean lock_brow_move = false;

float[][] start_transforms = new float[number_of_parts][trans_index]; // アニメーション開始時の位置・形
float[][] target_transforms = new float[number_of_parts][trans_index]; // アニメーションの目標位置・形
color[] start_colors = new color[number_of_parts]; // アニメーション開始時の色
color[] target_colors = new color[number_of_parts]; // アニメーションの目標色
int anim_start_time = 0; // アニメーションを開始した時刻
int anim_duration = anim_duration_default; // 現在のアニメーション所要時間（ms）
boolean animating = false; // trueの間だけアニメーションを更新

float[][][] preset_transforms = new float[number_of_presets][number_of_parts][trans_index]; // プリセット；[プリセット番号][パーツ番号][変形項目]
color[][] preset_colors = new color[number_of_presets][number_of_parts]; // [プリセット番号][パーツ番号]
boolean[] preset_saved = new boolean[number_of_presets]; // 各プリセットが登録済みかどうか

boolean recording = false; // trueなら顔領域を連番画像へ保存
int record_start_time = 0; // 録画開始時刻（ms）経過時間の表示に使う

int record_frame_index = 0; // 録画画像専用の連番
volatile boolean exporting_video = false; // 動画変換中の状態trueなら録画開始と二重書き出しを禁止（別スレッドと共有）
final java.util.concurrent.ConcurrentLinkedQueue<OscMessage> osc_messages = new java.util.concurrent.ConcurrentLinkedQueue<OscMessage>(); // 別スレッドから安全に追加できるOSCの待機列
final java.util.concurrent.ConcurrentLinkedQueue<Runnable> file_actions = new java.util.concurrent.ConcurrentLinkedQueue<Runnable>(); // draw()側で実行する保存・読込処理の待機列
