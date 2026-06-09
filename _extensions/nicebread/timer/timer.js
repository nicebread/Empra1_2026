// Credit: Mateusz Rybczonec

const FULL_DASH_ARRAY = 2 * Math.PI * 45;
const THRESHOLDS = [10, 5];

function initializeTimer(containerId, timeLimit, startOn, size = "100%", soundStr = "false") {

  let active = true;
  let timePassed = 0;
  let timeLeft = timeLimit;
  let timerId = null;
  const playSound = (soundStr === "true");

  let audioObj = null;
  if (playSound) {
    let soundUrl = window.quartoTimerSound;
    if (!soundUrl) {
      soundUrl = "bing.wav";
      const scripts = document.getElementsByTagName("script");
      for (let i = 0; i < scripts.length; i++) {
        if (scripts[i].src && scripts[i].src.includes("timer.js")) {
          soundUrl = scripts[i].src.replace("timer.js", "bing.wav");
          break;
        }
      }
    }
    audioObj = new Audio(soundUrl);
  }

  let timerSize = "300px";
  if (size.endsWith("%")) {
    const percent = parseFloat(size);
    if (!isNaN(percent)) {
      timerSize = `${(percent / 100) * 300}px`;
    }
  } else {
    timerSize = size;
  }

  document.getElementById(containerId).innerHTML = `
    <div class="base-timer" style="width: ${timerSize}; height: ${timerSize};">
      <svg id="${containerId}-timer-svg" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
          <circle id="${containerId}-circle" class="base-timer__path-elapsed" cx="50" cy="50" r="45"></circle>
          <path
            id="${containerId}-path-remaining"
            stroke-dasharray="${FULL_DASH_ARRAY}"
            class="base-timer__path-remaining"
            d="M 50 50 m 0 -45 a 45 45 0 0 1 0 90 a 45 45 0 0 1 0 -90">
          </path>
          <text id="${containerId}-label" x="50%" y ="50%" dominant-baseline="middle" text-anchor="middle">
            ${formatTime(timeLeft)}
          </text>
          <g id="${containerId}-playpause" class="timer-playpause" transform="translate(44, 16) scale(0.5)">
            <circle class="timer-playpause-bg" cx="12" cy="12" r="16"></circle>
            <path id="${containerId}-play-icon" class="timer-playpause-icon" d="M8 5 L19 12 L8 19 Z"></path>
            <path id="${containerId}-pause-icon" class="timer-playpause-icon" d="M9 5 V19 M15 5 V19"></path>
          </g>
          <g id="${containerId}-reset" class="timer-reset" transform="translate(44, 72) scale(0.5)">
            <circle class="timer-reset-bg" cx="12" cy="12" r="16"></circle>
            <path class="timer-reset-icon" d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"></path>
            <path class="timer-reset-icon" d="M3 3v5h5"></path>
          </g>
      </svg>
    </div>
    `;

  document.getElementById(`${containerId}-playpause`).addEventListener("click", (event) => {
    event.stopPropagation();
    toggleTimer();
  });

  document.getElementById(`${containerId}-reset`).addEventListener("click", (event) => {
    event.stopPropagation();
    resetTimer();
  });

  if (startOn === "interaction") {
    active = false;
    startOn = "slide";
  }

  updatePlayPauseIcon();
  updateCircleFill();

  function startTimer() {
    if (active && (startOn === 'presentation' || (startOn === 'slide' && !isHidden()))) {
      timePassed += 1;
      timeLeft = timeLimit - timePassed;

      document.getElementById(`${containerId}-label`).innerHTML = formatTime(timeLeft);
      setCircleDasharray();
      setRemainingPathColor(timeLeft);

      if (timeLeft === 0 && playSound && audioObj) {
        audioObj.currentTime = 0;
        audioObj.play().catch(e => console.warn("Sound konnte nicht abgespielt werden:", e));
      }
    }
    if (timeLeft > 0) {
      timerId = setTimeout(startTimer, 1000);
    } else {
      timerId = null;
    }
  }

  startTimer();

  function isHidden() {
    let el = document.getElementById(containerId);
    let ancestor = el.parentNode;
    while (ancestor && ancestor.tagName !== "SECTION") {
      ancestor = ancestor.parentNode;
    }
    if (!ancestor) return true;
    if (ancestor.hidden) return true;
    const style = window.getComputedStyle(ancestor);
    return style.display === "none";
  }

  function toggleTimer() {
    if (!active && audioObj) {
      audioObj.muted = true;
      let playPromise = audioObj.play();
      if (playPromise !== undefined) {
        playPromise.then(() => {
          audioObj.pause();
          audioObj.currentTime = 0;
          audioObj.muted = false;
        }).catch(e => {
          audioObj.muted = false;
        });
      }
    }

    active = !active;
    updateCircleFill();
    updatePlayPauseIcon();
  }

  function resetTimer() {
    timePassed = 0;
    timeLeft = timeLimit;
    active = false;

    document.getElementById(`${containerId}-label`).innerHTML = formatTime(timeLeft);
    setCircleDasharray();

    const pathId = `${containerId}-path-remaining`;
    for (let i = 0; i < THRESHOLDS.length; i += 1) {
      document.getElementById(pathId).classList.remove(`lvl${i - 1}`);
      document.getElementById(pathId).classList.remove(`lvl${i}`);
    }

    updateCircleFill();
    updatePlayPauseIcon();

    if (timerId === null) {
      startTimer();
    }
  }

  function updateCircleFill() {
    document.getElementById(`${containerId}-circle`).style.fill = active ? '' : '#fcb';
  }

  function updatePlayPauseIcon() {
    document.getElementById(`${containerId}-play-icon`).style.display = active ? "none" : "block";
    document.getElementById(`${containerId}-pause-icon`).style.display = active ? "block" : "none";
  }

  function formatTime(time) {
    const minutes = Math.floor(time / 60);
    let seconds = time % 60;
    if (seconds < 10) {
      seconds = `0${seconds}`;
    }
    return `${minutes}:${seconds}`;
  }

  function setRemainingPathColor(timeLeft) {
    const pathId = `${containerId}-path-remaining`;
    for (let i = 0; i < THRESHOLDS.length; i += 1) {
      if (timeLeft < THRESHOLDS[i]) {
        document.getElementById(pathId).classList.remove(`lvl${i - 1}`);
        document.getElementById(pathId).classList.add(`lvl${i}`);
      }
    }
  }

  function setCircleDasharray() {
    let circle_proportions = timeLeft / timeLimit * FULL_DASH_ARRAY + " ";
    circle_proportions += (1 - timeLeft / timeLimit) * FULL_DASH_ARRAY;
    document
      .getElementById(`${containerId}-path-remaining`)
      .setAttribute("stroke-dasharray", circle_proportions);
  }
}
