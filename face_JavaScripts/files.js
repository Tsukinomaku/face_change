// 現在の顔・操作設定を、Processing版と同じキー名のJSONへ変換する。
function currentSettings() {
  return {
    colors: colors.map(value => value.slice(0, 3)),
    transforms: copyValues(transforms),
    symmetry: symmetry_mode,
    upperEyelid_shape,
    lowerEyelid_shape,
    showGuide_line,
    lockBgColor: lock_bg_color,
    lockEyeColor: lockEye_color,
    lockBrowColor: lock_brow_color,
    lockLidMove: lockLid_move,
    lockEyeMove: lockEye_move,
    lockBrowMove: lock_brow_move,
    animDuration: anim_duration
  };
}

// 現在の設定をJSONとしてダウンロードする。プリセット登録は含めない。
function saveSettings() {
  const blob = new Blob([JSON.stringify(currentSettings(), null, 2)], { type: "application/json" });
  downloadBlob(blob, "face-settings.json");
  showMessage("現在の設定をface-settings.jsonへ保存しました。");
}

// ファイル選択後にJSONを検査し、成功したときだけ設定を反映する。
function setupFileInput() {
  const input = document.getElementById("settings-file");
  input.addEventListener("change", async () => {
    const file = input.files[0];
    if (!file) return;
    try {
      if (file.size > 1024 * 1024) throw new Error("JSONは1MB以下のファイルを選んでください。");
      const json = JSON.parse((await file.text()).replace(/^\uFEFF/, ""));
      loadSelectedSettings(json);
      showMessage(`読み込みました: ${file.name}`);
    } catch (error) {
      showMessage(`読込失敗（現在の設定を維持）: ${error.message}`, true);
    } finally {
      input.value = ""; // 同じファイルの選び直しにも反応する
    }
  });
}

// ブラウザのファイル選択画面を開く。
function loadSettings() {
  document.getElementById("settings-file").click();
}

// 指定の行列を、数値の型・行数・列数まで確認してコピーする。
function readMatrix(array, rows, columns, label) {
  if (!Array.isArray(array) || array.length != rows) throw new Error(`${label}のパーツ数が不正です。`);
  return array.map((row, index) => {
    if (!Array.isArray(row) || row.length != columns) throw new Error(`${label}の項目数が不正です: ${index}`);
    return row.map(value => {
      if (typeof value != "number" || !Number.isFinite(value)) throw new Error(`${label}には有限の数値が必要です。`);
      return value;
    });
  });
}

// 顔の位置・サイズ・色を確認する。元のJSONオブジェクトは変更しない。
function readFaceData(json) {
  if (!json || typeof json != "object") throw new Error("JSONオブジェクトが必要です。");
  const next_transforms = readMatrix(json.transforms, number_of_parts, trans_index, "transforms");
  const next_colors = readMatrix(json.colors, number_of_parts, rgb_index, "colors");
  for (const row of next_transforms) {
    row[transf_width] = Math.max(0, row[transf_width]);
    row[transf_height] = Math.max(0, row[transf_height]);
  }
  for (const row of next_colors) {
    for (let channel = 0; channel < rgb_index; channel++) row[channel] = Math.round(Math.max(0, Math.min(255, row[channel])));
    row.push(255);
  }
  return { next_transforms, next_colors };
}

// boolean項目が欠けている場合や、文字列など別の型ならエラーにする。
function readBoolean(json, name) {
  if (typeof json[name] != "boolean") throw new Error(`${name}はtrueかfalseが必要です。`);
  return json[name];
}

// 瞼形状が、楕円0または四角1か確認する。
function validEyelidShape(shape) {
  if (shape !== eyelidEllipse_shape && shape !== eyelid_rectangle_shape) throw new Error("瞼形状は0か1です。");
  return shape;
}

// 全項目を確認した後で、顔と設定をまとめて反映する。
function loadSelectedSettings(json) {
  const { next_transforms, next_colors } = readFaceData(json);
  const next = {
    symmetry: readBoolean(json, "symmetry"),
    upper: validEyelidShape(json.upperEyelid_shape),
    lower: validEyelidShape(json.lowerEyelid_shape),
    guide: readBoolean(json, "showGuide_line"),
    bg: readBoolean(json, "lockBgColor"),
    eye: readBoolean(json, "lockEyeColor"),
    brow: readBoolean(json, "lockBrowColor"),
    lidMove: readBoolean(json, "lockLidMove"),
    eyeMove: readBoolean(json, "lockEyeMove"),
    browMove: readBoolean(json, "lockBrowMove")
  };
  if (!Number.isInteger(json.animDuration)) throw new Error("animDurationは整数が必要です。");
  const duration = Math.max(anim_duration_min, Math.min(anim_duration_max, json.animDuration));
  animating = false;
  copyValuesInto(next_transforms, transforms);
  copyArrayInto(next_colors, colors);
  symmetry_mode = next.symmetry;
  upperEyelid_shape = next.upper;
  lowerEyelid_shape = next.lower;
  showGuide_line = next.guide;
  lock_bg_color = next.bg;
  lockEye_color = next.eye;
  lock_brow_color = next.brow;
  lockLid_move = next.lidMove;
  lockEye_move = next.eyeMove;
  lock_brow_move = next.browMove;
  anim_duration = duration;
  active_text_box = input_nothing;
  input_text = "";
}
