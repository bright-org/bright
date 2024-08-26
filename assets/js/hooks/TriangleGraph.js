import html2canvas from 'html2canvas';

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
const drawLevel = (ctx, levelText, number, percent, x, y, isDisplay) => {
  ctx.fillStyle = textColor;
  ctx.font = "14px 'Noto Sans JP'";

  // 人数は一定期間は封印の為コメントアウト
  ctx.fillText(levelText + " " + percent + "%", x, y);

  // アイコン取得
  image = document.querySelector("#user_menu_dropmenu img")
  if (isDisplay) ctx.drawImage(image, x + 100, y - 15, 20, 20);

  // ctx.fillText(levelText + " " + number + "人 " + percent + "%", x, y);
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

  drawLevel(ctx, "ベテラン", data.skilled, skilledPercent, 210, 15, false);
  drawLevel(ctx, "平均", data.normal, normalPercent, 210, 50, true);
  drawLevel(ctx, "見習い", + data.beginner, beginnerPercent, 210, 90, false);

  // 人数は一定期間は封印の為コメントアウト
  // ctx.fillText( "「 " + data.name + "」登録者 " + total + "人", 5, 120);

  // 三角形を重ねて描画します
  // ・見習い
  // ・平均
  // ・ベテラン
  // の順に描画します
  // 三角形全体を見習いで描画後、平均やベテラン分を頂点を基準に描画する為順序が大事です. 重ねて描画されなかった領域が見習い領域になります。
  drawTriangle(ctx, maxPercent, beginnerColor);

  // 合計が0の場合は「見習い」のみ描画
  if (total > 0) {
    drawTriangle(ctx, maxPercent - beginnerPercent, normalColor);
    drawTriangle(ctx, skilledPercent, skilledColor);
  }

  if (ctx.canvas.parentNode.id !== "ogp_triangle_graph") return;

  html2canvas(document.querySelector("#skill_shara_og_image"), {
    width: 1200,
    height: 630,
  }).then(canvas => {
    let og_image_data = document.getElementById("skill_shara_og_image_data");
    if (og_image_data == null) return;
    og_image_data.value = canvas.toDataURL("image/png");
    og_image_data.click();
  });

}

export const TriangleGraph = {
  mounted() {
    drawTriangleGraph(this.el);
  }
};
