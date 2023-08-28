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

const setElement = function(element, property, value) {
  element.style[property] = value + "px"
}

const TabSlideScroll = {
  mounted() {
    const relational_tab = this.el.querySelector(".inner_tab_list")
    const relational_tab_items = relational_tab.querySelectorAll("li")
    const  relational_buttons = this.el.querySelector(".inner_tab_slide_buttons")
    const count = relational_tab_items.length
    const tab_width = count * 200
    this.margin = 0
    this.first_tab_item = relational_tab_items[0]

    if (count > 3) {
      relational_buttons.style.display = "block"
    } else {
      relational_buttons.style.display = "none"
    }

    const buttons = relational_buttons.children
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
    // タブ押下時(updated)の位置の再設定
    setElement(this.first_tab_item, "marginLeft", this.margin)
  }
}

export default TabSlideScroll
