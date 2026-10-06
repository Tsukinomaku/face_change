import oscP5.*;
import netP5.*;
import java.io.File;

// 画面サイズを設定する変数で指定するためsettings()を使う
void settings() {
  size(screen_width, screen_height); // 画面の幅と高さを指定
}

// 起動時に一度だけ、描画・プリセット・OSCを準備する
void setup() {
  frameRate(screen_fps);                                  // 1秒あたりの描画回数を指定
  textFont(createFont(japanese_font, default_font_size)); // 日本語を表示するフォントを設定
  savePreset(0);                                          // 起動時の顔をプリセット0に記録
  oscP5 = new OscP5(this, osc_port);                      // 指定ポートでOSCの受信を開始
}

// 毎フレーム、待機中の操作・アニメーション・描画・録画を処理する
void draw() {
  processPendingActions();
  updateAnimation();
  background(black);
  drawFaceAndUI();
  recordFrame();
}

// 保存・読込とOSCの待機列を、上限件数まで順番に処理する
void processPendingActions() {
  Runnable action; // Runnableは、run()で実行できる処理を保持する
  for (int i = 0; i < file_action_process_limit && (action = file_actions.poll()) != null; i++) action.run(); // poll()で先頭の処理を取り出す空なら停止し、残りは次のフレームへ
  OscMessage msg; // OscMessageは、OSCのアドレスと引数を保持する
  for (int i = 0; i < osc_process_limit && (msg = osc_messages.poll()) != null; i++) handleOscMessage(msg);   // OSCも先頭から順に、上限件数まで処理する
}

// 背景、補助線、顔パーツ、操作パネルの順に描く
void drawFaceAndUI() {
  int background_index = get_targetIdx(background); // 操作対象の背景IDを、色配列の添字へ変換
  drawRect(canvas_x, canvas_y, canvas_width, canvas_height, 0, CORNER, colors[background_index], black, 0);
  drawGuideLines();
  for (int id : face_draw_order) drawPart(id); // 目→瞼→眉の順に重ねて描く
  drawUI();
}
