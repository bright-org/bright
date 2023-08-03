function animateElement(element, property, startValue, endValue, duration) {
  let startTime = null;
  function step(timestamp) {
    if (!startTime) startTime = timestamp;
    const progress = timestamp - startTime;
    const percentage = Math.min(progress / duration, 1);
    const currentValue = startValue + percentage * (endValue - startValue);
    element.style[property] = currentValue + "px";
    if (progress < duration) {
      requestAnimationFrame(step);
    }
  }
  requestAnimationFrame(step);
}

let relational_user_tab = document.querySelector("#relational_user_tab");
let relational_user_tab_item = relational_user_tab.querySelectorAll("li");
let relational_user_buttons = document.querySelector("#relational_user_tab_buttons");
let count = relational_user_tab_item.length;
let tab_width = count * 200;
let margin = 0;

if (count > 3) {
  relational_user_buttons.style.display = "block";
} else {
  relational_user_buttons.style.display = "none";
}

let buttons = relational_user_buttons.children;
buttons[0].addEventListener("click", function () {
  if (tab_width + margin > 600) {
    margin = margin - 200;
    animateElement(relational_user_tab_item[0], "marginLeft", margin + 200, margin, 250);
  }
});

buttons[1].addEventListener("click", function () {
  if (margin < 0) {
    margin = margin + 200;
    animateElement(relational_user_tab_item[0], "marginLeft", margin - 200, margin, 250);
  }
});
