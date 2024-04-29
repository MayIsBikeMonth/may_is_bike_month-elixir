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
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

import TimeParser from "./time_parser"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.currentUnitPreference = () => {
  let unitPreference = localStorage.getItem("unitPreference")
  if (unitPreference === null || unitPreference !== "metric") {
    unitPreference = "imperial"
  } else {
    unitPreference = "metric"
  }
  localStorage.setItem("unitPreference", unitPreference)
  return unitPreference
}

window.toggleUnitPreference = (event = false) => {
  event && event.preventDefault()
  const newUnit = currentUnitPreference() === "metric" ? "imperial" : "metric"
  localStorage.setItem("unitPreference", newUnit)
  showPreferredUnit()
  // console.log(newUnit)
}

window.showPreferredUnit = () => {
  const unit = currentUnitPreference()
  document.querySelectorAll(`.unit-${unit}`).forEach(el => el.classList.remove('hidden'))
  const hiddenUnit = unit === "metric" ? "imperial" : "metric"
  document.querySelectorAll(`.unit-${hiddenUnit}`).forEach(el => el.classList.add('hidden'))
}

// Add the click selector to the toggle button
document.querySelectorAll("a.toggleUnitPreference").forEach(el => el.addEventListener("click", toggleUnitPreference))

document.addEventListener('DOMContentLoaded', function() {
  showPreferredUnit()
  window.addEventListener("phx:update", function() { showPreferredUnit() })
})

toggleActivities = (_event) => {
  document.querySelectorAll(".activityList").forEach(el => el.classList.toggle("hidden"))
}
document.querySelector('#toggleIndividualActivities')?.addEventListener("click", toggleActivities)

window.updateStravaInBackground = async function() {
  const response = await fetch("/update_strava");
  const update_response = await response.json();
  console.log(update_response);
}

document.addEventListener('DOMContentLoaded', function() {
  if (!window.timeParser) { window.timeParser = new TimeParser() }
  window.timeParser.localize()
  window.addEventListener("phx:update", function() { window.timeParser.localize() })
  updateStravaInBackground()
  setInterval(function() {
    updateStravaInBackground()
  }, 650000); // Update strava in background every 10+ minutes
})
