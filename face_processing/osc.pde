// 受信したOSCメッセージを待機列に入れるここでは顔を変更しない
void oscEvent(OscMessage msg) {
   if (osc_messages.size() >= osc_queue_limit) return; // 待機数が上限なら、新しいメッセージを受け付けない
  osc_messages.add(msg);
}

// OSCの整数または小数をfloatとして取り出し、異常値を確認する
float oscNumber(OscMessage msg, int index) {
  char type = msg.typetag().charAt(index);
  float value = type == 'i' ? msg.get(index).intValue() : msg.get(index).floatValue();
  if (!isFiniteValue(value)) throw new IllegalArgumentException("有限の数値を指定してください");
  return value;
}

// OSCの引数の数と型を確認するnは整数・小数のどちらも許可
void requireOscTypes(OscMessage msg, String pattern) {
  String types = msg.typetag();
  if (types.length() != pattern.length()) throw new IllegalArgumentException("引数の数が違います");
  for (int i = 0; i < pattern.length(); i++) {
    char expected = pattern.charAt(i);
    char actual = types.charAt(i);
    boolean valid = expected == 'n' ? actual == 'i' || actual == 'f' : actual == expected; // iは整数、fは小数、sは文字列nはこの関数独自の数値指定
    if (!valid) throw new IllegalArgumentException("引数の型が違います: " + types);
  }
}

// OSCのアドレスを調べ、プリセット・速度・JSON読込・移動を処理する
void handleOscMessage(OscMessage msg) {
  try {
    if (msg.checkAddrPattern("/preset")) { // 登録済みプリセットへ遷移する番号は0から始まる
      requireOscTypes(msg, "i");
      int preset = msg.get(0).intValue();
      if (preset < 0 || preset >= number_of_presets) throw new IllegalArgumentException("プリセット番号が範囲外です");
      if (preset_saved[preset]) start_transition(preset_transforms[preset], preset_colors[preset], true);
    } else if (msg.checkAddrPattern("/speed")) { // 所要時間をミリ秒で変更する短いほど速くなる
      requireOscTypes(msg, "i");
      anim_duration = constrain(msg.get(0).intValue(), anim_duration_min, anim_duration_max);
    } else if (msg.checkAddrPattern("/loadJson")) { // 指定されたJSONの顔データへ遷移する
      requireOscTypes(msg, "s");
      loadAndTransitionFromJson(msg.get(0).stringValue());
    } else if (msg.checkAddrPattern("/movePart")) { // 対象ID・X移動量・Y移動量・回転量を取り出す
      requireOscTypes(msg, "innn");
      int target = msg.get(0).intValue();
      if (target < minI_d || target > maxI_d) throw new IllegalArgumentException("ターゲットIDは0～12です");
      float dx = oscNumber(msg, 1);
      float dy = oscNumber(msg, 2);
      float da = oscNumber(msg, 3);
      if (target == background) return;
      float[][] next_transforms = copyValues(transforms);
      moveParts(next_transforms, target, dx, dy, da);

      start_transition(next_transforms, colors, false); // 最短回転に直さず、指定された方向と回転量を保つ
    }
  } catch (Exception e) {
    println("OSCエラー" + msg.addrPattern() + ": " + e.getMessage());
  }
}
