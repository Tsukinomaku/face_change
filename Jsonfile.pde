// 保存先を選ぶ画面を開く選択後にsaveCallback()が呼ばれる
void saveSettings() {
  selectOutput("保存先 (*.json)", "saveCallback");
}

// 現在の顔と操作設定を、選択されたJSONファイルへ保存する
void saveSelectedSettings(File selection) {
  if (selection == null) return; // ファイル選択がキャンセルされた場合は終了
  JSONObject json = new JSONObject();
  JSONArray colors_array = new JSONArray();
  JSONArray transforms_array = new JSONArray();
  for (int i = 0; i < number_of_parts; i++) { // パーツごとに、色と位置・角度・大きさを保存用配列へ入れる
    JSONArray color_data = new JSONArray();
    JSONArray transform_data = new JSONArray();
    color_data.setFloat(rgb_R, red(colors[i])); // 色を[R, G, B]の配列として保存する
    color_data.setFloat(rgb_G, green(colors[i]));
    color_data.setFloat(rgb_B, blue(colors[i]));
    for (int j = 0; j < trans_index; j++) {
      transform_data.setFloat(j, transforms[i][j]);
    }
    colors_array.setJSONArray(i, color_data);
    transforms_array.setJSONArray(i, transform_data);
  }
  json.setJSONArray("colors", colors_array);
  json.setJSONArray("transforms", transforms_array);
  json.setBoolean("symmetry", symmetry_mode); 
  json.setInt("upperEyelid_shape", upperEyelid_shape);
  json.setInt("lowerEyelid_shape", lowerEyelid_shape);
  json.setBoolean("showGuide_line", showGuide_line);
  json.setBoolean("lockBgColor", lock_bg_color);
  json.setBoolean("lockEyeColor", lockEye_color);
  json.setBoolean("lockBrowColor", lock_brow_color);
  json.setBoolean("lockLidMove", lockLid_move);
  json.setBoolean("lockEyeMove", lockEye_move);
  json.setBoolean("lockBrowMove", lock_brow_move);
  json.setInt("animDuration", anim_duration);
  String path = selection.getAbsolutePath();
  if (!path.toLowerCase(java.util.Locale.ROOT).endsWith(".json")) path += ".json";
  saveJSONObject(json, path);
  println("データを保存しました: " + path);
}

// 読込ファイルを選ぶ画面を開く選択後にloadCallback()が呼ばれる
void loadSettings() {
  selectInput("読み込み (*.json)", "loadCallback");
}

// 保存処理を待機列に入れ、draw()側で実行できるようにする
void saveCallback(final File selection) {
  if (selection == null) return; // キャンセル時は処理を登録しない
  file_actions.add(new Runnable() { // run()の中身は、待機列から取り出されたときに実行される
    public void run() {
      try {
        saveSelectedSettings(selection);
      }
      catch (Exception e) {
        println("保存に失敗しました: " + e.getMessage());
      }
    }
  }
  );
}

// 読込処理を待機列に入れ、draw()側で実行できるようにする
void loadCallback(final File selection) {
  if (selection == null) return; // キャンセル時は処理を登録しない
  file_actions.add(new Runnable() { // 別スレッドから直接状態を変えず、draw()側で読み込む
    public void run() {
      loadSelectedSettings(selection);
    }
  }
  );
}

// JSONの色と位置・形を検査し、準備したコピー先へ読み込む
void readFaceData(JSONObject json, float[][] next_transforms, color[] next_colors) {
  if (json == null) throw new IllegalArgumentException("JSONを読み込めませんでした");
  readColors(json.getJSONArray("colors"), next_colors);
  readMatrix(json.getJSONArray("transforms"), next_transforms);
}

// 全パーツのRGB配列を検査し、colorへ変換する
void readColors(JSONArray array, color[] destination) {
  if (array == null) throw new IllegalArgumentException("colors が必要です");
  if (array.size() != destination.length) throw new IllegalArgumentException("色のパーツ数が不正です"); // 現在の保存形式では、全パーツのデータが必要
  for (int i = 0; i < destination.length; i++) {
    JSONArray row = array.getJSONArray(i);
    if (row == null || row.size() != rgb_index) throw new IllegalArgumentException("RGBは3成分必要です: " + i);
    color next_color = black;
    for (int channel = 0; channel < rgb_index; channel++) {
      float value = row.getFloat(channel); // 数値を検査し、RGBの範囲内へ補正する
      if (!isFiniteValue(value)) throw new IllegalArgumentException("有限の数値を指定してください");
      next_color = withColorChannel(next_color, channel, constrain(value, rgb_min, rgb_max));
    }
    destination[i] = next_color;
  }
}

