// If your components require any hooks or custom uploaders, or if your pages
// require connect parameters, uncomment the following lines and declare them as
// such:
//
// import * as Hooks from "./hooks";
// import * as Params from "./params";
// import * as Uploaders from "./uploaders";
import  * as hooks from "./hooks"
(function () {
  window.storybook = hooks
})()

document.addEventListener("DOMContentLoaded", () => {
  // storybookでMaterialIconsを読み込む
  // linkを記述する場所がないためjsで追加する
  const head = document.head
  const link = document.createElement("link")
  link.href = "https://fonts.googleapis.com/css?family=Material+Icons%7CMaterial+Icons+Outlined%7CMaterial+Icons+Round%7CMaterial+Icons+Sharp%7CMaterial+Icons+Two+Tone"
  link.rel="stylesheet"
  head.appendChild(link)
})


// If your components require alpinejs, you'll need to start
// alpine after the DOM is loaded and pass in an onBeforeElUpdated
//
// import Alpine from 'alpinejs'
// window.Alpine = Alpine
// document.addEventListener('DOMContentLoaded', () => {
//   window.Alpine.start();
// });

// (function () {
//   window.storybook = {
//     LiveSocketOptions: {
//       dom: {
//         onBeforeElUpdated(from, to) {
//           if (from._x_dataStack) {
//             window.Alpine.clone(from, to)
//           }
//         }
//       }
//     }
//   };
// })();
