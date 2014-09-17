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
  trs = south: document.getElementById("#{area}-stations-south").getElementsByTagName('tr')[index]
  trs.north =  document.getElementById("#{area}-stations-north").getElementsByTagName('tr')[index] if area != 'eb'
  for key, tr of trs
    for th in tr.getElementsByTagName('th')
      th.className = th.className.replace(/\ ?error\ ?/, '') + ' loading'
  xmlhttp = new XMLHttpRequest()
  xmlhttp.onreadystatechange = ->
    if (xmlhttp.readyState == 4)
      if(xmlhttp.status == 200)
        data = xmlhttp.responseXML
        window.data = data
        station = data.getElementsByTagName("station")[0]
        updateStationRows station, trs
      else
        for key, tr of trs
          for th in tr.getElementsByTagName('th')
            th.className = th.className.replace(/\ ?loading\ ?/, '') + " error"

  xmlhttp.open("GET", url, true);
  xmlhttp.send();

writeUrl = (abbr) ->
  url = "http://api.bart.gov/api/etd.aspx?cmd=etd&orig=#{abbr}&key=MW9S-E7SL-26DU-VV8V"

updateStationRows = (station, trs) ->
  estimates = splitEstimates station
  updateStationRow estimates.south, trs.south
  updateStationRow estimates.north, trs.north if trs.north

splitEstimates = (station) ->
  estimates =
    south: []
    north: []
  ests = station.getElementsByTagName('estimate')
  for estimate in ests
    parseEstimate(estimate)
    estimates[estimate.direction].push estimate if estimate.show
  estimates

extractText = (elem, tag) ->
  elem.getElementsByTagName(tag)[0].textContent.toLowerCase()

parseEstimate = (estimate) ->
  estimate.direction = extractText(estimate, 'direction')
  estimate.color     = extractText(estimate, 'color')
  estimate.minutes   = Number(extractText(estimate, 'minutes')) || 0
  estimate.show      = estimate.direction == 'south' || estimate.color == myLineColor

updateStationRow = (estimates, tr) ->
  removeThese = []
  for child in tr.childNodes
    if child.tagName == 'TD'
      removeThese.push child
    else if child.tagName == 'TH'
      child.className = child.className.replace(/\ ?error\ ?/, '').replace(/\ ?loading\ ?/, '')
  tr.removeChild(td) for td in removeThese
  addEstimateTd(tr, estimate) for estimate in estimates.sort(sortByMinutes)[0..9]

sortByMinutes = (a, b) -> a.minutes - b.minutes

addEstimateTd = (tr, estimate) ->
  td = document.createElement("td")
  td.className = estimate.color
  td.innerText = estimate.minutes
  tr.appendChild td
