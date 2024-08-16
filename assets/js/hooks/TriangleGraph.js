// グラフの色定義
const beginnerColor = "#1DA091";
const normalColor = "#3CC0A8";
const skilledColor = "#72EAD9";

// 文字の色定義
const textColor = "#688888";

const maxPercent = 100;

// 三角形の描画関数
// 三角形を一つだけ描きます
const drawTriangle = (ctx, percent, color) => {
  // 100％の三角形から小さくしていき、x座標がずれるので差分を求めています
  let xDiff = maxPercent - percent;
  ctx.beginPath();
  // 三角形の頂点を開始位置にします
  ctx.moveTo(percent + xDiff, 0);
  // 三角形の左下まで線を描きます
  ctx.lineTo(0 + xDiff, percent);
  // 三角形の右下まで線を描きます
  // percent * 2 の理由は頂点を基準に左右で倍の長さにしたいからです
  ctx.lineTo(percent * 2 + xDiff, percent);
  // ここでパスを閉じると頂点と結ばれます
  ctx.closePath();
  ctx.fillStyle = color;
  ctx.fill();
}

// %を求める関数
const getPercent = (number, total) => {
  if (total == 0) return 0;
  return Math.floor(number / total * maxPercent);
}

// 各レベルのテキストを描画する関数
const drawLevel = (ctx, levelText, number, percent, x, y) => {
  ctx.fillStyle = textColor;
  ctx.font = "14px 'Noto Sans JP'";
  ctx.fillText(levelText + " " + number + "人 " + percent + "%", x, y);
}

const drawTriangleGraph = (element) => {
  const dataset = element.dataset;
  const data = JSON.parse(dataset.data);
  const canvas = document.querySelector("#" + element.id + " canvas");
  const ctx = canvas.getContext('2d');

  const total = data.beginner + data.normal + data.skilled;

  const skilledPercent = getPercent(data.skilled, total);
  const normalPercent = getPercent(data.normal, total);
  const beginnerPercent = total == 0 ? 0 : maxPercent - skilledPercent - normalPercent;

  drawLevel(ctx, "ベテラン", data.skilled, skilledPercent, 210, 15);
  drawLevel(ctx, "平均", data.normal, normalPercent, 210, 50);
  drawLevel(ctx, "見習い", + data.beginner, beginnerPercent, 210, 90);

  // 三角形を重ねて描画します
  // ・見習い
  // ・平均
  // ・ベテラン
  // の順に描画します
  // 三角形全体を見習いで描画後、平均やベテラン分を頂点を基準に描画する為順序が大事です. 重ねて描画されなかった領域が見習い領域になります。
  drawTriangle(ctx, maxPercent, beginnerColor);

  // 合計が0の場合は「見習い」のみ描画
  if (total == 0) return;
  drawTriangle(ctx, maxPercent - beginnerPercent, normalColor);
  drawTriangle(ctx, skilledPercent, skilledColor);

}

export const TriangleGraph = {
  mounted() {
    drawTriangleGraph(this.el);
  }
};
