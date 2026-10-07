let faceGraphics;

// 起動時に一度だけ、画面・顔専用の描画先・プリセットを準備する。
function setup() {
  pixelDensity(1);
  const canvas = createCanvas(screen_width, screen_height);
  canvas.parent("sketch");
  canvas.elt.setAttribute("tabindex", "0");
  canvas.elt.setAttribute("aria-label", "顔編集パネル。矢印で移動、Q/Eで回転、1〜7でプリセット再生");
  canvas.elt.addEventListener("mousedown", () => canvas.elt.focus({ preventScroll: true }));
  frameRate(screen_fps);
  textFont(japanese_font);
  textSize(default_font_size);
  faceGraphics = createGraphics(canvas_width, canvas_height);
  faceGraphics.pixelDensity(1);
  savePreset(0);
  setupFileInput();
  showMessage("準備完了。パーツを選んで編集してください。");
}

// 毎フレーム、アニメーションを更新して顔と操作パネルを描く。
function draw() {
  updateAnimation();
  background(black);
  drawFaceAndUI();
  drawRecordingMark();
}

// 顔だけを別のキャンバスへ描き、画面では補助線と操作パネルを重ねる。
function drawFaceAndUI() {
  faceGraphics.background(colors[get_targetIdx(backgroundTarget)]);
  for (const id of face_draw_order) drawPart(id, faceGraphics);
  image(faceGraphics, canvas_x, canvas_y);
  drawGuideLines();
  drawUI();
}