// 全パーツの位置・角度・大きさを検査して読み込む
void readMatrix(JSONArray array, float[][] destination) {
  if (array == null) throw new IllegalArgumentException("transforms が必要です");
  if (array.size() != destination.length) throw new IllegalArgumentException("位置・形のパーツ数が不正です");
  for (int i = 0; i < destination.length; i++) {
    JSONArray row = array.getJSONArray(i);
    if (row == null || row.size() != destination[i].length) throw new IllegalArgumentException("位置・角度・幅・高さの項目数が不正です: " + i);
    for (int j = 0; j < destination[i].length; j++) {
      float value = row.getFloat(j);
      if (!isFiniteValue(value)) throw new IllegalArgumentException("有限の数値を指定してください");
      if (j == transf_width || j == transf_height) value = max(0, value); // 幅・高さは0以上にする
      destination[i][j] = value;
    }
  }
}

// 瞼形状が楕円か四角かを確認し、不正な番号ならエラーにする
int validEyelidShape(int shape) {
  if (shape != eyelidEllipse_shape && shape != eyelid_rectangle_shape) throw new IllegalArgumentException("瞼形状は0か1です");
  return shape;
}

// JSONをすべて検査してから、顔と操作設定をまとめて反映する
void loadSelectedSettings(File selection) {
  try {
    JSONObject json = loadJSONObject(selection.getAbsolutePath());
    float[][] next_transforms = new float[number_of_parts][trans_index]; // 検査用の配列へ読み込み、成功するまで現在の状態を変えない
    color[] next_colors = new color[number_of_parts];
    readFaceData(json, next_transforms, next_colors);
    boolean next_symmetry = json.getBoolean("symmetry"); // 現在の保存形式に含まれる操作設定をすべて読み込む
    int next_upper = validEyelidShape(json.getInt("upperEyelid_shape"));
    int next_lower = validEyelidShape(json.getInt("lowerEyelid_shape"));
    boolean next_guide = json.getBoolean("showGuide_line");
    boolean next_bg_lock = json.getBoolean("lockBgColor");
    boolean next_eye_lock = json.getBoolean("lockEyeColor");
    boolean next_brow_lock = json.getBoolean("lockBrowColor");
    boolean next_lid_move = json.getBoolean("lockLidMove");
    boolean next_eye_move = json.getBoolean("lockEyeMove");
    boolean next_brow_move = json.getBoolean("lockBrowMove");
    int next_duration = constrain(json.getInt("animDuration"), anim_duration_min, anim_duration_max);

    animating = false; // すべての検査が成功した後で、現在の状態へまとめて反映
    copyValuesInto(next_transforms, transforms);
    arrayCopy(next_colors, colors);
    symmetry_mode = next_symmetry;
    upperEyelid_shape = next_upper;
    lowerEyelid_shape = next_lower;
    showGuide_line = next_guide;
    lock_bg_color = next_bg_lock;
    lockEye_color = next_eye_lock;
    lock_brow_color = next_brow_lock;
    lockLid_move = next_lid_move;
    lockEye_move = next_eye_move;
    lock_brow_move = next_brow_move;
    anim_duration = next_duration;
    active_text_box = input_nothing;
    input_text = "";
    println("データを読み込みました: " + selection.getAbsolutePath());
  }
  catch (Exception e) {
    println("読込に失敗しました（現在の設定を維持）: " + e.getMessage());
  }
}

// JSONの顔データを目標にして、アニメーションを開始する
void loadAndTransitionFromJson(String path) {
  try {
    JSONObject json = loadJSONObject(path);
    float[][] next_transforms = new float[number_of_parts][trans_index]; // 顔データを読み込む線対称・固定などの設定は変更しない
    color[] next_colors = new color[number_of_parts];
    readFaceData(json, next_transforms, next_colors);
    start_transition(next_transforms, next_colors, true); // 最短回転を使って遷移を開始固定状態もここで適用する
    println("OSC経由で読み込みました: " + path);
  }
  catch (Exception e) {
    println("JSON遷移に失敗しました: " + e.getMessage());
  }
}
