import { Chart } from 'chart.js/auto'
const dash = [5, 3]
const padding = 70
const dashColor = '#97ACAC'
const myselfBorderColor = '#52CCB5'
const myselfPointColor = '#96D1B7'
const myselfSelectedColor = '#008971'
const myselfFillStartColor = '#B6F1E7FF'
const myselfFillEndColor = '#B6F1E700'
const otherBorderColor = '#C063CD'
const otherPointColor = '#E4BDE9'
const otherSelectedColor = '#9510B1'
const roleBorderColor = '#A9BABA'
const rolePointColor = '#D5DCDC'
const futurePointColor = '#FFFFFF'
const nowColor = '#B77285'
const nowSelectColor = '#B71225'

const dataDivision = (data, futureEnabled) => {
  if (data === undefined) return [[], []]
  data = data.slice(1)
  if (!futureEnabled) return [data, []]
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

const createData = (data) => {
  const futureEnabled = data['future_enabled'] === undefined ? true : data['future_enabled']
  const [myselfData, myselfFuture] = dataDivision(data['myself'], futureEnabled)
  const [otherData, otherFuture] = dataDivision(data['other'], futureEnabled)
  const [roleData, roleFuture] = dataDivision(data['role'], futureEnabled)
  const datasets = [];
  datasets.push(createDataset(myselfData, myselfBorderColor, myselfPointColor, myselfPointColor, false))
  if (futureEnabled) {
    datasets.push(createDataset(myselfFuture, myselfBorderColor, futurePointColor, myselfPointColor, true))
  }
  datasets.push(createDataset(otherData, otherBorderColor, otherPointColor, otherPointColor, false))
  if (futureEnabled) {
    datasets.push(createDataset(otherFuture, otherBorderColor, futurePointColor, otherPointColor, true))
  }
  datasets.push(createDataset(roleData, roleBorderColor, rolePointColor, rolePointColor, false))
  if (futureEnabled) {
    datasets.push(createDataset(roleFuture, roleBorderColor, futurePointColor, rolePointColor, true))
  }

  return {
    labels: data.labels,
    datasets: datasets
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

const drawNow = (chart, scales) => {
  const context = chart.ctx
  const dataset = chart.canvas.parentNode.dataset
  // 現在のスコア
  const data = JSON.parse(dataset.data)
  const now = data['now']

  if (now === undefined) return
  const y = scales.y
  const x = scales.x
  const pastData = data['myself']
  const drawNowColor = data['myselfSelected'] === 'now' ? nowSelectColor : nowColor

  context.setLineDash([2, 0])
  context.strokeStyle = drawNowColor
  const nowDown = y.getPixelForValue(0)
  const nowY = y.getPixelForValue(now)
  const pastY = y.getPixelForValue(pastData[4])

  // 直近の過去から未来の真ん中を求める
  const futureX = x.getPixelForValue(4)
  const pastX = x.getPixelForValue(3)
  const diffX = futureX - pastX
  const nowX = pastX + (diffX / 2)

  // 「現在」縦線
  context.lineWidth =  data['myselfSelected'] === 'now' ? 4 : 2
  context.beginPath()
  context.moveTo(nowX, nowDown)
  context.lineTo(nowX, nowY)
  context.stroke()

  // 直近の過去から現在までの線
  context.lineWidth = 3
  context.strokeStyle = myselfBorderColor
  context.beginPath()
  context.moveTo(pastX, pastY)
  context.lineTo(nowX, nowY)
  context.stroke()

  // 現在の点
  context.beginPath()
  context.arc(nowX, nowY, 8.5, 0 * Math.PI / 180, 360 * Math.PI / 180, false)
  context.fillStyle = drawNowColor
  context.fill()
}

const drawSelectedLine = (chart, scales, dataname, selectedColor, index) => {
  if (index < 0) return
  const context = chart.ctx
  const dataset = chart.canvas.parentNode.dataset
  // 現在のスコア
  const data = JSON.parse(dataset.data)
  let drawData = data[dataname]

  if (drawData === undefined) return
  drawData = drawData.slice(1)

  const y = scales.y
  const x = scales.x
  const curentData = drawData[index]

  context.lineWidth = 4
  context.setLineDash([])
  context.strokeStyle = selectedColor
  const selectedX = x.getPixelForValue(index)
  const selectedYDown = y.getPixelForValue(0)
  const selectedYUp = y.getPixelForValue(curentData)

  // 「選択している」縦線
  context.beginPath()
  context.moveTo(selectedX, selectedYDown)
  context.lineTo(selectedX, selectedYUp)
  context.stroke()
}

const drawSelectedPoint = (chart, scales, dataname, selectedColor, index) => {
  if (index < 0) return

  const context = chart.ctx
  const dataset = chart.canvas.parentNode.dataset
  // 現在のスコア
  const data = JSON.parse(dataset.data)
  let drawData = data[dataname]

  if (drawData === undefined) return
  drawData = drawData.slice(1)

  const y = scales.y
  const x = scales.x
  const curentData = drawData[index]

  context.lineWidth = 4
  context.setLineDash([])
  context.strokeStyle = selectedColor
  const selectedX = x.getPixelForValue(index)
  const selectedYUp = y.getPixelForValue(curentData)

  // 「選択している」ポイント
  context.beginPath()
  context.arc(selectedX, selectedYUp, 8.5, 0 * Math.PI / 180, 360 * Math.PI / 180, false)
  context.fillStyle = selectedColor
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
  const dataset = chart.canvas.parentNode.dataset
  const data = JSON.parse(dataset.data)

  const myselfSelected = (element) => element == data['myselfSelected'];
  const myselfSelectedIndex = data.labels.findIndex(myselfSelected)

  const otherSelected = (element) => element == data['otherSelected'];
  const otherSelectedIndex = data.labels.findIndex(otherSelected)

  drawvVrticalLine(context, scales)
  drawHorizonLine(context, scales)
  fillMyselfData(chart, scales)
  drawNow(chart, scales)
  drawSelectedLine(chart, scales, 'myself', myselfSelectedColor, myselfSelectedIndex)
  drawSelectedLine(chart, scales, 'other', otherSelectedColor, otherSelectedIndex)
  drawfastDataLine(chart, scales, "role", roleBorderColor)
  drawfastDataLine(chart, scales, "other", otherBorderColor)
  drawfastDataLine(chart, scales, "myself", myselfBorderColor)
}

const afterDatasetsDraw = (chart, ease) => {
  const context = chart.ctx
  const scales = chart.scales
  const dataset = chart.canvas.parentNode.dataset
  const data = JSON.parse(dataset.data)

  const myselfSelected = (element) => element == data['myselfSelected'];
  const myselfSelectedIndex = data.labels.findIndex(myselfSelected)

  const otherSelected = (element) => element == data['otherSelected'];
  const otherSelectedIndex = data.labels.findIndex(otherSelected)

  drawSelectedPoint(chart, scales, 'myself', myselfSelectedColor, myselfSelectedIndex)
  drawSelectedPoint(chart, scales, 'other', otherSelectedColor, otherSelectedIndex)
}

const createChartFromJSON = (data) => {
  return ({
    type: 'line',
    data: createData(data),
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
    plugins: [
      {
        beforeDatasetsDraw: beforeDatasetsDraw,
        afterDatasetsDraw: afterDatasetsDraw
      }]
  })
}

export const GrowthGraph = {
  drawGrowthGraph(element) {
    const dataset = element.dataset
    const data = JSON.parse(dataset.data)
    const ctx = document.querySelector('#' + element.id + ' canvas')
    this.myChart = new Chart(ctx, createChartFromJSON(data))
    this.myChart.canvas.parentNode.style.height = '357px'
    this.myChart.canvas.parentNode.style.width = '714px'
  },
  mounted() {
    this.drawGrowthGraph(this.el)
  },
  updated() {
    this.myChart.destroy()
    this.drawGrowthGraph(this.el)
  }
}
