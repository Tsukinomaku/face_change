// 操作パネル、選択ボタン、入力欄、スライダーを描く
void drawUI() {
  pushStyle();
  drawRect(right_panel_x, right_panel_y, right_panel_width, right_panel_height, 0, CORNER, right_panel_color, black, 0); // 右側と下側のパネル背景
  drawRect(under_panel_x, under_panel_y, under_panel_width, under_panel_height, 0, CORNER, under_panel_color, black, 0);
  for (int i = 0; i < uiGrid.length; i++) { // パーツ選択ボタン選択中の対象を別の色で表示
    int t = uiGrid[i];
    if (t == nothing) continue;
    int col = i % target_grid_column;
    int row = i / target_grid_column;
    float button_x = target_button_start_x + col * target_button_step_x;
    float button_y = target_button_start_y + row * target_button_step_y;
    color button_color = targetI_d == t ? selected_button_color : normal_button_color;
    drawRect(button_x, button_y, target_button_width, target_button_height, target_button_radius, CORNER, button_color, black, 0);
    drawText(targetNames[t], button_x + target_button_width / 2, button_y + target_button_height / 2,
             text_color, target_button_text_size, CENTER, CENTER);
  }
  int target_idx = get_targetIdx(targetI_d); // RGB欄：瞼を選んだ場合は背景色を表示する
  int color_idx = target_idx;
  if (target_idx >= leftupperEyelid && target_idx <= rightlowerEyelid) color_idx = number_of_parts - 1; // 瞼の場合は背景色を参照
  for (int i = 0; i < rgb_index; i++) {
    float row_y = rgb_base_y + i * rgb_row_step_y;
    float slider_y = row_y + rgb_slider_y_offset;
    drawText(labels[i], rgb_label_x, row_y + rgb_label_y_offset, text_color, rgb_Label_text_size, LEFT, CENTER);
    drawRect(rgb_slider_x, slider_y, rgb_slider_width, rgb_slider_height, rgb_slider_radius, CORNER, input_background_color, black, 0);
    float channel_value = getColorChannel(colors[color_idx], i);
    float value_width = map(channel_value, rgb_min, rgb_max, 0, rgb_slider_width); // RGB値をスライダーの塗り幅へ変換
    color slider_color = i == rgb_R ? red_slider_color : i == rgb_G ? green_slider_color : blue_slider_color;
    drawRect(rgb_slider_x, slider_y, value_width, rgb_slider_height, rgb_slider_radius, CORNER, slider_color, black, 0);
    drawInputBox(rgb_input_x, row_y + rgb_input_y_offset, rgb_input_width, rgb_input_height, i, String.valueOf((int)channel_value));
  }
  if (target_idx >= leftupperEyelid && target_idx <= rightlowerEyelid) { // 選択対象に応じて注意文を表示
    drawText("※瞼の色は背景色と連動します", warning_text_x, warning_text_y, warning_text_color, warning_text_size, LEFT, BASELINE);
  } else if (target_idx == number_of_parts - 1) {
    drawText("※背景の移動・回転はできません", warning_text_x, warning_text_y, warning_text_color, warning_text_size, LEFT, BASELINE);
  }
  drawText("回転角度", rotation_dial_x, rotation_dial_y + rotation_dial_title_y_offset, text_color, rotation_dial_title_size, CENTER, CENTER); // 回転ダイヤルと角度入力欄
  stroke(ui_stroke_color);
  strokeWeight(rotation_dial_border_width);
  fill(input_background_color);
  ellipse(rotation_dial_x, rotation_dial_y, rotation_dial_radius * 2, rotation_dial_radius * 2);
  float mark_inner_radius = rotation_dial_radius - rotation_dial_mark_length;
  for (int angle = 0; angle < 360; angle += rotation_dial_mark_step) { // 一定角度ごとに目盛りを描く
    line(rotation_dial_x + cos(radians(angle - rotation_dial_angle_offset)) * mark_inner_radius, rotation_dial_y + sin(radians(angle - rotation_dial_angle_offset)) * mark_inner_radius,
         rotation_dial_x + cos(radians(angle - rotation_dial_angle_offset)) * rotation_dial_radius, rotation_dial_y + sin(radians(angle - rotation_dial_angle_offset)) * rotation_dial_radius);
  }
  float current_angle = transforms[target_idx][transf_angle]; // 現在の角度を示す針を描く
  stroke(selected_button_color);
  strokeWeight(rotation_dial_pointer_width);
  line(rotation_dial_x, rotation_dial_y, rotation_dial_x + cos(radians(current_angle - rotation_dial_angle_offset)) * mark_inner_radius, rotation_dial_y + sin(radians(current_angle - rotation_dial_angle_offset)) * mark_inner_radius);
  drawInputBox(rotation_input_x, rotation_input_y, rotation_input_width, rotation_input_height, input_angle, String.valueOf((int)current_angle));
  for (int i = 0; i < coordinate_labels.length; i++) { // X・Y・幅・高さの入力欄
    float input_y = coordinate_base_y + coordinate_row_step_y * i;
    drawText(coordinate_labels[i], coordinate_label_x, input_y + coordinate_label_y_offset, text_color, coordinate_label_text_size, LEFT, CENTER);
    drawInputBox(coordinate_input_x, input_y, coordinate_input_width, coordinate_input_height, coordinate_input_ids[i], String.valueOf((int)transforms[target_idx][coordinate_channels[i]]));
  }
  drawRect(symmetry_check_x, symmetry_check_y, symmetry_check_size, symmetry_check_size, symmetry_check_radius, CORNER, input_background_color, ui_stroke_color, symmetry_check_border_width); // 線対称のチェックボックス
  if (symmetry_mode) {
    stroke(selected_button_color);
    strokeWeight(symmetry_check_line_width);
    line(symmetry_check_x + 3, symmetry_check_y + 10, symmetry_check_x + 8, symmetry_check_y + 15);
    line(symmetry_check_x + 8, symmetry_check_y + 15, symmetry_check_x + 15, symmetry_check_y + 3);
  }
  drawText("両方選択時：線対称", symmetry_text_x, symmetry_text_y, text_color, symmetry_text_size, LEFT, CENTER);
  drawSystemButton(upperEyelid_button_x, eyelid_button_y, eyelid_button_width, eyelid_button_height, upperEyelid_shape == eyelidEllipse_shape ? "上瞼: 楕円" : "上瞼: 四角", eyelid_button_color); // 瞼形状と補助線の切替ボタン
  drawSystemButton(lowerEyelid_button_x, eyelid_button_y, eyelid_button_width, eyelid_button_height, lowerEyelid_shape == eyelidEllipse_shape ? "下瞼: 楕円" : "下瞼: 四角", eyelid_button_color);
  drawSystemButton(guide_button_x, guide_button_y, guide_button_width, guide_button_height, showGuide_line ? "補助線: ON" : "補助線: OFF", guide_button_color);
  drawLockButton(colorLock_button_start_x, colorLock_button_y, colorLock_button_width, colorLock_button_height, "背色", lock_bg_color); // 色固定ボタン
  drawLockButton(colorLock_button_start_x + colorLock_button_step_x, colorLock_button_y, colorLock_button_width, colorLock_button_height, "目色", lockEye_color);
  drawLockButton(colorLock_button_start_x + colorLock_button_step_x * 2, colorLock_button_y, colorLock_button_width, colorLock_button_height, "眉色", lock_brow_color);
  drawLockButton(moveLock_button_start_x, moveLock_button_y, moveLock_button_width, moveLock_button_height, "瞼動", lockLid_move); // 移動固定ボタン
  drawLockButton(moveLock_button_start_x + moveLock_button_step_x, moveLock_button_y, moveLock_button_width, moveLock_button_height, "目動", lockEye_move);
  drawLockButton(moveLock_button_start_x + moveLock_button_step_x * 2, moveLock_button_y, moveLock_button_width, moveLock_button_height, "眉動", lock_brow_move);
  drawText("表情登録　クリックで現在の状態を記録", preset_title_x, preset_title_y, sub_text_color, ui_title_text_size, LEFT, CENTER); // プリセット登録ボタン登録済みと未登録で色を変える
  for (int i = 0; i < number_of_presets; i++) {
    color button_color = preset_saved[i] ? saved_preset_color : empty_preset_color;
    drawSystemButton(preset_button_start_x + i * preset_button_step_x, preset_button_y, preset_button_width, preset_button_height, String.valueOf(i + 1), button_color);
  }
  drawText("アニメーション速度 " + nf(anim_duration / 1000.0, 1, 2) + " 秒", speed_title_x, speed_title_y, sub_text_color, ui_title_text_size, LEFT, CENTER); // アニメーションの所要時間を秒で表示
  drawRect(speed_slider_x, speed_slider_y, speed_slider_width, speed_slider_height, speed_slider_radius, CORNER, input_background_color, ui_stroke_color, speed_slider_border_width);
  float speed_width = map(anim_duration, anim_duration_min, anim_duration_max, 0, speed_slider_width);
  drawRect(speed_slider_x, speed_slider_y, speed_width, speed_slider_height, speed_slider_radius, CORNER, selected_button_color, black, 0);
  drawText("システム", system_title_x, system_title_y, sub_text_color, ui_title_text_size, LEFT, CENTER); // 初期化・保存・読込ボタン
  drawSystemButton(reset_button_x, system_button_y, system_button_width, system_button_height, "初期化", reset_button_color);
  drawSystemButton(save_button_x, system_button_y, system_button_width, system_button_height, "保存", save_button_color);
  drawSystemButton(load_button_x, system_button_y, system_button_width, system_button_height, "読込", load_button_color);
  drawText("動画作成用", video_title_x, video_title_y, text_color, ui_title_text_size, LEFT, CENTER); // 録画と動画化ボタン
  drawSystemButton(record_button_x, record_button_y, record_button_width, record_button_height, recording ? "● 録画停止 (保存中)" : "〇 録画開始 (顔保存)", recording ? recording_button_color : record_button_color);
  drawSystemButton(exportVideo_button_x, exportVideo_button_y, exportVideo_button_width, exportVideo_button_height, "動画化", export_video_button_color);
  drawText("【操作】 矢印/WASD：移動  Q,E：回転  1〜" + number_of_presets + "：アニメーション再生", help_text_x, help_text_y, help_text_color, help_text_size, LEFT, TOP); // キーボード操作の説明
  popStyle();
}

