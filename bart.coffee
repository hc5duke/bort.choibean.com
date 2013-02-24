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

updateStationRow = (estimates, tr) ->
  tr.children('td').detach()
  addEstimateTd(tr, estimate) for estimate in estimates.sort(numericSort)

splitEstimates = (station) ->
  estimates = {south: [], north: []}
  for estimate in station.children('etd').children('estimate')[0..19]
    direction = $(estimate).children('direction').text().toLowerCase()
    color = $(estimate).children('color').text().toLowerCase()
    mins = Number($(estimate).children('minutes').text()) || 0
    if direction == 'south' || color == 'blue'
      estimates[direction].push [mins, estimate]
  estimates

numericSort = (a, b) -> a[0] - b[0]

addEstimateTd = (tr, arr) ->
  mins  = arr[0]
  est   = arr[1]
  hexcolor = $(est).children('hexcolor').text()
  td    = $("<td>#{mins}</td>")
  td.css('background-color', hexcolor)
  td.appendTo(tr)
