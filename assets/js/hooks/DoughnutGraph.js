import { Chart } from 'chart.js/auto'
const dash = [3, 2]
const dashColor = '#A5B8B8'
const myBorderColor = '#52CCB5'
const myPointColor = '#B6F1E7'
const myFillColor = '#40DEC622'
const othersBorderColor = '#C063CD'
const othersPointColor = '#E4BDE9'
const futurePointColor = '#FFFFFF'
const currentColor = '#B71225'

const dataDivision = (data) => {
  const past = data.map((x, index) => index > 3 ? null : x)
  const future = data.map((x, index) => index < 3 ? null : x)
  return([past, future])
}


const doughnutData = {
  labels: ["Red", "Blue", "Yellow"],
  datasets: [
    {
      label: "My First Dataset",
      data: [300, 50, 100],
      backgroundColor: [
        "rgb(255, 99, 132)",
        "rgb(54, 162, 235)",
        "rgb(255, 205, 86)",
      ],
      hoverOffset: 4,
    },
  ],
};

const createData = (labels, data) => {
  const [myData, myFuture] = dataDivision(data[0])
  const [othersData, othersFuture] = dataDivision(data[1])

  return{
    labels: labels,
    datasets: [
      {
        label: 'others',
        data: othersData,
        borderColor: othersBorderColor,
        pointRadius: 8,
        pointBackgroundColor: othersPointColor,
        pointBorderColor: othersPointColor,
        fill: false,
        tension: 0.1
    }
  ]
  }
}

const createChartFromJSON = (data) => {
  return (
    {
      type: "doughnut",
      data: doughnutData,
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
    myChart.canvas.parentNode.style.height =  '80px'
    myChart.canvas.parentNode.style.width =   '80px'

  }
}
