@Sorter = ($scope, $http) ->

  $scope.resourceUrl = resourceUrl
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
    $http.get(resourceUrl + 'api.php?mode=bodies').success (res) ->
      $scope.previewBodies = eval(res)
      scaleUpImages($scope.previewBodies, '.preview')

  $scope.sorterImages = []
  $scope.pageCount = 0

  $scope.next = (e) ->
    random = ""
    if e
      random = "&random=1" if $(e.target).attr('data-random')
    $scope.calcTotals()
    $http.get("#{resourceUrl}api.php?mode=query&category=all&subcategory=all&page=#{$scope.pageCount}#{random}").success (json) ->
      json = eval(json)
      $scope.sorterImages = $scope.sorterImages.concat json
      scaleUpImages(json)
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
    post = $http.post(resourceUrl + 'api.php?mode=set', 'json='+JSON.stringify(categories))
    .success (res) ->
      $scope.pageCount = 0
      $scope.sorterImages = []
      $scope.next()

  $scope.calcTotals = ->
    $http.get(resourceUrl + 'api.php?mode=stats').success (res) ->
      $scope.sorterTotal = res.total
      $scope.sorterProgress = res.sorted
      $scope.sorterPercentage = (100 / res.total) * res.sorted

  $scope.graphicPreview = ->
    $('#graphicPreview').modal('show')
    $scope.selectedResource = @item.id
    scaleUpImages([@item], '.preview')
    false

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

        $.getJSON resourceUrl + "api.php?mode=query&category=#{category}&subcategory=#{subcategory}", (json) ->
          $scope.imgs = imgs = {}
          for j in json
            index = "canvas-#{j.id}"
            imgs[index] = new Image()
            imgs[index].src = resourceUrl + "resources/#{j.location}"
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
