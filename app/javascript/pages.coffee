@Sorter = ($scope, $http) ->

  $scope.init = ->

    $('.nav-tabs').tab()
    $('.sortable').sortable
      connectWith: ".sortable"

    infScr = $('#infinite-scroll')
    infScrTop = infScr.offset().top
    $(window).scroll ->
      scrTop = $(window).scrollTop()
      if scrTop > infScrTop
        infScr.css('margin-top', (scrTop - infScrTop) + 10)
      else
        infScr.css('margin-top', 0)
    $scope.next()

  $scope.sorterImages = []
  $scope.pageCount = 0

  $scope.next = (e, sender, callback = false) ->
    url = 'http://mistarcane.com/charas/api.php?mode=query&category=all&subcategory=all&page='+$scope.pageCount
    $http.get(url).success (json) ->
      json = eval(json)
      $scope.sorterImages = $scope.sorterImages.concat json
      imgs = []
      for j, index in json
        imgs[index] = new Image()
        imgs[index].crossOrigin = "anonymous"
        imgs[index].src = "http://mistarcane.com/charas/resources/#{j.location}"
        imgs[index].id = "canvas-#{j.id}"
        imgs[index].onload = ->
          scaleUpImage(@)
      callback() if callback
      $scope.pageCount++
    $scope.calcTotals()

  $scope.commit = ->
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
    post = $http.post('http://mistarcane.com/charas/api.php?mode=set', 'json='+JSON.stringify(categories))
    .success (res) ->
      $scope.pageCount = 0
      $scope.sorterImages = []
      $scope.next()

  $scope.calcTotals = ->
    $http.get('http://mistarcane.com/charas/api.php?mode=stats').success (res) ->
      $scope.sorterTotal = res.total
      $scope.sorterProgress = res.sorted
      $scope.sorterPercentage = (100 / res.total) * res.sorted

  $scope.graphicPreview = ->
    $('#graphicPreview').modal('show')

  $scope.$on '$routeChangeSuccess', $scope.init

@Maker = ($scope) ->
    $scope.imgs = {}

    $scope.init = ->
      $('#resources .nav-tabs li a').click -> setTimeout $scope.load, 1
      $scope.load()

    $scope.load = ->
      activeResource = '#resources .tab-pane.active .tab-pane.active .resources'
      unless $(activeResource).children().length
        category = $('#resources .nav-tabs li.active a').html()
        subcategory = $('#'+category+' .nav-tabs li.active a').html()
        imgLoadCount = 0

        $.getJSON "http://mistarcane.com/charas/api.php?mode=query&category=#{category}&subcategory=#{subcategory}", (json) ->
          $scope.imgs = imgs = {}
          for j in json
            index = "canvas-#{j.id}"
            imgs[index] = new Image()
            imgs[index].src = "http://mistarcane.com/charas/resources/#{j.location}"
            imgs[index].id = index
            imgs[index].crossOrigin = "anonymous"
            imgs[index].onload = ->
              scaleUpImage(@)
              imgLoadCount++
              if imgLoadCount is imgs.length
                $('#resources .resources').masonry
                  itemSelector: 'canvas'
                $('.resources').each (index, elem) ->
                  $(@).css('height', '1032px') if $(@).css('height') is '0px'
          $scope.$apply -> $scope.imgs

    $scope.select = (angularObj) ->
      sender = angularObj.img
      url = $(sender).attr('data-location')
      id = $(sender).attr('id')

      section = $('#resources .tab-pane.active .tab-pane.active').attr('data-section')
      $('#charas canvas[data-section="'+section+'"]').remove()
      $('#charas').append("<canvas id=\"viewer-#{id}\" data-section=\"#{section}-#{}\"></canvas>")
      
      img = $scope.imgs[id]
      img.id = 'viewer-' + id
      scaleUpImage(img)

    $scope.$on '$routeChangeSuccess', $scope.init
