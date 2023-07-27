import { Chart } from 'chart.js/auto'
const dash = [5, 3]
const padding = 70
const dashColor = '#97ACAC'
const myselfBorderColor = '#52CCB5'
const myselfPointColor = '#B6F1E7'
const myselfFillStartColor = '#B6F1E7FF'
const myselfFillEndColor = '#B6F1E700'
const otherBorderColor = '#C063CD'
const otherPointColor = '#E4BDE9'
const roleBorderColor = '#A9BABA'
const rolePointColor = '#D5DCDC'
const futurePointColor = '#FFFFFF'
const currentColor = '#B71225'

const dataDivision = (data) => {
  if (data === undefined) return [[], []]
  data = data.slice(1)
  const past = data.map((x, index) => index > 3 ? null : x)
  const future = data.map((x, index) => index < 3 ? null : x)
  return ([past, future])
}

const createDataset = (data, borderColor, pointBackgroundColor, pointBorderColor, isFuture) => {
  return {
    data: data,
    borderColor: borderColor,
    pointRadius: 8,
    pointBackgroundColor: pointBackgroundColor,
    pointBorderColor: pointBorderColor,
    borderDash: isFuture ? dash : []
  }
}

const createData = (labels, data) => {
  const [myselfData, myselfFuture] = dataDivision(data['myself'])
  const [otherData, otherFuture] = dataDivision(data['other'])
  const [roleData, roleFuture] = dataDivision(data['role'])
  return {
    labels: labels,
    datasets: [
      createDataset(myselfData, myselfBorderColor, myselfPointColor, myselfPointColor, false),
      createDataset(myselfFuture, dashColor, futurePointColor, myselfPointColor, true),
      createDataset(otherData, otherBorderColor, otherPointColor, otherPointColor, false),
      createDataset(otherFuture, dashColor, futurePointColor, otherPointColor, true),
      createDataset(roleData, roleBorderColor, rolePointColor, rolePointColor, false),
      createDataset(roleFuture, dashColor, futurePointColor, rolePointColor, true),
    ]
  }
}

const drawvVrticalLine = (context, scales) => {
  const y = scales.y
  const x = scales.x

  context.lineWidth = 0.5
  const upY = y.getPixelForValue(100)
  const downY = y.getPixelForValue(0)
  context.setLineDash(dash)
  context.strokeStyle = dashColor

  context.beginPath()
  for (let i = 0; i < 5; i++) {
    const vrticalX = x.getPixelForValue(i)
    context.moveTo(vrticalX, upY)
    context.lineTo(vrticalX, downY)
  }
  context.stroke()
}
const drawHorizonLine = (context, scales) => {
  // 見習い、平均、ベテランの線
  const y = scales.y
  const x = scales.x

  const startX = x.getPixelForValue(0) - padding
  const endX = x.getPixelForValue(4) + padding
  const downY = y.getPixelForValue(0)
  const normalY = y.getPixelForValue(40)
  const skilledY = y.getPixelForValue(60)
  context.lineWidth = 0.5
  context.setLineDash([])
  context.strokeStyle = dashColor
  context.beginPath()
  // 下の線
  context.moveTo(startX, downY)
  context.lineTo(endX, downY)
  context.stroke()

  context.setLineDash(dash)

  // 平均の線
  context.beginPath()
  context.moveTo(startX, normalY)
  context.lineTo(endX, normalY)

  // ベテランの線
  context.moveTo(startX, skilledY)
  context.lineTo(endX, skilledY)
  context.stroke()
}

const drawCurrent = (chart, scales) => {
  const context = chart.ctx
  const dataset = chart.canvas.parentNode.dataset
  // 現在のスコア
  const data = JSON.parse(dataset.data)
  let now = data['now']

  if (now === undefined) return
  const y = scales.y
  const x = scales.x
  const pastData = data['myself']

  //　現在の縦線
  context.beginPath()
  context.lineWidth = 3
  context.setLineDash([2, 0])
  context.strokeStyle = currentColor
  const nowDown = y.getPixelForValue(0)
  const nowY = y.getPixelForValue(now)
  const pastY = y.getPixelForValue(pastData[4])

  // 直近の過去から未来の真ん中を求める
  const futureX = x.getPixelForValue(4)
  const pastX = x.getPixelForValue(3)
  const diffX = futureX - pastX
  const nowX = pastX + (diffX / 2)

  // 「現在」縦線
  context.beginPath()
  context.moveTo(nowX, nowDown)
  context.lineTo(nowX, nowY)
  context.stroke()

  // 直近の過去から現在までの線
  context.beginPath()
  context.moveTo(pastX, pastY)
  context.lineTo(nowX, nowY)
  context.stroke()

  // 現在の点
  context.beginPath()
  context.arc(nowX, nowY, 8, 0 * Math.PI / 180, 360 * Math.PI / 180, false)
  context.fillStyle = currentColor
  context.fill()
}

