// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import  {Hooks} from "./hooks"

import "flowbite/dist/flowbite.phoenix.js"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket


// shows alert if editting
window.addEventListener('phx:form-edit-start', (_info) => {
  document.body.classList.add('maybe-editting')
  document.body.classList.add('pointer-events-none')
})

window.addEventListener('phx:form-edit-end', (_info) => {
  document.body.classList.remove('maybe-editting')
  document.body.classList.remove('pointer-events-none')
})

window.addEventListener('click', (event) => {
  // alert用途外であればreturn
  if(!document.body.classList.contains('maybe-editting')) { return }
  if(event.target.tagName != 'HTML') { return }

  const message = '現在入力中です。他の操作を行うと入力内容が保存されない可能性があります。'

  if(confirm(message)) {
    document.body.classList.remove('maybe-editting')
    document.body.classList.remove('pointer-events-none')

    // event.targetはpointer-events-none状態では全体(HTML)をさすため、現在位置要素を特定してclick()を実行
    document.elementFromPoint(event.clientX, event.clientY).click()
  }
})
