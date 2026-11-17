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
const HOARD_DISPLAY_ORDER = Object.freeze({ gems: 0, art: 1, magic: 2 })

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

export function weightedSelection(entries, random = Math.random) {
  const weightedEntries = entries.filter(({ weight }) => Number(weight) > 0)
  const totalWeight = weightedEntries.reduce((total, entry) => total + Number(entry.weight), 0)
  if (totalWeight === 0) return undefined

  const selection = random() * totalWeight
  let cumulativeWeight = 0

  for (const entry of weightedEntries) {
    cumulativeWeight += Number(entry.weight)
    if (selection < cumulativeWeight) return entry
  }

  return weightedEntries.at(-1)
}

export function sampleBoundedGaussian(minimum, maximum, random = Math.random) {
  if (minimum === maximum) return minimum

  const mean = (minimum + maximum) / 2
  const standardDeviation = (maximum - minimum) / 6

  while (true) {
    let firstUniform = random()
    while (firstUniform === 0) firstUniform = random()

    const secondUniform = random()
    const standardNormal = Math.sqrt(-2 * Math.log(firstUniform)) * Math.cos(2 * Math.PI * secondUniform)
    const draw = mean + standardDeviation * standardNormal

    if (draw >= minimum && draw <= maximum) return Math.round(draw)
  }
}

export function inclusiveUniformInteger(minimum, maximum, random = Math.random) {
  return minimum + Math.floor(random() * (maximum - minimum + 1))
}

export function generateTreasureHoard(data, challengeRating, random = Math.random) {
  const category = weightedSelection(
    data.categories.filter((candidate) => candidate.challenge_rating === challengeRating),
    random
  )
  if (!category) return []

  const entries = []
  if (category.valuable_type && category.valuable_value) {
    const entryType = category.valuable_type === "gems" ? "Gemstone" : "Art"
    const choices = data.valuables.filter((entry) => entry.entry_type === entryType && entry.value === category.valuable_value)
    const count = sampleBoundedGaussian(category.valuable_min_count, category.valuable_max_count, random)

    for (let index = 0; index < count; index += 1) {
      const choice = weightedSelection(choices, random)
      if (!choice) continue

      const value = choice.value.replace(/\s+gp$/i, "gp")
      entries.push({
        kind: category.valuable_type,
        text: `${value} ${category.valuable_type === "gems" ? "gem" : "art"} ${choice.description}`
      })
    }
  }

  if (category.item_type) {
    const choices = data.magic_items.filter((entry) => entry.item_type === category.item_type)
    const count = inclusiveUniformInteger(category.item_min, category.item_max, random)

    for (let index = 0; index < count; index += 1) {
      const choice = weightedSelection(choices, random)
      if (!choice) continue

      entries.push({ kind: "magic", text: choice.name, link: choice.link })
    }
  }

  return entries.sort((left, right) => {
    const categoryDifference = HOARD_DISPLAY_ORDER[left.kind] - HOARD_DISPLAY_ORDER[right.kind]
    return categoryDifference || left.text.localeCompare(right.text, undefined, { sensitivity: "base" })
  })
}

export function consolidateHoardEntries(entries) {
  const entriesByIdentity = new Map()

  for (const entry of entries) {
    const identity = JSON.stringify([entry.kind, entry.text, entry.link ?? null])
    const consolidatedEntry = entriesByIdentity.get(identity)

    if (consolidatedEntry) {
      consolidatedEntry.count += entry.count ?? 1
    } else {
      entriesByIdentity.set(identity, { ...entry, count: entry.count ?? 1 })
    }
  }

  return [...entriesByIdentity.values()]
}

function hoardEntryPrefix(entry) {
  return entry.count > 1 ? `${entry.count}x ` : ""
}

export function hoardMarkdown(entries) {
  if (entries.length === 0) return "Empty hoard"

  return entries.map((entry) => entry.kind === "magic"
    ? `- ${hoardEntryPrefix(entry)}[${entry.text}](${entry.link})`
    : `- ${hoardEntryPrefix(entry)}${entry.text}`).join("\n")
}

export default class extends Controller {
  static targets = [
    "challengeRating", "copyStatus", "generateButton", "results",
    "hoardChallengeRating", "hoardCopyStatus", "hoardGenerateButton", "hoardResults"
  ]
  static values = { hoardData: Object }

  connect() {
    this.updateButton()
    this.updateHoardButton()
  }

  updateButton() {
    this.generateButtonTarget.disabled = this.challengeRatingTarget.value === ""
  }

  updateHoardButton() {
    this.hoardGenerateButtonTarget.disabled = this.hoardChallengeRatingTarget.value === ""
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

  generateHoards(event) {
    event.preventDefault()

    const challengeRating = this.hoardChallengeRatingTarget.value
    if (!TreasureHoardCategoryChallengeRatings.includes(challengeRating)) return

    this.hoardCopyStatusTarget.textContent = ""
    const results = document.createElement("div")
    results.className = "treasure-hoard-result-list"

    for (let index = 0; index < 3; index += 1) {
      const entries = consolidateHoardEntries(generateTreasureHoard(this.hoardDataValue, challengeRating))
      const row = document.createElement("div")
      row.className = "treasure-hoard-result"

      if (entries.length === 0) {
        const empty = document.createElement("p")
        empty.textContent = "Empty hoard"
        row.append(empty)
      } else {
        const list = document.createElement("ul")
        for (const entry of entries) {
          const item = document.createElement("li")
          const prefix = hoardEntryPrefix(entry)
          if (entry.kind === "magic") {
            const link = document.createElement("a")
            link.href = entry.link
            link.textContent = entry.text
            if (prefix) item.append(prefix)
            item.append(link)
          } else {
            item.textContent = `${prefix}${entry.text}`
          }
          list.append(item)
        }
        row.append(list)
      }

      row.append(this.hoardCopyButton(hoardMarkdown(entries), index + 1))
      results.append(row)
    }

    this.hoardResultsTarget.replaceChildren(results)
    this.hoardGenerateButtonTarget.focus()
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

  async copyHoard(event) {
    const copyText = event.currentTarget.dataset.copyText
    const hoardNumber = event.currentTarget.dataset.hoardNumber
    this.hoardCopyStatusTarget.textContent = ""

    try {
      await navigator.clipboard.writeText(copyText)
      this.hoardCopyStatusTarget.textContent = `Treasure hoard ${hoardNumber} copied to clipboard`
    } catch {
      this.hoardCopyStatusTarget.textContent = `Unable to copy treasure hoard ${hoardNumber} to clipboard`
    }
  }

  hoardCopyButton(copyText, hoardNumber) {
    const button = this.copyButton("")
    delete button.dataset.coinString
    button.dataset.action = "loot#copyHoard"
    button.dataset.copyText = copyText
    button.dataset.hoardNumber = hoardNumber
    button.setAttribute("aria-label", `Copy treasure hoard ${hoardNumber} to clipboard`)
    return button
  }
}

const TreasureHoardCategoryChallengeRatings = Object.freeze(["0-4", "5-10", "11-16", "17+"])
