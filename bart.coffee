$ ->
  stations = $('#data').data('stations')
  fetchStationData(abbr, index) for abbr, index in stations

fetchStationData = (abbr, index)->
  url = "http://api.bart.gov/api/etd.aspx?cmd=etd&orig=#{abbr}&key=MW9S-E7SL-26DU-VV8V"
  tr = $("tbody#stations tr:nth-child(#{1 + index})")
  $.get url, (data) ->
    station = $(data).children('root').children('station')
    updateStationRow station, tr

updateStationRow = (station, tr) ->
  tr.children('td').detach()
  estimates = for estimate in station.children('etd').children('estimate')[0..19]
    dir = $(estimate).children('direction').text()
    mins = Number($(estimate).children('minutes').text()) || 0
    [dir, mins, estimate]
  addEstimateTd(tr, estimate) for estimate in estimates.sort(estimateSortFunction)

estimateSortFunction = (a, b) ->
  if a[0] == b[0]
    a[1] - b[1]
  else
    if a[0] == 'South' then 1 else -1

addEstimateTd = (tr, arr) ->
  dir   = arr[0]
  mins  = arr[1]
  est   = arr[2]
  color = $(est).children('hexcolor').text()
  qual  = if dir == 'South' then 'color' else 'background-color'
  td    = $("<td>#{mins}</td>")
  td.css(qual, color)
  td.appendTo(tr)
