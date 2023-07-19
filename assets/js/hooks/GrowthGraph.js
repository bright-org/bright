import { Chart } from 'chart.js/auto'

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


const beforeDatasetsDraw = (chart) => {

}

const createChartFromJSON = (labels, datasets) => {
  const color = "#0000FF"
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
            color: color,
            backdropPadding: 5,
            padding: 25,
          },
        },
      },
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
    const datasets = [];
    datasets.push(createData(data[0]));

    if (data[1] !== undefined) {
      datasets.push(createData(data[1]))
    }

    const ctx = document.querySelector('#' + element.id + ' canvas')
    const myChart = new Chart(ctx, createChartFromJSON(labels, datasets))
    myChart.canvas.parentNode.style.height =  '426px'
    myChart.canvas.parentNode.style.width =   '426px'

  }
}
