// 操作対象IDを配列の添字に変換する両方選択時は左側を返す
int get_targetIdx(int st) {
  if (st == bothEyes) return leftEye;
  if (st == bothEyebrows) return leftEyebrow;
  if (st == bothupperEyelids) return leftupperEyelid;
  if (st == bothlowerEyelids) return leftlowerEyelid;
  if (st == background) return number_of_parts - 1; // 背景データは配列の最後（添字8）にある
  return st; // 個別パーツは番号をそのまま使う
}

// 操作するパーツ番号を返す個別なら1個、両方なら2個
int[] targetParts(int target) {
  if (target < minI_d || target > maxI_d) return new int[0]; // 範囲外なら要素数0の配列を返す
  if (target >= bothEyes && target <= bothlowerEyelids) {
    int left = get_targetIdx(target);
    return new int[]{left, left + 1}; // 左右は連続した番号なので、右側は左側+1
  }
  return new int[]{get_targetIdx(target)};
}

// パーツの位置・角度・大きさが固定中かを返すpartは配列番号
boolean isMoveLocked(int part) {
  if (part >= leftupperEyelid && part <= rightlowerEyelid) return lockLid_move;
  if (part == leftEye || part == rightEye) return lockEye_move;
  if (part == leftEyebrow || part == rightEyebrow) return lock_brow_move;
  return false;
}

// パーツの色が固定中かを返すpartは配列番号0〜8
boolean isColorLocked(int part) {
  if (part >= leftupperEyelid) return lock_bg_color; // 瞼は背景色で描くため、背景と同じ固定状態を使う
  if (part == leftEye || part == rightEye) return lockEye_color;
  if (part == leftEyebrow || part == rightEyebrow) return lock_brow_color;
  return false;
}

// NaN（数として定まらない値）と無限大を除き、通常の数値かを調べる
boolean isFiniteValue(float value) {
  return !Float.isNaN(value) && !Float.isInfinite(value);
}

// 同じ向きを保ち、角度を0度以上360度未満にそろえる
float normalizeAngle(float angle) {
  return ((angle % 360) + 360) % 360; // 負の角度も補正する例：−30度→330度、390度→30度
}

// 両方選択中なら、アニメーションを止めて左右を同期する
void sync_targets() {
  if (targetI_d < bothEyes || targetI_d > bothlowerEyelids) return;
  animating = false;
  int left = get_targetIdx(targetI_d);
  syncPair(left, left + 1);
}

// 左側の色と形を、線対称モードに合わせて右側へ反映する
void syncPair(int left, int right) {
  colors[right] = colors[left]; // 左右を同じ色にする
  for (int channel = 0; channel < trans_index; channel++) applySym(right, channel, transforms[left][channel]); // 位置・角度・大きさを右側へ反映
}

// 指定した配列のパーツを移動・回転するdx・dyは移動量、daは回転量
void moveParts(float[][] data, int target, float dx, float dy, float da) {
  if (target == background) return; // 背景の移動・回転は行わない
  boolean paired = target >= bothEyes && target <= bothlowerEyelids;
  for (int id : targetParts(target)) {
    boolean mirrored = paired && symmetry_mode && id % 2 == 1; // 両方選択かつ線対称ONなら、右側（奇数番号）の向きを反転
    data[id][transf_x] += mirrored ? -dx : dx;
    data[id][transf_y] += dy;
    data[id][transf_angle] += mirrored ? -da : da; // 角度を丸めず、指定した回転方向と回転量を保つ
  }
}

// アニメーションを止め、選択中のパーツを直接移動・回転する
void move_target(float dx, float dy, float da) {
  if (targetI_d == background) return;
  animating = false;
  moveParts(transforms, targetI_d, dx, dy, da);
}

// colorから、指定したR・G・Bの成分を取り出す
float getColorChannel(color value, int channel) {
  if (channel == rgb_R) return red(value);
  if (channel == rgb_G) return green(value);
  if (channel == rgb_B) return blue(value);
  throw new IllegalArgumentException("RGB成分の番号が不正です");
}

