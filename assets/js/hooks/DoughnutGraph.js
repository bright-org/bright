import { Chart } from 'chart.js/auto'



const doughnutData = (data) => {
  return {
    datasets: [
      {
        data: data,
        backgroundColor: [
          "rgb(255, 99, 132)",
          "rgb(54, 162, 235)",
          "rgb(255, 205, 86)",
        ]
      },
    ]
  }
};

const createChartFromJSON = (data) => {
  return (
    {
      type: "doughnut",
      data: doughnutData(data),
      options: {
        plugins: {
          legend: {
            display: false,
          },
        },
      },
    }
  )
}

export const DoughnutGraph = {
  mounted() {
    const element = this.el
    const dataset = element.dataset
    const data = JSON.parse(dataset.data)

    const ctx = document.querySelector('#' + element.id + ' canvas')
    const myChart = new Chart(ctx, createChartFromJSON(data))
    myChart.canvas.parentNode.style.height = '80px'
    myChart.canvas.parentNode.style.width = '80px'

  }
}