// 数値入力欄を描く選択中は入力文字、それ以外は値valを表示する
void drawInputBox(float x, float y, float w, float h, int id, String val) {
  boolean active = active_text_box == id; // 選択中かどうかで、背景・枠線・表示文字を変える
  color box_color = active ? active_input_color : input_background_color;
  color border_color = active ? active_input_stroke_color : input_stroke_color;
  drawRect(x, y, w, h, input_box_radius, CORNER, box_color, border_color, active ? active_input_border_width : input_border_width);
  drawText(active ? input_text : val, x + w / 2, y + h / 2 + input_text_y_offset, text_color, input_text_size, CENTER, CENTER);
}

// 角丸ボタンを描くマウスが重なると背景を明るくする
void drawSystemButton(float x, float y, float w, float h, String label, color baseColor) {
  color button_color = baseColor;
  if (mouseInside(x, y, w, h)) button_color = color(red(baseColor) + button_hover_brightness, green(baseColor) + button_hover_brightness, blue(baseColor) + button_hover_brightness);
  drawRect(x, y, w, h, system_button_radius, CORNER, button_color, black, 0);
  drawText(label, x + w / 2, y + h / 2 + button_text_y_offset, text_color, system_button_text_size, CENTER, CENTER);
}

// 固定状態lockedに合わせて、ボタンの文字と背景色を選ぶ
void drawLockButton(float x, float y, float w, float h, String label, boolean locked) {
  drawSystemButton(x, y, w, h, label + (locked ? ":固定" : ":変化"), locked ? locked_button_color : unlocked_button_color); // 固定中は「:固定」、それ以外は「:変化」を名前に付ける
}