const drawfastDataLine = (chart, scales, name, color) => {
  const context = chart.ctx
  const dataset = chart.canvas.parentNode.dataset
  const data = JSON.parse(dataset.data)
  const drawData = data[name]
  if (drawData === undefined) return
  if (drawData[0] === null) return
  context.lineWidth = 3
  context.setLineDash([])
  const y = scales.y
  const x = scales.x

  const startX = x.getPixelForValue(0) - padding
  const endX = x.getPixelForValue(0)
  const stratY = y.getPixelForValue(drawData[0])
  const endY = y.getPixelForValue(drawData[1])

  context.strokeStyle = color
  context.beginPath()
  context.moveTo(startX, stratY)
  context.lineTo(endX, endY)
  context.stroke()

}

const fillMyselfData = (chart, scales) => {
  const context = chart.ctx
  const dataset = chart.canvas.parentNode.dataset
  const data = JSON.parse(dataset.data)
  let drawData = data['myself']
  if (drawData === undefined) return
  // 期間外のデータを描画するかを判定　配列の先頭は期間外のデータ
  const isDrawBefore = drawData[0] !== null

  // 期間外のデータがnullの場合は予め除外しておく、理由は通常のグリッド処理が可能の為
  drawData = isDrawBefore ? drawData : drawData.slice(1)
  context.lineWidth = 1
  context.setLineDash([])
  const y = scales.y
  const x = scales.x

  const startX = x.getPixelForValue(0) - padding
  const startY = y.getPixelForValue(0)

  const endX = x.getPixelForValue(4)
  const endY = y.getPixelForValue(0)

  const gradient = context.createLinearGradient(0, 0, 0, 300)
  gradient.addColorStop(0, myselfFillStartColor)
  gradient.addColorStop(1, myselfFillEndColor)

  context.fillStyle = gradient
  context.beginPath()
  context.moveTo(startX, startY)
  if (isDrawBefore) {
    // 期間外のデータの時はグリッドでx座標を管理していない為x座標計算結果(startX)を代入
    let pointY = y.getPixelForValue(drawData[0])
    context.lineTo(startX, pointY)
  }

  startIndex = isDrawBefore ? 1 : 0

  for (let i = startIndex; i < drawData.length; i++) {
    let pointX = x.getPixelForValue(i - startIndex)
    let pointY = y.getPixelForValue(drawData[i])
    context.lineTo(pointX, pointY)
  }
  context.lineTo(endX, endY)
  context.lineTo(startX, startY)
  context.closePath()
  context.fill()
}

const beforeDatasetsDraw = (chart, ease) => {
  const context = chart.ctx
  const scales = chart.scales
  drawvVrticalLine(context, scales)
  drawHorizonLine(context, scales)
  fillMyselfData(chart, scales)
  drawCurrent(chart, scales)
  drawfastDataLine(chart, scales, "role", roleBorderColor)
  drawfastDataLine(chart, scales, "other", otherBorderColor)
  drawfastDataLine(chart, scales, "myself", myselfBorderColor)
}

const createChartFromJSON = (labels, data) => {
  return ({
    type: 'line',
    data: createData(labels, data),
    options: {
      animation: false,
      hover: {
        mode: null
      },
      layout: {
        padding: {
          right: padding,
          left: padding,
        }
      },
      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          enabled: false
        }
      },
      scales: {
        y: {
          min: -3, //丸いポイントが削れるため-3ずらしてる
          max: 103, //丸いポイントが削れるため+3ずらしてる
          display: false,
          grid: {
            display: false
          },
          ticks: {
            display: false
          }
        },
        x: {
          display: false,
          grid: {
            display: false
          }
        }
      }
    },
    plugins: [{ beforeDatasetsDraw: beforeDatasetsDraw }]
  })
}

export const GrowthGraph = {
  mounted() {
    const element = this.el
    const dataset = element.dataset
    const labels = JSON.parse(dataset.labels)
    const data = JSON.parse(dataset.data)

    const ctx = document.querySelector('#' + element.id + ' canvas')
    const myChart = new Chart(ctx, createChartFromJSON(labels, data))
    myChart.canvas.parentNode.style.height = '600px'
    myChart.canvas.parentNode.style.width = '800px'

  }
}
