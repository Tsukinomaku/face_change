// マウスが指定した長方形の内側にあるか調べる。境界上は含めない。
function mouseInside(x, y, w, h) {
  return mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h;
}

// クリックしたボタンや入力欄を調べ、対応する設定を変更する。
function mousePressed() {
  for (let i = 0; i < uiGrid.length; i++) { // パーツ選択ボタン：番号から列と行を求め、クリック位置を調べる
    let t = uiGrid[i];
    if (t == nothing) continue;
    let col = i % target_grid_column;
    let row = Math.floor(i / target_grid_column);
    let button_x = target_button_start_x + col * target_button_step_x;
    let button_y = target_button_start_y + row * target_button_step_y;
    if (mouseInside(button_x, button_y, target_button_width, target_button_height)) {
      targetI_d = t;
      sync_targets();
      break;
    }
  }

  if (mouseInside(symmetry_check_x, symmetry_check_y, symmetry_check_size, symmetry_check_size)) { // 線対称を切り替え、両方選択中の左右をそろえる
    symmetry_mode = !symmetry_mode;
    sync_targets();
  }

  if (mouseInside(upperEyelid_button_x, eyelid_button_y, eyelid_button_width, eyelid_button_height)) upperEyelid_shape = upperEyelid_shape == eyelidEllipse_shape ? eyelid_rectangle_shape : eyelidEllipse_shape; // 上下の瞼の形と、補助線の表示を切り替える

  if (mouseInside(lowerEyelid_button_x, eyelid_button_y, eyelid_button_width, eyelid_button_height)) lowerEyelid_shape = lowerEyelid_shape == eyelidEllipse_shape ? eyelid_rectangle_shape : eyelidEllipse_shape;

  if (mouseInside(guide_button_x, guide_button_y, guide_button_width, guide_button_height)) showGuide_line = !showGuide_line;

  if (mouseInside(colorLock_button_start_x, colorLock_button_y, colorLock_button_width, colorLock_button_height)) lock_bg_color = !lock_bg_color; // 色固定のON/OFF。プリセットの遷移に適用する
  if (mouseInside(colorLock_button_start_x + colorLock_button_step_x, colorLock_button_y, colorLock_button_width, colorLock_button_height)) lockEye_color = !lockEye_color;
  if (mouseInside(colorLock_button_start_x + colorLock_button_step_x * 2, colorLock_button_y, colorLock_button_width, colorLock_button_height)) lock_brow_color = !lock_brow_color;

  if (mouseInside(moveLock_button_start_x, moveLock_button_y, moveLock_button_width, moveLock_button_height)) lockLid_move = !lockLid_move; // 移動固定のON/OFF。手動の編集は引き続き可能
  if (mouseInside(moveLock_button_start_x + moveLock_button_step_x, moveLock_button_y, moveLock_button_width, moveLock_button_height)) lockEye_move = !lockEye_move;
  if (mouseInside(moveLock_button_start_x + moveLock_button_step_x * 2, moveLock_button_y, moveLock_button_width, moveLock_button_height)) lock_brow_move = !lock_brow_move;

  if (mouseInside(reset_button_x, system_button_y, system_button_width, system_button_height)) reset_toDefault(); // 初期化・JSON保存・JSON読込のボタン

  if (mouseInside(save_button_x, system_button_y, system_button_width, system_button_height)) saveSettings();

  if (mouseInside(load_button_x, system_button_y, system_button_width, system_button_height)) loadSettings();

  for (let i = 0; i < number_of_presets; i++) { // クリックした番号へ現在の顔を登録する
    let button_x = preset_button_start_x + i * preset_button_step_x;
    if (mouseInside(button_x, preset_button_y, preset_button_width, preset_button_height)) {
      savePreset(i);
      break;
    }
  }

  if (mouseInside(record_button_x, record_button_y, record_button_width, record_button_height)) toggleRecording();
  if (mouseInside(exportVideo_button_x, exportVideo_button_y, exportVideo_button_width, exportVideo_button_height)) exportVideo();

  active_text_box = input_nothing; // 入力欄の選択を解除し、クリックした欄を選び直す

  for (let i = 0; i < rgb_index; i++) { // RGBの入力欄を判定
    let input_y = rgb_base_y + i * rgb_row_step_y + rgb_input_y_offset;
    if (mouseInside(rgb_input_x, input_y, rgb_input_width, rgb_input_height)) {
      active_text_box = i; // クリックしたRGB欄を選択
      break;
    }
  }

  if (mouseInside(rotation_input_x, rotation_input_y, rotation_input_width, rotation_input_height)) active_text_box = input_angle; // 回転角度の入力欄を判定

  for (let i = 0; i < coordinate_input_ids.length; i++) { // X・Y・幅・高さの入力欄を、描画と同じ順で判定
    let input_y = coordinate_base_y + coordinate_row_step_y * i;
    if (mouseInside(coordinate_input_x, input_y, coordinate_input_width, coordinate_input_height)) {
      active_text_box = coordinate_input_ids[i]; // クリックした位置・サイズ欄を選択
      break;
    }
  }
  if (active_text_box != input_nothing) input_text = "";
  if (active_text_box == input_nothing) updateSlidersAndDial();
}

