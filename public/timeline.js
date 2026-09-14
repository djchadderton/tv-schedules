document.addEventListener("DOMContentLoaded", () => {
  if (!scheduleData || scheduleData.length === 0) {
    console.log("No schedule data found.")
    return
  }

  const container = document.getElementById("timeline-container")
  let currentOffset = 0 // Tracks the cumulative start time offset

  // 1. Group programmes by channel first to create the row structure
  const channels = {}
  scheduleData.forEach((programme) => {
    const parsed_programme = JSON.parse(programme)
    const channel = parsed_programme.channel_name
    if (!channels[channel]) {
      channels[channel] = []
    }
    channels[channel].push(parsed_programme)
  })

  Object.keys(channels)
    .sort()
    .forEach((channelName) => {
      const sortedPrograms = channels[channelName].sort((a, b) => {
        // Sort by start time string comparison (assuming consistent format like HH:MM)
        return a.starts_at.localeCompare(b.starts_at)
      })

      // 2. Create the channel track row
      const trackRow = document.createElement("div")
      trackRow.className = "channel-track"
      trackRow.setAttribute("data-channel", channelName)

      let channelOffset = 0 // Reset offset for this new channel track

      sortedPrograms.forEach((programme) => {
        // --- CORE CALCULATIONS ---

        // A. Calculate the exact start time (offset)
        // This requires converting time strings (H:M) into minutes/pixels.
        // For simplicity, let's assume a function `timeToOffset` exists:
        const startMinutes = timeToMinutes(programme.starts_at)
        const startOffset = calculatePixelOffset(startMinutes, channelOffset)

        // B. Calculate the duration width
        const endMinutes = timeToMinutes(programme.ends_at)

        const durationMinutes = () => {
          if (endMinutes < startMinutes) {
            return 24 * 60 - startMinutes + endMinutes // Wrap around midnight
          } else {
            return endMinutes - startMinutes
          }
        }
        const width = calculatePixelWidth(durationMinutes)

        // C. Create the program block element
        const block = document.createElement("div")
        block.className = "program-block"
        block.textContent = `${programme.title} (${programme.starts_at} - ${programme.ends_at})`

        // D. Apply the calculated CSS properties
        block.style.left = `${startOffset}px`
        block.style.width = `${width}px`

        trackRow.appendChild(block)

        // E. Update tracker
        channelOffset += width
      })

      container.appendChild(trackRow)
    })
})
/**
 * NOTE: The functions below are placeholders. You MUST implement the logic
 * to convert time strings (H:M) into a quantifiable unit (minutes from the day's start)
 * and relate that unit to pixel/percentage dimensions.
 *
 * 1. timeToMinutes: Converts "19:30" to 1170 (minutes from midnight)
 * 2. calculatePixelOffset: Takes the absolute start minute and converts it to 'left' pixels.
 * 3. calculatePixelWidth: Takes the duration in minutes and converts it to 'width' pixels.
 */
function timeToMinutes(timeStr) {
  // Logic to parse "HH:MM" to total minutes
  // e.g., '19:30' -> 1170
  const [hours, minutes, _] = timeStr.split("T")[1].split(":").map(Number)
  return hours * 60 + minutes
}

function calculatePixelOffset(minutesFromMidnight, channelStartOffset) {
  // 1. Determine the total time span (e.g., 12 hours * 60 minutes = 720 minutes)
  // 2. Calculate the percentage or pixel count for the given minutes.
  // Example: Assuming 1 hour = 100 pixels, offset = (minutes / 60) * 100
  return (minutesFromMidnight / 720) * 100 // If using percentages
  // return "0px" // Placeholder
}

function calculatePixelWidth(durationMinutes) {
  // Example: Assuming 1 minute = 10 pixels.
  return durationMinutes * 10
}
