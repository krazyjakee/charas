###
serverless jade templating with angularjs
remove loading js per page
create per view js objects
###

@scaleUpImage = (imgElem) ->
  scale = 2

  width = imgElem.width
  height = imgElem.height

  src_canvas = document.createElement('canvas')
  src_canvas.width = width
  src_canvas.height = height
  
  src_ctx = src_canvas.getContext('2d')
  src_ctx.drawImage(imgElem, 0, 0)
  src_data = src_ctx.getImageData(0, 0, width, height).data
  
  dst_canvas = document.getElementById(imgElem.id)
  dst_canvas.width = width * scale
  dst_canvas.height = height * scale
  dst_ctx = dst_canvas.getContext('2d')
  offset = 0
  for y in [0...height]
    for x in [0...width]
      rgba = [src_data[offset++],src_data[offset++],src_data[offset++],src_data[offset++]/100].join(',')
      dst_ctx.fillStyle = "rgba(#{rgba})"
      dst_ctx.fillRect(x * scale, y * scale, scale, scale)


templateLoadCount = 0
$('.angular-template').each (index, elem) ->
  src = $(elem).attr('src')
  e = elem
  $.get src, (res) ->
    $(e).html jade.compile(res)()
    .removeAttr 'src'
    templateLoadCount++
    initAngular() if templateLoadCount is $('.angular-template').length

initAngular = ->
  app = angular.module 'charas', ['ngRoute']
  app.config ($routeProvider) ->
    $routeProvider.when '/sorter',
      templateUrl: 'sorter.jade'
    .when '/maker',
      templateUrl: 'maker.jade'
    .otherwise
      redirectTo: '/sorter'
    return

  angular.bootstrap document, ['charas']

#Sorter.init()