// 他の成分を保ち、指定したRGB成分だけを変更した色を返す
color withColorChannel(color current, int channel, float value) {
  if (channel == rgb_R) return color(value, green(current), blue(current));
  if (channel == rgb_G) return color(red(current), value, blue(current));
  if (channel == rgb_B) return color(red(current), green(current), value);
  throw new IllegalArgumentException("RGB成分の番号が不正です");
}

// 選択中のパーツのRGB成分を変更する瞼の場合は背景色を変更する
void applyColorValue(int channel, float val) {
  if (channel < 0 || channel >= rgb_index || !isFiniteValue(val)) return;
  animating = false;
  val = constrain(val, rgb_min, rgb_max); // RGB値を0〜255に収める
  int idx = get_targetIdx(targetI_d);
  if (idx >= leftupperEyelid && idx <= rightlowerEyelid) {
    int background_idx = get_targetIdx(background); // 瞼を選択した場合は、描画に使う背景色を更新する
    colors[background_idx] = withColorChannel(colors[background_idx], channel, val);
    return;
  }
  for (int id : targetParts(targetI_d)) colors[id] = withColorChannel(colors[id], channel, val);
}

// 選択中の位置・角度・大きさを変更し、両方選択時は右側も更新する
void apply_transformValue(int channel, float val) {
  if (targetI_d == background || channel < 0 || channel >= trans_index || !isFiniteValue(val)) return;
  animating = false;
  if (channel == transf_width || channel == transf_height) val = max(0, val); // 幅と高さは負の値にしない
  int[] ids = targetParts(targetI_d);
  if (ids.length == 0) return;
  transforms[ids[0]][channel] = val; // 代表となる左側、または個別パーツを更新
  if (ids.length == 2) applySym(ids[1], channel, val); // 両方選択時は右側も同期する
}

// 左側の値valを右側へ反映する線対称ONならX座標と角度を反転する
void applySym(int right, int channel, float val) {
  if (channel == transf_x) transforms[right][channel] = symmetry_mode ? 2 * canvas_center_x - val : val; // X座標は中心を挟んで反転中心300、左200なら右400
  else if (channel == transf_angle) transforms[right][channel] = symmetry_mode ? -val : val; // 角度は符号を反転左15度なら右−15度
  else transforms[right][channel] = val; // Y座標・幅・高さは左右で同じ値線対称OFFなら全項目を同じ値にする
}

// 2次元配列を行ごとにコピーし、元の配列と独立した新しい配列を返す
float[][] copyValues(float[][] source) {
  float[][] result = new float[source.length][]; // 行数だけ用意する各行の配列は次のループで作る
  for (int i = 0; i < source.length; i++) result[i] = source[i].clone(); // 各行もコピーするので、コピー先の変更は元に影響しない
  return result;
}

// 2次元配列sourceの中身を、用意済みのdestinationへ行ごとにコピーする
void copyValuesInto(float[][] source, float[][] destination) {
  for (int i = 0; i < source.length; i++) arrayCopy(source[i], destination[i]);
}

// 現在の位置・形・色を、指定番号のプリセット配列に記録する
void savePreset(int presetIdx) {
  if (presetIdx < 0 || presetIdx >= number_of_presets) return; // プリセット番号は0から始まる範囲外なら終了
  copyValuesInto(transforms, preset_transforms[presetIdx]); // 現在の位置・形を記録
  arrayCopy(colors, preset_colors[presetIdx]); // 現在の色を記録
  preset_saved[presetIdx] = true; // 登録済みとして扱うファイルへの保存は行わない
}

// 顔と操作設定をその場で初期値に戻す登録済みプリセットは残す
void reset_toDefault() {
  animating = false;
  input_text = "";
  copyValuesInto(default_transforms, transforms); // 位置・角度・幅・高さと色を初期値へ戻す
  arrayCopy(default_colors, colors);
  symmetry_mode = true; // 線対称と補助線をONにし、瞼を楕円に戻す
  upperEyelid_shape = lowerEyelid_shape = eyelidEllipse_shape;
  showGuide_line = true;
  lock_bg_color = lockEye_color = lock_brow_color = false; // 色と移動の固定をすべて解除
  lockLid_move = lockEye_move = lock_brow_move = false;
  anim_duration = anim_duration_default;
  targetI_d = leftEye; // 左目を選択し、入力欄の選択を解除
  active_text_box = input_nothing;
}
