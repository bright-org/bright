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

const setButtonsDisplay = function(scrollerEl, thisEl, itemsSumWidth) {
  // 表示幅からスクロール操作ボタンを出すかを決定
  const width = getElWidth(thisEl)

  if (itemsSumWidth > width) {
    scrollerEl.style.display = "flex"
  } else {
    scrollerEl.style.display = "none"
  }
}

// 引数elの要素幅を取得する。autoなどの場合は親要素にさかのぼる
const getElWidth = function(el) {
  let width = 0

  // 幅取得できたときか、全要素を遡ったら終了する
  while(width == 0 && el != null) {
    width_value = el.clientWidth
    width_style = window.getComputedStyle(el).width

    if(width_value != 0) {
      width = width_value
    } else if(typeof width_style === 'string' && width_style.endsWith('px')) {
      width = parseInt(width_style)
    }

    el = el.parentElement
  }
  return width
}

const TabSlideScroll = {
  mounted() {
    // itemWidth: HTML側で指定されているタブ幅(200px)
    const itemWidth = 200
    const relational_tab = this.el.querySelector(".inner_tab_list")
    const relational_tab_items = relational_tab.querySelectorAll("li")
    this.relational_buttons = this.el.querySelector(".inner_tab_slide_buttons")
    // this.margin: スライドしている量。右矢印でマイナス側にずらして表示内容を変更している
    this.margin = 0
    this.first_tab_item = relational_tab_items[0]
    this.itemsSumWidth = relational_tab_items.length * itemWidth
    const buttons = this.relational_buttons.children

    // 表示設定
    setButtonsDisplay(this.relational_buttons, this.el, this.itemsSumWidth)

    // イベント設定
    buttons[1].addEventListener("click", () => {
      if (this.itemsSumWidth + this.margin > this.el.clientWidth) {
        const newMargin = this.margin - itemWidth
        animateElement(this.first_tab_item, "marginLeft", this.margin, newMargin, 250)
        this.margin = newMargin
      }
    })
    buttons[0].addEventListener("click", () => {
      if (this.margin < 0) {
        const newMargin = this.margin + itemWidth
        animateElement(this.first_tab_item, "marginLeft", this.margin, newMargin, 250)
        this.margin = newMargin
      }
    })
  },

  updated() {
    // タブ押下時(updated)の位置と表示の再設定
    setElementMargin(this.first_tab_item, "marginLeft", this.margin)
    setButtonsDisplay(this.relational_buttons, this.el, this.itemsSumWidth)
  }
}

export default TabSlideScroll
