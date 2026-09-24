document.addEventListener("DOMContentLoaded", () => {
  const schedule = document.querySelector(".schedule-scroll")
  const currentLine = document.querySelector(".time-axis .current-time-line")
  const programmes = [...document.querySelectorAll(".programme")]
  const nowLink = document.querySelector(".now-link")

  const centerOnCurrentTime = () => {
    if (!schedule || !currentLine) return false

    schedule.scrollTo({
      left: Math.max(0, currentLine.offsetLeft - schedule.clientWidth / 2),
      behavior: "smooth"
    })
    return true
  }

  const closeProgramme = (programme) => {
    programme.classList.remove("is-open")
    programme.dataset.pinned = "false"
    programme
      .querySelector(".programme-trigger")
      ?.setAttribute("aria-expanded", "false")
  }

  const closeOtherProgrammes = (current) => {
    programmes.forEach((programme) => {
      if (programme !== current) closeProgramme(programme)
    })
  }

  centerOnCurrentTime()

  nowLink?.addEventListener("click", (event) => {
    if (centerOnCurrentTime()) event.preventDefault()
  })

  programmes.forEach((programme) => {
    const popover = programme.querySelector(".programme-popover")
    const trigger = programme.querySelector(".programme-trigger")
    if (!popover) return

    const positionPopover = () => {
      const bounds = programme.getBoundingClientRect()
      const minimumLeft = schedule.getBoundingClientRect().left + 202
      const left = Math.min(
        bounds.left,
        window.innerWidth - popover.offsetWidth - 12
      )
      const top =
        bounds.bottom + 8 + popover.offsetHeight <= window.innerHeight
          ? bounds.bottom + 8
          : bounds.top - popover.offsetHeight - 8
      programme.style.setProperty(
        "--popover-left",
        `${Math.max(minimumLeft, left, 12)}px`
      )
      programme.style.setProperty("--popover-top", `${Math.max(12, top)}px`)
    }

    const activateProgramme = () => {
      const willOpen = !programme.classList.contains("is-open")
      programme.dataset.pinned = willOpen ? "true" : "false"
      window.setTimeout(() => {
        closeOtherProgrammes(programme)
        programme.classList.toggle("is-open", willOpen)
        programme.dataset.pinned = willOpen ? "true" : "false"
        trigger.setAttribute("aria-expanded", String(willOpen))
        if (willOpen) requestAnimationFrame(positionPopover)
      }, 0)
    }

    trigger.addEventListener("pointerdown", (event) => {
      event.preventDefault()
      trigger.dataset.pointerActivated = "true"
      activateProgramme()
    })
    trigger.addEventListener("click", () => {
      if (trigger.dataset.pointerActivated === "true") {
        delete trigger.dataset.pointerActivated
        return
      }

      activateProgramme()
    })
    programme.addEventListener("pointerenter", () => {
      closeOtherProgrammes(programme)
      programme.classList.add("is-open")
      trigger.setAttribute("aria-expanded", "true")
      requestAnimationFrame(positionPopover)
    })
    programme.addEventListener("pointerleave", () => {
      if (programme.dataset.pinned !== "true") closeProgramme(programme)
    })
    programme.addEventListener("focusin", () => {
      closeOtherProgrammes(programme)
      programme.classList.add("is-open")
      trigger.setAttribute("aria-expanded", "true")
      requestAnimationFrame(positionPopover)
    })
    schedule?.addEventListener("scroll", () => {
      if (programme.classList.contains("is-open")) positionPopover()
    })
    window.addEventListener("resize", positionPopover)
  })

  document.addEventListener("click", (event) => {
    if (!event.target.closest(".programme")) programmes.forEach(closeProgramme)
  })
  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") programmes.forEach(closeProgramme)
  })
})
