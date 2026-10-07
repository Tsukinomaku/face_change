// 色・文字サイズ・文字の基準位置を指定して描き、描画設定を元に戻す。
function drawText(value, x, y, text_color, text_size, align_x, align_y) {
  push(); // 描画設定を保存し、描画後にpop()で戻す
  noStroke(); // 直前の線の設定を文字へ引き継がない
  fill(text_color);
  textSize(text_size);
  textAlign(align_x, align_y);
  text(value, x, y);
  pop();
}

// 塗り・枠線・座標基準を指定して四角形を描く。radiusは角丸の大きさ。
function drawRect(x, y, w, h, radius, mode, fill_color, stroke_color, line_width) {
  push();
  rectMode(mode); // CORNERは左上基準、CENTERは中心基準
  fill(fill_color);
  if (line_width > 0) stroke(stroke_color); // 線幅が0以下なら枠線を描かない
  else noStroke();
  if (line_width > 0) strokeWeight(line_width);
  rect(x, y, w, h, radius);
  pop();
}

// 中央の補助線と線対称時の破線を描く。録画中は非表示。
function drawGuideLines() {
  if (!showGuide_line || recording) return; // 表示OFFまたは録画中なら何も描かない
  push();
  strokeWeight(guide_line_width);
  stroke(guide_line_color);
  line(canvas_center_x, canvas_y, canvas_center_x, canvas_y + canvas_height); // 顔領域の中央に縦の実線を描く
  if (symmetry_mode) { // 線対称ONなら、中央線に破線を重ねる
    stroke(symmetry_guide_color);
    strokeWeight(symmetry_guide_width);
    for (let y_line = canvas_y; y_line < canvas_y + canvas_height; y_line += guide_dash_step) {
      line(canvas_center_x, y_line, canvas_center_x, y_line + guide_dash_length);
    }
  }
  pop();
}

// idで指定した顔パーツを描く。gは顔専用のp5.Graphics。
function drawPart(id, g) {
  g.push();
  g.translate(transforms[id][transf_x] - canvas_x, transforms[id][transf_y] - canvas_y);
  g.rotate(radians(transforms[id][transf_angle]));
  const w = transforms[id][transf_width];
  const h = transforms[id][transf_height];
  const eyelid = id >= leftupperEyelid && id <= rightlowerEyelid;
  if (id == leftEyebrow || id == rightEyebrow) {
    g.stroke(colors[id]);
    g.strokeWeight(h);
    g.strokeCap(ROUND);
    if (h > 0) g.line(-w / 2, 0, w / 2, 0);
  } else {
    const part_color = eyelid ? colors[get_targetIdx(backgroundTarget)] : colors[id];
    const shape = eyelid ? (id <= rightupperEyelid ? upperEyelid_shape : lowerEyelid_shape) : eyelidEllipse_shape;
    g.fill(part_color);
    g.noStroke();
    g.ellipseMode(CENTER);
    g.rectMode(CENTER);
    if (shape == eyelidEllipse_shape) g.ellipse(0, 0, w, h);
    else g.rect(0, 0, w, h);
  }
  g.pop();
}
