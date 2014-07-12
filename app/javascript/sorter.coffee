window.setupSorter = ->
  infScr = $('#infinite-scroll')

  $('.nav-tabs').tab()
  $('.sortable').sortable
    connectWith: ".sortable"

  window.infScrTop = infScr.offset().top
  $(window).scroll ->
    scrTop = $(window).scrollTop()
    if scrTop > infScrTop
      infScr.css('margin-top', (scrTop - infScrTop) + 10)
    else
      infScr.css('margin-top', 0)

window.Uncategorised =
  pageCount: 0
  getNext: (e, sender, callback = false) ->
    $.getJSON 'http://mistarcane.com/charas/api.php?mode=query&category=all&subcategory=all&page='+Uncategorised.pageCount, (json) ->
      imgs = []
      for j in json
        infs = $('#infinite-scroll')
        infs.append("<canvas id=\"canvas-#{j.id}\"></canvas>")
        index = imgs.length
        imgs[index] = new Image()
        imgs[index].src = "resources/#{j.location}"
        imgs[index].id = j.id
        imgs[index].onload = ->
          scaleUpImage(@)
      callback() if callback
      Uncategorised.pageCount++

window.Categorised =
  save: ->
    categories = {}
    $('#categorised .sortable').each (index, elem) ->
      cat = $(@).attr('data-category').split('-')
      ids = []
      $(@).find('canvas').each (index, elem) -> ids.push $(@).attr('id').split('-')[1]
      if ids.length
        if cat[0] is 'trash'
          categories['trash'] = ids
        else
          categories[cat[0]] = {} unless categories[cat[0]]
          categories[cat[0]][cat[1]] = ids
    $.ajax
      url: 'http://mistarcane.com/charas/api.php?mode=set'
      type: 'POST'
      data: 'json='+JSON.stringify(categories)
      success: (res) ->
        $('#infinite-scroll, .sortable').empty()
        Uncategorised.pageCount = 0
        Uncategorised.getNext()

Uncategorised.getNext(null, null, setupSorter)