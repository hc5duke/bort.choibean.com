queryObject = () ->
  result = {}
  queryString = location.search.slice(1)
  re = /([^&=]+)=([^&]*)/g
  while (m = re.exec(queryString))
    result[decodeURIComponent(m[1])] = decodeURIComponent(m[2])
  result

myLineColor = 'yellow'

window.onload = ->
  $("#sf h3 a.btn.#{myLineColor}").hide()
  $('#refresh').click (e) ->
    refresh()
    e.preventDefault()
  refresh()

refresh = ->
  refreshDirection('sf')
  refreshDirection('eb')

refreshDirection = (direction) ->
  fetchStationData(abbr, index, direction) for abbr, index in $('#data').data("stations-#{direction}")

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
  updateStationRow estimates.south, trs.south
  updateStationRow estimates.north, trs.north if trs.north

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
  tr.children('td').detach()
  tr.children('th').removeClass('loading')
  addEstimateTd(tr, estimate) for estimate in estimates.sort(sortByMinutes)[0..9]

sortByMinutes = (a, b) -> a.minutes - b.minutes

addEstimateTd = (tr, estimate) ->
  $("<td class='#{estimate.color}'>#{estimate.minutes}</td>").appendTo(tr)
