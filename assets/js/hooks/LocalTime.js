// ブラウザのタイムテーブルで日時周りを表示するためのHook
//
// - Hookしているタグの`data-iso`でiso-8601形式で日時(UTC)を渡す
// - 表示対象タグの`data-local-time`でフォーマットを指定する
//   - 必要に応じて phx-update="ignore" をつける
//
// Example
//
//   <div
//     id="exmaple"
//     phx-hook="LocalTime"
//     phx-update="ignore"
//     data-iso={NaiveDateTime.to_iso8601(hoge.inserted_at)}
//   >
//     <p data-local-time="%x %H:%M"></p>
//   </div>

const LocalTime = {
  renderLocalTime(elm, date, format) {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hour = String(date.getHours()).padStart(2, '0')
    const minute = String(date.getMinutes()).padStart(2, '0')

    // NOTE:
    //   日時フォーマットは適宜追加してください。
    //   明確な命名がない場合はstrftimeが参考になります。
    //   see: https://hexdocs.pm/elixir/1.13/Calendar.html#strftime/3
    switch(format) {
      case '%x %H:%M':
        const content = `${year}-${month}-${day} ${hour}:${minute}`
        elm.innerHTML = content
        break
      default:
        console.error("LocalTime: Invalid format given")
    }
  },
  mounted() {
    // getTimezoneOffset()の取得結果からローカルタイムに変更
    const formatIso = this.el.dataset.iso
    const date = new Date(formatIso)
    const offsetMinute = (new Date()).getTimezoneOffset()
    const localDate = new Date(date.setMinutes(date.getMinutes() - offsetMinute))
    const elms = this.el.querySelectorAll("[data-local-time]")

    elms.forEach((elm) => {
      this.renderLocalTime(elm, localDate, elm.dataset.localTime)
    })
  }
}

export default LocalTime
