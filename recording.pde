// 録画中の顔領域を連番画像に保存し、録画マークと経過時間を描く
void recordFrame() {
  if (recording) {
    PImage frameImg = get(canvas_x, canvas_y, canvas_width, canvas_height); // 顔領域だけを取得する録画マークは保存画像に含めない
    File framesDir = new File(sketchPath(), frames_folder_name);
    File frameFile = new File( framesDir, String.format(java.util.Locale.ROOT, frame_file_pattern, record_frame_index) ); // 設定した桁数で画像名を作る例：frame-0000.png
    frameImg.save(frameFile.getAbsolutePath());
    record_frame_index++;

    pushStyle(); // 画像保存後に、画面だけへ録画中の表示を重ねる
    boolean recording_blink = frameCount % screen_fps < screen_fps / 2; // 1秒の前半と後半で表示の透明度を切り替える
    int recording_alpha = recording_blink ? recording_bright_alpha : recording_dim_alpha;
    noFill();
    stroke(recording_mark_color, recording_alpha);
    strokeWeight(recording_border_width);
    rect(canvas_x + recording_border_margin, canvas_y + recording_border_margin, canvas_width - recording_border_margin * 2, canvas_height - recording_border_margin * 2);
    fill(recording_mark_color, recording_alpha);
    noStroke();
    ellipse(recording_mark_x, recording_mark_y, recording_mark_size, recording_mark_size);
    int elapsed_ms = millis() - record_start_time;
    int total_sec = elapsed_ms / 1000; // 経過ミリ秒を分・秒に変換する
    int minute = total_sec / 60;
    int second = total_sec % 60;
    String time_str = nf(minute, 2) + ":" + nf(second, 2);
    drawText("REC " + time_str, recording_mark_x + recording_text_x_offset, recording_mark_y + recording_text_y_offset, text_color, recording_text_size, LEFT, CENTER);
    popStyle();
  }
}

// 録画フォルダを用意し、前回の連番画像を削除する
boolean prepareRecordingFolder() {
  File frames_dir = new File(sketchPath(), frames_folder_name);
  if (!frames_dir.exists() && !frames_dir.mkdirs()) { // フォルダがなければ作成し、作成できなければ中止
    println("エラーframesフォルダを作成できませんでした: " + frames_dir.getAbsolutePath());
    return false;
  }
  if (!frames_dir.isDirectory()) return false;

  File[] files = frames_dir.listFiles();
  if (files == null) {
    println("エラーframesフォルダを読み取れません");
    return false;
  }
  for (File file : files) {
    String name = file.getName();
    if (name.startsWith(frame_file_prefix) && name.endsWith(frame_file_extension)) { // 指定の接頭辞・拡張子に一致する画像だけ削除する
      if (!file.delete()) {
        println("エラー古いフレームを削除できませんでした: " + file.getAbsolutePath());
        return false;
      }
    }
  }
  return true;
}

// FFmpegで連番画像を動画に変換し、別スレッドで終了とログを確認する
void exportVideo() {
  if (exporting_video) { // 動画変換の二重実行を防ぐ
    println("動画化はすでに実行中です");
    return;
  }
  println("----------------------------------------");
  println("動画の書き出しを開始します...");

  if (recording) { // 録画を止めて、変換中に画像が追加されないようにする
    recording = false;
    println("録画を停止してから動画化します保存フレーム数: " + record_frame_index);
  }
  String sketch_folder = sketchPath();
  File frames_dir = new File(sketch_folder, frames_folder_name);
  File first_frame = new File(frames_dir, String.format(java.util.Locale.ROOT, frame_file_pattern, 0));
  if (!first_frame.exists()) { // 先頭の録画画像がなければ変換しない
    println("エラー録画画像が見つかりません");
    println("先に録画を開始し、停止してから動画化してください");
    println("確認先: " + first_frame.getAbsolutePath());
    println("----------------------------------------");
    return;
  }
  String input_pattern = new File(frames_dir, frame_file_pattern).getAbsolutePath();
  final String output_path =
    new File(sketch_folder, video_file_name).getAbsolutePath();
  String[] cmd = {ffmpeg_command, "-y", "-framerate", str(screen_fps), "-start_number", "0", "-i", input_pattern, // FFmpegの引数連番画像を指定FPSのH.264動画へ変換する
    "-c:v", "libx264", "-pix_fmt", "yuv420p", output_path};
  try {
    ProcessBuilder pb = new ProcessBuilder(cmd);
    pb.directory( new File(sketch_folder) );
    pb.redirectErrorStream(true); // 標準出力とエラー出力をまとめてログにする
    final Process p = pb.start();
    exporting_video = true;
    println("動画化処理中...");
    println("入力: " + input_pattern);
    println("出力: " + output_path);
    new Thread(new Runnable() { // ログ読取と終了待ちは別スレッドに任せ、描画を止めない
      public void run() {
        try (java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.InputStreamReader(p.getInputStream()))) {
          String line;
          while ((line = reader.readLine()) != null) println("FFmpegログ: " + line);
          int exit_code = p.waitFor(); // FFmpegの終了を待つ終了コード0なら成功
          if (exit_code == 0) println("★動画化に成功しました: " + output_path);
          else println("エラー動画化に失敗しました(Exit Code: " + exit_code + ")");
        }
        catch (Exception e) {
          p.destroy();
          e.printStackTrace();
        }
        finally {
          exporting_video = false; // 終了・失敗後に変換中の状態を解除する
        }
      }
    }
    , "video-export").start();
  }
  catch (Exception e) {
    exporting_video = false; // 終了・失敗後に変換中の状態を解除する
    e.printStackTrace();
  }
}
