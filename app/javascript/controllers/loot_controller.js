import { Controller } from "@hotwired/stimulus"

export const MAXIMUM_CP_BY_CHALLENGE_RATING = Object.freeze({
  "1/8": 5,
  "1/4": 50,
  "1/2": 100,
  "1": 300,
  "2": 800,
  "3": 1300,
  "4": 1800,
  "5": 2000,
  "6": 4800,
  "7": 7600,
  "8": 10400,
  "9": 13200,
  "10": 16000,
  "11": 20000,
  "12": 56000,
  "13": 92000,
  "14": 128000,
  "15": 164000,
  "16": 200000,
  "17+": 1600000
})

export const COIN_VALUES = Object.freeze([
  Object.freeze({ name: "CP", value: 1 }),
  Object.freeze({ name: "SP", value: 10 }),
  Object.freeze({ name: "GP", value: 100 }),
  Object.freeze({ name: "PP", value: 1000 })
])

const DISPLAY_ORDER = ["PP", "GP", "SP", "CP"]

export function samplePurse(maximum, random = Math.random) {
  const mean = maximum / 2
  const standardDeviation = maximum / 6

  while (true) {
    let firstUniform = random()
    while (firstUniform === 0) firstUniform = random()

    const secondUniform = random()
    const standardNormal = Math.sqrt(-2 * Math.log(firstUniform)) * Math.cos(2 * Math.PI * secondUniform)
    const draw = mean + standardDeviation * standardNormal

    if (draw >= 0 && draw <= maximum) return Math.round(draw)
  }
}

export function generateCoins(purse, random = Math.random) {
  const counts = Object.fromEntries(COIN_VALUES.map(({ name }) => [name, 0]))
  let remaining = purse

  while (true) {
    const coin = COIN_VALUES[Math.floor(random() * COIN_VALUES.length)]
    if (remaining - coin.value < 0) return counts

    counts[coin.name] += 1
    remaining -= coin.value
  }
}

export function formatCoins(counts) {
  const displayedCoins = DISPLAY_ORDER
    .filter((name) => counts[name] > 0)
    .map((name) => `${counts[name]} ${name}`)

  return displayedCoins.length > 0 ? displayedCoins.join(", ") : "Empty pockets"
}

export default class extends Controller {
  static targets = ["challengeRating", "copyStatus", "generateButton", "results"]

  connect() {
    this.updateButton()
  }

  updateButton() {
    this.generateButtonTarget.disabled = this.challengeRatingTarget.value === ""
  }

  generate(event) {
    event.preventDefault()

    const maximum = MAXIMUM_CP_BY_CHALLENGE_RATING[this.challengeRatingTarget.value]
    if (maximum === undefined) return

    this.copyStatusTarget.textContent = ""

    const list = document.createElement("ul")
    list.className = "loot-result-list"

    for (let index = 0; index < 3; index += 1) {
      const purse = samplePurse(maximum)
      const coinString = formatCoins(generateCoins(purse))
      const result = document.createElement("li")
      const resultText = document.createElement("span")

      resultText.textContent = coinString
      result.append(resultText, this.copyButton(coinString))
      list.append(result)
    }

    this.resultsTarget.replaceChildren(list)
    this.generateButtonTarget.focus()
  }

  async copy(event) {
    const coinString = event.currentTarget.dataset.coinString
    this.copyStatusTarget.textContent = ""

    try {
      await navigator.clipboard.writeText(coinString)
      this.copyStatusTarget.textContent = `${coinString} copied to clipboard`
    } catch {
      this.copyStatusTarget.textContent = `Unable to copy ${coinString} to clipboard`
    }
  }

  copyButton(coinString) {
    const button = document.createElement("button")
    const icon = document.createElementNS("http://www.w3.org/2000/svg", "svg")
    const path = document.createElementNS("http://www.w3.org/2000/svg", "path")

    button.type = "button"
    button.className = "loot-copy-button"
    button.dataset.action = "loot#copy"
    button.dataset.coinString = coinString
    button.setAttribute("aria-label", `Copy ${coinString} to clipboard`)

    icon.setAttribute("aria-hidden", "true")
    icon.setAttribute("focusable", "false")
    icon.setAttribute("viewBox", "0 0 24 24")
    path.setAttribute("d", "M8 7V5a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2h-2M5 8h9a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-9a2 2 0 0 1 2-2Z")
    icon.append(path)
    button.append(icon)

    return button
  }
}
