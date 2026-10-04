// 色・文字サイズ・文字の基準位置を指定して描き、描画設定を元に戻す
void drawText(String value, float x, float y, color text_color, float text_size, int align_x, int align_y) {
  pushStyle(); // 描画設定を保存し、描画後にpopStyle()で戻す
  fill(text_color);
  textSize(text_size);
  textAlign(align_x, align_y);
  text(value, x, y);
  popStyle();
}

// 塗り・枠線・座標基準を指定して四角形を描くradiusは角丸の大きさ
void drawRect(float x, float y, float w, float h, float radius, int mode, color fill_color, color stroke_color, float line_width) {
  pushStyle();
  rectMode(mode); // CORNERは左上基準、CENTERは中心基準
  fill(fill_color);
  if (line_width > 0) stroke(stroke_color); // 線幅が0以下なら枠線を描かない
  else noStroke();
  if (line_width > 0) strokeWeight(line_width);
  rect(x, y, w, h, radius);
  popStyle();
}

// 中央の補助線と線対称時の破線を描く録画中は非表示
void drawGuideLines() {
  if (!showGuide_line || recording) return; // 表示OFFまたは録画中なら何も描かない
  pushStyle();
  strokeWeight(guide_line_width);
  stroke(guide_line_color);
  line(canvas_center_x, canvas_y, canvas_center_x, canvas_y + canvas_height); // 顔領域の中央に縦の実線を描く
  if (symmetry_mode) { // 線対称ONなら、中央線に破線を重ねる
    stroke(symmetry_guide_color);
    strokeWeight(symmetry_guide_width);
    for (int y_line = canvas_y; y_line < canvas_y + canvas_height; y_line += guide_dash_step) {
      line(canvas_center_x, y_line, canvas_center_x, y_line + guide_dash_length);
    }
  }
  popStyle();
}

// idで指定した顔パーツを、設定された位置・角度・大きさ・色で描く
void drawPart(int id) {
  pushStyle(); // 色・線の設定と座標系を保存し、最後に元へ戻す
  pushMatrix();
  translate(transforms[id][transf_x], transforms[id][transf_y]); // パーツの中心を新しい原点(0, 0)にする
  rotate(radians(transforms[id][transf_angle])); // 度をラジアンに変換し、パーツの中心で回転する
  float w = transforms[id][transf_width];
  float h = transforms[id][transf_height];
  boolean eyelid = id >= leftupperEyelid && id <= rightlowerEyelid;
  if (id == leftEyebrow || id == rightEyebrow) {
    stroke(colors[id]);
    strokeWeight(h); // 眉は高さhを線の太さとして使う
    line(-w/2, 0, w/2, 0); // 原点から左右に幅の半分ずつ伸ばして眉を描く
  } else if (id == leftEye || id == rightEye || eyelid) {
    color part_color = eyelid ? colors[get_targetIdx(background)] : colors[id]; // 目は自身の色、瞼は背景色で目の一部を隠す
    int shape = eyelid ? (id <= rightupperEyelid ? upperEyelid_shape : lowerEyelid_shape) : eyelidEllipse_shape; // 目は楕円瞼は上・下それぞれの形状設定を使う
    fill(part_color);
    noStroke();
    if (shape == eyelidEllipse_shape) ellipse(0, 0, w, h);
    else drawRect(0, 0, w, h, 0, CENTER, part_color, black, 0); // 中心基準の四角形角丸なし・枠線なしで描く
  }
  popMatrix();
  popStyle();
}
