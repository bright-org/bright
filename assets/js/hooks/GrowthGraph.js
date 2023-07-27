import { Chart } from 'chart.js/auto'
const dash = [5, 3]
const padding = 70
const dashColor = '#97ACAC'
const myselfBorderColor = '#52CCB5'
const myselfPointColor = '#B6F1E7'
const myselfFillColor = '#40DEC622'
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

const createData = (labels, data) => {
  const [myselfData, myselfFuture] = dataDivision(data['myself'])
  const [otherData, otherFuture] = dataDivision(data['other'])
  const [roleData, roleFuture] = dataDivision(data['role'])

  return {
    labels: labels,
    datasets: [
      {
        label: 'myself',
        data: myselfData,
        borderColor: myselfBorderColor,
        pointRadius: 8,
        pointBackgroundColor: myselfPointColor,
        pointBorderColor: myselfPointColor,
        fill: true,
        backgroundColor: myselfFillColor,
      },
      {
        label: 'myselfFuture',
        data: myselfFuture,
        borderColor: dashColor,
        borderDash: dash,
        pointRadius: 8,
        pointBackgroundColor: futurePointColor,
        pointBorderColor: myselfPointColor,
        fill: true,
        backgroundColor: myselfFillColor,
        borderWidth: 2
      },
      {
        label: 'other',
        data: otherData,
        borderColor: otherBorderColor,
        pointRadius: 8,
        pointBackgroundColor: otherPointColor,
        pointBorderColor: otherPointColor,
        fill: false,
        tension: 0.1
      },
      {
        label: 'otherFuture',
        data: otherFuture,
        borderColor: dashColor,
        borderDash: dash,
        pointRadius: 8,
        pointBackgroundColor: futurePointColor,
        pointBorderColor: otherPointColor,
        fill: false,
        borderWidth: 2
      },
      {
        label: 'role',
        data: roleData,
        borderColor: roleBorderColor,
        pointRadius: 8,
        pointBackgroundColor: rolePointColor,
        pointBorderColor: rolePointColor,
        fill: false,
        tension: 0.1
      },
      {
        label: 'roleFuture',
        data: roleFuture,
        borderColor: dashColor,
        borderDash: dash,
        pointRadius: 8,
        pointBackgroundColor: futurePointColor,
        pointBorderColor: rolePointColor,
        fill: false,
        borderWidth: 2
      }]
  }
}

const drawvVrticalLine = (context, scales) => {
  const y = scales.y
  const x = scales.x

  context.lineWidth = 0.5
  const upY = y.getPixelForValue(100)
  const downY = y.getPixelForValue(0)
  context.setLineDash(dash)

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

const drawvfastDataLine = (chart, scales, name, color) => {
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
const beforeDatasetsDraw = (chart, ease) => {
  const context = chart.ctx
  const scales = chart.scales
  drawvVrticalLine(context, scales)
  drawHorizonLine(context, scales)
  drawCurrent(chart, scales)
  drawvfastDataLine(chart, scales, "role", roleBorderColor)
  drawvfastDataLine(chart, scales, "other", otherBorderColor)
  drawvfastDataLine(chart, scales, "myself", myselfBorderColor)
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
