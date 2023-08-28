// タブを横方向にスライドさせるボタン用JS

const animateElement = function(element, property, startValue, endValue, duration) {
  let startTime = null
  function step(timestamp) {
    if (!startTime) startTime = timestamp
    const progress = timestamp - startTime
    const percentage = Math.min(progress / duration, 1)
    const currentValue = startValue + percentage * (endValue - startValue)
    element.style[property] = currentValue + "px"
    if (progress < duration) {
      requestAnimationFrame(step)
    }
  }
  requestAnimationFrame(step)
}

const setElementMargin = function(element, property, value) {
  element.style[property] = value + "px"
}

const setButtonsDisplay = function(element, count) {
  if (count > 3) {
    element.style.display = "flex"
  } else {
    element.style.display = "none"
  }
}

const TabSlideScroll = {
  mounted() {
    const relational_tab = this.el.querySelector(".inner_tab_list")
    const relational_tab_items = relational_tab.querySelectorAll("li")
    this.relational_buttons = this.el.querySelector(".inner_tab_slide_buttons")
    this.margin = 0
    this.first_tab_item = relational_tab_items[0]
    this.count = relational_tab_items.length
    const tab_width = this.count * 200
    const buttons = this.relational_buttons.children

    // 表示設定
    setButtonsDisplay(this.relational_buttons, this.count)

    // イベント設定
    buttons[1].addEventListener("click", () => {
      if (tab_width + this.margin > 600) {
        this.margin = this.margin - 200
        animateElement(this.first_tab_item, "marginLeft", this.margin + 200, this.margin, 250)
      }
    })
    buttons[0].addEventListener("click", () => {
      if (this.margin < 0) {
        this.margin = this.margin + 200
        animateElement(this.first_tab_item, "marginLeft", this.margin - 200, this.margin, 250)
      }
    })
  },

  updated() {
    // タブ押下時(updated)の位置と表示の再設定
    setElementMargin(this.first_tab_item, "marginLeft", this.margin)
    setButtonsDisplay(this.relational_buttons, this.count)
  }
}

export default TabSlideScroll
