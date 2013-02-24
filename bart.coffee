$ ->
  sfStations = $('#data').data('stations-sf')
  fetchStationData(abbr, index) for abbr, index in sfStations

fetchStationData = (abbr, index) ->
  url = writeUrl(abbr)
  trs =
    south: $("tbody#sf-stations-south tr:nth-child(#{1 + index})")
    north: $("tbody#sf-stations-north tr:nth-child(#{1 + index})")
  $.get url, (data) ->
    station = $(data).children('root').children('station')
    updateStationRows station, trs

writeUrl = (abbr) ->
  url = "http://api.bart.gov/api/etd.aspx?cmd=etd&orig=#{abbr}&key=MW9S-E7SL-26DU-VV8V"

updateStationRows = (station, trs) ->
  estimates = splitEstimates station
  updateStationRow estimates.south, trs.south
  updateStationRow estimates.north, trs.north

splitEstimates = (station) ->
  estimates = {south: [], north: []}
  for estimate in station.children('etd').children('estimate')[0..19]
    parseEstimate(estimate)
    estimates[estimate.direction].push estimate if estimate.show
  estimates

parseEstimate = (estimate) ->
  $estimate         = $(estimate)
  estimate.direction = $estimate.children('direction').text().toLowerCase()
  estimate.color     = $estimate.children('color').text().toLowerCase()
  estimate.minutes   = Number($estimate.children('minutes').text()) || 0
  estimate.show      = estimate.direction == 'south' || estimate.color == 'blue'

updateStationRow = (estimates, tr) ->
  tr.children('td').detach()
  addEstimateTd(tr, estimate) for estimate in estimates.sort(sortByMinutes)

sortByMinutes = (a, b) -> a.minutes - b.minutes

addEstimateTd = (tr, estimate) ->
  $("<td class='#{estimate.color}'>#{estimate.minutes}</td>").appendTo(tr)
