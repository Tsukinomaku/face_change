let videoRecorder = null;
let videoStream = null;
let videoChunks = [];
let recordedVideo = null;

// 録画開始・停止を切り替える。録画後の動画は「動画保存」でダウンロードする。
function toggleRecording() {
  if (exporting_video) return;
  if (recording) {
    recording = false;
    exporting_video = true;
    videoRecorder.stop();
    showMessage("録画を停止しています…");
    return;
  }
  startRecording();
}

// 顔専用のキャンバスをMediaRecorderへ渡す。UI・補助線・REC表示は含めない。
function startRecording() {
  if (typeof MediaRecorder == "undefined" || typeof faceGraphics.canvas.captureStream != "function") {
    showMessage("このブラウザは動画録画に対応していません。ChromeまたはEdgeで試してください。", true);
    return;
  }
  const formats = ["video/webm;codecs=vp9", "video/webm;codecs=vp8", "video/webm", "video/mp4"];
  const mimeType = formats.find(type => MediaRecorder.isTypeSupported(type));
  try {
    videoStream = faceGraphics.canvas.captureStream(screen_fps);
    videoRecorder = new MediaRecorder(videoStream, mimeType ? { mimeType } : {});
    const recorder = videoRecorder;
    let failed = false;
    videoChunks = [];
    videoRecorder.ondataavailable = event => {
      if (event.data.size > 0) videoChunks.push(event.data);
    };
    videoRecorder.onstop = () => {
      const actualType = recorder.mimeType || videoChunks[0]?.type || "video/webm";
      const result = new Blob(videoChunks, { type: actualType });
      if (!failed && result.size > 0) recordedVideo = result;
      releaseRecordingStream();
      videoChunks = [];
      exporting_video = false;
      if (failed) return;
      showMessage(result.size > 0 ? "録画完了。「動画保存」でダウンロードできます。" : "録画データがありません。", result.size == 0);
    };
    videoRecorder.onerror = event => {
      recording = false;
      failed = true;
      exporting_video = true;
      releaseRecordingStream();
      showMessage(`録画エラー: ${event.error?.message || "録画を継続できませんでした。"}`, true);
    };
    videoRecorder.start(1000); // 1秒ごとにデータを受け取り、停止時にまとめる
    record_start_time = millis();
    recording = true;
    showMessage("顔だけを録画しています。終了後に「動画保存」を押してください。");
  } catch (error) {
    recording = false;
    releaseRecordingStream();
    showMessage(`録画開始に失敗: ${error.message}`, true);
  }
}

// 録画に使ったストリームを終了する。
function releaseRecordingStream() {
  if (videoStream) videoStream.getTracks().forEach(track => track.stop());
  videoStream = null;
}

// 停止して確定した動画をダウンロードする。実際の形式に拡張子を合わせる。
function exportVideo() {
  if (recording || exporting_video) {
    showMessage("先に録画を停止し、録画完了を待ってください。");
    return;
  }
  if (!recordedVideo) {
    showMessage("録画した動画がありません。録画開始→録画停止の順に操作してください。");
    return;
  }
  const extension = recordedVideo.type.includes("mp4") ? "mp4" : "webm";
  downloadBlob(recordedVideo, `face-video.${extension}`);
  showMessage(`動画をface-video.${extension}へ保存しました。`);
}

// RECマークと経過秒を、録画対象ではない操作画面へ重ねる。
function drawRecordingMark() {
  if (!recording) return;
  push();
  noStroke();
  fill(255, 0, 0, frameCount % screen_fps < screen_fps / 2 ? recording_bright_alpha : recording_dim_alpha);
  ellipse(recording_mark_x, recording_mark_y, recording_mark_size, recording_mark_size);
  fill(text_color);
  textSize(recording_text_size);
  textAlign(LEFT, CENTER);
  text(`REC ${((millis() - record_start_time) / 1000).toFixed(1)} 秒`, recording_mark_x + recording_text_x_offset, recording_mark_y + recording_text_y_offset);
  pop();
}
