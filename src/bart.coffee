queryObject = () ->
  result = {}
  queryString = location.search.slice(1)
  re = /([^&=]+)=([^&]*)/g
  while (m = re.exec(queryString))
    result[decodeURIComponent(m[1])] = decodeURIComponent(m[2])
  result

myLineColor = 'yellow'

window.onload = ->
  refresh()
  document.getElementById('refresh').onclick = (e) ->
    refresh()
    e.preventDefault()

refresh = ->
  refreshDirection('sf')
  refreshDirection('eb')

refreshDirection = (direction) ->
  data = JSON.parse(document.getElementById('data').dataset["stations#{direction}"])
  for abbr, index in data
    fetchStationData(abbr, index, direction)

fetchStationData = (abbr, index, area) ->
  url = writeUrl(abbr)
  trs =
    south: $("tbody##{area}-stations-south tr:nth-child(#{1 + index})")
    north: $("tbody##{area}-stations-north tr:nth-child(#{1 + index})")
  delete trs.north if area == 'eb'
  tr.children('th').addClass('loading') for key, tr of trs
  $.get url, (data) ->
    station = $(data).children('root').children('station')
    updateStationRows station, trs

writeUrl = (abbr) ->
  url = "http://api.bart.gov/api/etd.aspx?cmd=etd&orig=#{abbr}&key=MW9S-E7SL-26DU-VV8V"

updateStationRows = (station, trs) ->
  estimates = splitEstimates station
  updateStationRow estimates.south, trs.south[0]
  updateStationRow estimates.north, trs.north[0] if trs.north

splitEstimates = (station) ->
  estimates =
    south: []
    north: []
  for estimate in station.children('etd').children('estimate')
    parseEstimate(estimate)
    estimates[estimate.direction].push estimate if estimate.show
  estimates

parseEstimate = (estimate) ->
  $estimate         = $(estimate)
  estimate.direction = $estimate.children('direction').text().toLowerCase()
  estimate.color     = $estimate.children('color').text().toLowerCase()
  estimate.minutes   = Number($estimate.children('minutes').text()) || 0
  estimate.show      = estimate.direction == 'south' || estimate.color == myLineColor
  estimate.show      = estimate.direction == 'south' || estimate.color == myLineColor

updateStationRow = (estimates, tr) ->
  removeThese = []
  for child in tr.childNodes
    if child.tagName == 'TD'
      removeThese.push child
    else if child.tagName == 'TH'
      child.className = child.className.replace(/\ ?loading\ ?/, '')
  tr.removeChild(td) for td in removeThese
  addEstimateTd(tr, estimate) for estimate in estimates.sort(sortByMinutes)[0..9]

sortByMinutes = (a, b) -> a.minutes - b.minutes

addEstimateTd = (tr, estimate) ->
  td = document.createElement("td")
  td.className = estimate.color
  td.innerText = estimate.minutes
  tr.appendChild td
