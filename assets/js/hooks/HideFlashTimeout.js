// 一定時間後にフラッシュメッセージを非表示にする
// <div phx-hook="HideFlashTimeout" data-timeout=3000 data-kind="info">
const HideFlashTimeout = {
  mounted() {
    timeout = this.el.dataset.timeout || 3000
    kind = this.el.dataset.kind || 'info'
    setTimeout(() => {
      this.pushEvent('lv:clear-flash', {value: {key: kind}})
      this.el.classList.add("hidden")
    }, timeout)
  }
}

export default HideFlashTimeout
