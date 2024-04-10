const hour = document.getElementById('hour')
const minute = document.getElementById('minute')
const second = document.getElementById('second')
const day = document.getElementById('day')

var monthName = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
]
const clock = setInterval(function time() {
    let today = new Date()
    let m = today.getMonth()
    let d = today.getDate()
    let y = today.getFullYear()
    let h = today.getHours()
    let min = today.getMinutes()
    let sec = today.getSeconds()

    day.innerHTML = `${d} ${monthName[m]} ${y}`
    hour.textContent = h
    minute.innerText = min
    second.innerText = sec
})