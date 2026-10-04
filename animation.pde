// 開始状態と目標状態の中間値を求め、顔を少しずつ変化させる
void updateAnimation() {
  if (animating) {
    float t = (millis() - anim_start_time) / (float)anim_duration; // 経過時間の割合0が開始、1が完了
    if (t >= 1.0) { // 終了時は目標値を反映し、次のフレームから更新を止める
      t = 1.0;
      animating = false;
    }
    float ease_t = t * t * (3 - 2 * t); // 始めと終わりをゆっくりにする
    for (int i = 0; i < number_of_parts; i++) {
      for (int j = 0; j < trans_index; j++) { // 各パーツのX・Y・角度・幅・高さを更新
        transforms[i][j] = lerp(start_transforms[i][j], target_transforms[i][j], ease_t); // lerp()で開始値と目標値の間の値を求める
      }
      colors[i] = lerpColor(start_colors[i], target_colors[i], ease_t); // lerpColor()で開始色と目標色の間の色を求める
    }
  }
}

// 目標の位置・形・色を設定し、アニメーションを開始する
void start_transition(float[][] next_transforms, color[] next_colors, boolean shortest_rotation) {
  copyValuesInto(transforms, start_transforms); // 現在の位置・形を開始値として保存
  arrayCopy(colors, start_colors); // 現在の色を開始色として保存
  for (int i = 0; i < number_of_parts; i++) {
    boolean move_locked = isMoveLocked(i);
    arrayCopy(move_locked ? transforms[i] : next_transforms[i], target_transforms[i]); // 固定中は現在値、それ以外は指定された値を目標にする
    if (shortest_rotation && !move_locked) { // 最短回転が有効で、移動が固定されていない場合だけ角度を調整
      float delta = normalizeAngle(next_transforms[i][transf_angle] - transforms[i][transf_angle] + 180) - 180; // 角度差を−180度以上180度未満にして、最短の回転量を求める
      target_transforms[i][transf_angle] = transforms[i][transf_angle] + delta;
    }
    target_colors[i] = isColorLocked(i) ? colors[i] : next_colors[i]; // 色の固定中は現在色を保つ
  }
  anim_start_time = millis(); // 開始時刻を記録
  animating = true;
}
