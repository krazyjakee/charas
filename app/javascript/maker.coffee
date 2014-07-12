imgLoadCount = 0
imgs = []
showResources = ->
  $('#resources .resources').html('')

  category = $('#resources .nav-tabs li.active a').html()
  subcategory = $('#'+category+' .nav-tabs li.active a').html()

  $.getJSON "http://mistarcane.com/charas/api.php?mode=query&category=#{category}&subcategory=#{subcategory}", (json) ->
    imgs = []
    for j in json
      resourceDiv = $('#'+category+'-'+subcategory+' .resources')
      resourceDiv.append("<canvas id=\"canvas-#{j.id}\" data-location='#{j.location}' data-click='selectResource'></canvas>")
      index = "canvas-#{j.id}"
      imgs[index] = new Image()
      imgs[index].src = "resources/#{j.location}"
      imgs[index].id = j.id
      imgs[index].onload = ->
        scaleUpImage(@)
        imgLoadCount++
        if imgLoadCount is imgs.length
          $('#resources .resources').masonry
            itemSelector: 'canvas'
          $('.resources').each (index, elem) ->
            if $(@).css('height') is '0px'
              $(@).css('height', '1032px')

window.selectResource = (e, sender) ->
  url = $(sender).attr('data-location')
  id = $(sender).attr('id')

  section = $('#resources .tab-pane.active .tab-pane.active').attr('data-section')
  $('#charas canvas[data-section="'+section+'"]').remove()

  $('#charas').append("<canvas id=\"viewer-#{id}\" data-section=\"#{section}-#{}\"></canvas>")
  
  img = imgs[id]
  scaleUpImage(img, true)

$('#resources .nav-tabs li a').click -> setTimeout showResources, 1
showResources()