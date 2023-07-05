import { Chart } from 'chart.js/auto'

const getColorPattern = (length, colors) => {
  const pattern = [];
  if (length < 3) return

  // lengthが4の時は先頭から2色の交互
  if (length === 4) {
    for (let i = 0; i < length; i++) {
      pattern.push(colors[i % 2])
    }
    return pattern
  }

  // lengthが3で割り切れる時
  if (length % 3 === 0) {
    for (let i = 0; i < length; i++) {
      pattern.push(colors[i % colors.length])
    }
    return pattern
  }

  // lengthが3で割り切れるない時は3色の繰り返しで、最後は先頭から2番目の色を代入
  for (let i = 0; i < length - 1; i++) {
    pattern.push(colors[i % colors.length])
  }
  pattern.push(colors[1])
  return pattern
}

const createData = (data) => {
  return {
    label: '',
    data: data,
    borderColor: '#FFFFFF00',
    backgroundColor: '#FFFFFF00',
    borderWidth: 0,
    pointRadius: 0,
  }
}

const fillSurface = (chart, data, index, color) => {
  const context = chart.ctx

  const startValue = data[(index % data.length)]
  const endValue = data[((index + 1) % data.length)]
  const endIndex = ((index + 1) % data.length)

  const v0 = chart.scales.r.getPointPositionForValue(0, 0)
  const v1 = chart.scales.r.getPointPositionForValue(index, startValue)
  const v2 = chart.scales.r.getPointPositionForValue(endIndex, endValue)
  context.beginPath()
  context.strokeStyle = color
  context.moveTo(v0.x, v0.y)
  context.lineTo(v1.x, v1.y)
  context.lineTo(v2.x, v2.y)
  context.lineTo(v0.x, v0.y)
  context.fillStyle = color
  context.fill()
}

const drawGridline = (chart, value, length) => {
  const context = chart.ctx
  const v0 = chart.scales.r.getPointPositionForValue(0, value)
  context.beginPath()
  context.moveTo(v0.x, v0.y)
  context.strokeStyle = "#FFFFFF44"

  for (let i = 1; i < length; i++) {
    chart.scales.r.getPointPositionForValue(i, value)
    const v1 = chart.scales.r.getPointPositionForValue(i, value)
    context.lineTo(v1.x, v1.y)
  }
  context.lineTo(v0.x, v0.y)
  context.stroke()
}

const drawUnderline = (chart, i) => {
  const context = chart.ctx
  const label = chart.scales.r.getPointLabelPosition(i)
  context.beginPath()
  context.lineWidth = 1
  context.strokeStyle = '#0000ff'
  context.moveTo(label.left, label.bottom)
  context.lineTo(label.right, label.bottom)
  context.stroke()
}

const beforeDatasetsDraw = (chart) => {
  const context = chart.ctx
  const data = chart.data.datasets[0].data
  const color = getColorPattern(data.length, ["#72EAD9C0", "#3CC0A8C0", "#1DA091C0"])
  const color2 = getColorPattern(data.length, ["#E4BDE9AA", "#C063CDAA", "#9510B1AA"])

  if (chart.data.datasets[1] !== undefined) {
    for (let i = 0; i < chart.data.datasets[1].data.length; i++) {
      fillSurface(chart, chart.data.datasets[1].data, i, color2[i])
    }
  }

  for (let i = 0; i < data.length; i++) {
    fillSurface(chart, data, i, color[i])
  }

  for (let i = 1; i < 5; i++) {
    drawGridline(chart, 20 * i, data.length)
  }

  const img = new Image()
  img.src = "/images/icon_up_green.svg"

  const iconWidth = 21
  const iconHeight = 21

  // padding rightで拡張しないと、一番右にに表示するアイコンが削れる
  img.onload = function () {
    for (let i = 0; i < data.length; i++) {
      const label = chart.scales.r.getPointLabelPosition(i);
      context.drawImage(img, label.right + 2, label.top - 4, iconWidth, iconHeight)
    }
  }

  for (let i = 0; i < data.length; i++) {
    drawUnderline(chart, i)
  }
}

const createChartFromJSON = (labels, datasets) => {
  return ({
    type: 'radar',
    data: {
      labels: labels,
      datasets: datasets
    },
    options: {
      animation: false,
      responsive: true,
      maintainAspectRatio: false,
      layout: {
        padding: {
          right: 22
        }
      },
      gridLines: {
        circular: true
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
        r: {
          min: 0,
          max: 100,
          backgroundColor: '#D4F9F7',
          grid: {
            display: false
          },
          angleLines: {
            display: false
          },
          ticks: {
            stepSize: 20,
            display: false
          },
          pointLabels: {
            color: '#0000FF',
            backdropPadding: 5,
            padding: 25,
          },
        },
      },
    },
    plugins: [{ beforeDatasetsDraw: beforeDatasetsDraw }]
  })
}

export const SkillGem = {
  mounted() {
    const element = this.el
    const dataset = element.dataset
    const labels = JSON.parse(dataset.labels)
    const data = JSON.parse(dataset.data)
    const isSmall = dataset.size == "sm"
    const datasets = [];
    datasets.push(createData(data[0]));

    if (data[1] !== undefined) {
      datasets.push(createData(data[1]))
    }

    const ctx = document.querySelector('#' + element.id + ' canvas')
    const myChart = new Chart(ctx, createChartFromJSON(labels, datasets))
    myChart.canvas.parentNode.style.height = isSmall ?  '165px' : '426px'
    myChart.canvas.parentNode.style.width =  isSmall ? '250px' : '426px'

    ctx.addEventListener('click', function (event) {
      // padding rightで拡張した部分がクリック判定できるようにする

      const rect = ctx.getBoundingClientRect()
      const x = event.clientX - rect.left
      const y = event.clientY - rect.top
      const length = myChart.data.labels.length

      // リンクの判定例
      for (let i = 0; i < length; i++) {
        const label = myChart.scales.r.getPointLabelPosition(i)
        const judge = (x >= label.left) && (x <= label.right) && (y >= label.top) && (y <= label.bottom)
        if (judge) { alert('リンククリック：' + myChart.data.labels[i]) }
      }

      // アイコン判定例
      for (let i = 0; i < length; i++) {
        const label = myChart.scales.r.getPointLabelPosition(i)
        const judge = (x >= label.right + 2) && (x <= label.right + 20 + 2) && (y >= label.top - 5) && (y <= label.top + 20 - 5)
        if (judge) { alert('アイコンクリック：' + myChart.data.labels[i]) }
      }
    })
  }
}
