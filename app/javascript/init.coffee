###
serverless jade templating with angularjs
remove loading js per page
create per view js objects
###

@scaleUpImage = (sender, viewer = false) ->
  scale = 2

  src_canvas = document.createElement('canvas')
  src_canvas.width = sender.width
  src_canvas.height = sender.height
  
  src_ctx = src_canvas.getContext('2d')
  src_ctx.drawImage(sender, 0, 0)
  src_data = src_ctx.getImageData(0, 0, sender.width, sender.height).data
  
  id = 'canvas-'+sender.id
  id = 'viewer-' + id if viewer
  dst_canvas = document.getElementById(id)
  dst_canvas.width = sender.width * scale
  dst_canvas.height = sender.height * scale
  dst_ctx = dst_canvas.getContext('2d')
  offset = 0
  for y in [0...sender.height]
    for x in [0...sender.width]
      rgba = [src_data[offset++],src_data[offset++],src_data[offset++],src_data[offset++]/100].join(',')
      dst_ctx.fillStyle = "rgba(#{rgba})"
      dst_ctx.fillRect(x * scale, y * scale, scale, scale)

globalInit = ->
  reqs = $('require')
  if reqs.length
    coffeeReqs = $('require').html().split(',')
    for req in coffeeReqs
      $.get "app/javascript/#{req}.coffee", (res) -> CoffeeScript.eval(res)
  $("body").on 'click', '[data-click]', handleLink

handleLink = (e)->
  sender = $(@)
  eval($(@).attr('data-click'))(e, sender)

goToLink = (e, sender) ->
  e.preventDefault()
  link = $(sender).attr('data-url')
  changePage(link)
  false

changePage = (where) ->
  $("body [data-click]").unbind 'click'
  $.get "views/#{where}.jade", (e) ->
    $('#container').html jade.compile(e)()
    globalInit()

changePage('sorter')