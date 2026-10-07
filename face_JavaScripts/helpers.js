// p5の起動前にも使えるRGB配列。1引数はグレー、4引数目は透明度。
function rgb(r, g = r, b = r, a = 255) {
  return [r, g, b, a];
}

// 行ごとに独立した、多次元のゼロ配列を作る。
function createArray(length, ...dimensions) {
  return Array.from({ length }, () => dimensions.length ? createArray(...dimensions) : 0);
}

// 行もコピーし、コピー先の編集が元の配列へ影響しないようにする。
function copyArrayInto(source, destination) {
  destination.splice(0, destination.length, ...source.map(value => Array.isArray(value) ? value.slice() : value));
}

// 画面下の案内欄へ、操作結果やエラーを表示する。
function showMessage(message, error = false) {
  const status = document.getElementById("status");
  status.textContent = message;
  status.classList.toggle("error", error);
}

// ブラウザのダウンロードとしてファイルを保存する。
function downloadBlob(blob, filename) {
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}