// ドラッグ中にスライダーと回転ダイヤルを更新する。
function mouseDragged() {
  if (active_text_box == input_nothing) updateSlidersAndDial();
}

// マウス位置から、RGB値・回転角度・アニメーション時間を求める。
function updateSlidersAndDial() {

  for (let i = 0; i < rgb_index; i++) { // RGB：スライダー上のマウス位置を0〜255へ変換
    let slider_y = rgb_base_y + i * rgb_row_step_y + rgb_slider_y_offset;
    if (mouseInside(rgb_slider_x, slider_y, rgb_slider_width, rgb_slider_height)) {
      let val = map(mouseX, rgb_slider_x, rgb_slider_x + rgb_slider_width, rgb_min, rgb_max);
      applyColorValue(i, val);
    }
  }

  if (dist(mouseX, mouseY, rotation_dial_x, rotation_dial_y) < rotation_dial_radius + rotation_dial_hit_margin) { // 回転：中心からマウスへの方向を角度に変換
    let angle = normalizeAngle(degrees(atan2(mouseY - rotation_dial_y, mouseX - rotation_dial_x)) + rotation_dial_angle_offset);
    apply_transformValue(transf_angle, angle);
  }

  if (mouseInside(speed_slider_x, speed_slider_y, speed_slider_width, speed_slider_height)) { // 速度：マウス位置をアニメーションの所要時間へ変換
    anim_duration = Math.trunc(map(mouseX, speed_slider_x, speed_slider_x + speed_slider_width, anim_duration_min, anim_duration_max));
  }
}


// 入力欄を編集するか、選択中のパーツをキーで移動・回転する。
function keyPressed(event) {
  if (!event || event.ctrlKey || event.metaKey || event.altKey) return;
  const tag = document.activeElement?.tagName;
  if (tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT") return;
  const pressed = event.key;
  if (active_text_box != input_nothing) {
    const signed = active_text_box == input_angle || active_text_box == input_x || active_text_box == input_y;
    const digit = /^[0-9]$/.test(pressed);
    const minus = pressed == "-" && input_text.length == 0 && signed;
    const decimal = pressed == "." && !input_text.includes(".");
    if ((digit || minus || decimal) && input_text.length < input_max_length) {
      input_text += pressed;
      applyBoxValue();
    } else if (pressed == "Backspace") {
      input_text = input_text.slice(0, -1);
      applyBoxValue();
    } else if (pressed == "Enter" || pressed == "Escape") {
      active_text_box = input_nothing;
    }
    return false; // 矢印スクロールやBackspaceのブラウザ動作を抑える
  }
  const input_key = pressed.toLowerCase();
  if (pressed == "ArrowUp" || input_key == "w") move_target(0, -move_step, 0);
  else if (pressed == "ArrowDown" || input_key == "s") move_target(0, move_step, 0);
  else if (pressed == "ArrowLeft" || input_key == "a") move_target(-move_step, 0, 0);
  else if (pressed == "ArrowRight" || input_key == "d") move_target(move_step, 0, 0);
  else if (input_key == "q") move_target(0, 0, -rotation_step);
  else if (input_key == "e") move_target(0, 0, rotation_step);
  else if (/^[1-7]$/.test(pressed)) {
    const preset_idx = Number(pressed) - 1;
    if (preset_saved[preset_idx]) start_transition(preset_transforms[preset_idx], preset_colors[preset_idx], true);
    else showMessage(`プリセット${pressed}は未登録です。下の番号ボタンで登録できます。`);
  } else return;
  return false;
}

// 入力途中の空文字・負号・小数点だけは無視し、有効な数値を反映する。
function applyBoxValue() {
  if (["", "-", ".", "-."].includes(input_text)) return;
  const val = Number(input_text);
  if (!Number.isFinite(val)) return;
  if (active_text_box >= input_R && active_text_box <= input_B) applyColorValue(active_text_box, val);
  else if (active_text_box == input_angle) apply_transformValue(transf_angle, val);
  else if (active_text_box >= input_x && active_text_box <= input_height) apply_transformValue(coordinate_channels[active_text_box - input_x], val);
}
