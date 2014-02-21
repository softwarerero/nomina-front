$ -> # like document ready
  window.Nomina.init()
  
class Nomina
  name: "funcionarios"
#  alert(window.nominaData)
#  items: null
  item_template : """
                  <tr class="item">
                    <td><%= obj.nombre %></td>
                    <td><% if (obj.cargo) {  %><%= obj.cargo %><% } %></td>
                    <td><%= obj.categoria %></td>
                    <td><%= Nomina.formatCurrency(obj.sueldo) %></td>
                    <td><%= Nomina.formatCurrency(obj.extra) %></td>
                    <td><%= Nomina.formatCurrency(obj.total) %></td>
                    <td><%= obj.antiguedad %></td>
                    <td><%= obj.estado %></td>
                    <td><%= obj.institucion %></td>
                  </tr>
                  """ 

  init: ->
    location = window.location.href.toString().split(window.location.host)[1]
#    alert(window.nominaData)
    if location.indexOf("nomina") > -1
#      json = @loadZip()
      @initMainPage(window.nominaData)

  loadZip: () =>
#    loader = new ZipLoader('nomina.zip')
#    json = loader.load('nomina.zip://nomina.js')
#    json = eval(json)
#    imageLoader = new ZipLoader('img/a.zip')
#    $("#temp").attr('alt', 'bla')
#    $("#temp").attr('src', imageLoader.loadImage('img/a.zip://expand.png'))
#    alert(imageLoader.loadImage('img/a.zip://collapse.png'))
#    alert(imageLoader.loadImage('img/a.zip://bobble.png'))
#    $.getJSON "/nomina.json.js", (json) =>
    $.getJSON "/nomina.js", (json) =>
      @initMainPage(json)

  initMainPage: (json) =>
    settings = 
      items: json
      facets: { 'cargo': 'Cargo', 'cargo' : 'Cargo', 'categoria' : 'Categoria', 'antiguedad' : 'Antiguedad', 'institucion': 'Institucion' }
      resultSelector  : '#results'
      facetSelector   : '#facets'
      resultTemplate  : @item_template
      orderByOptions  : {'nombre': 'Nombre', 'cargo': 'Cargo', 'categoria': 'Categoria', 'sueldo': 'Sueldo', 'antiguedad': 'Antiguedad'}
      facetContainer  : '<div class="facetsearch" id=<%= id %> ></div>',
      facetListContainer  : '<select class="facetlist"></select>' 
      listItemTemplate  : '<option class=facetitem id="<%= id %>" value="<%= name %>"><%= name %> <span class=facetitemcount>(<%= count %>)</span></option>' 
      bottomContainer    : '<div class="bottomline"></div>',
      deselectTemplate   : '<span class=deselectstartover><button class="btn btn-large btn-primary" type="button">Reiniciar Filtros</button></span>'
      facetTitleTemplate : '<h5 class=facettitle><%= title %></h5>'
      countTemplate      : '<span class=facettotalcount><%= count %> Funcionarios</span>',
      showMoreTemplate   : '<a id=showmorebutton>Más</a>'
      paginationCount    : 15
      callbackResultUpdate: @resultUpdate
      textFilter      : '#filter1'
    $.facetelize(settings)
    $("#filter1").prependTo($(".bottomline"))
    $("#filter1Lable").prependTo($(".bottomline"))

    $("#filter1").keypress (event) ->
      if(event.which == 13) 
        event.preventDefault()
        $.facetUpdate()         
            
#    $(".stats").click () ->
#      $("#salarioAnhos").delay(10800).css("width", "1500")
    $(window).resize () ->
      $("#salarioAnhos").css("width", $(".container2").width())

  	
  resultUpdate: (items) =>
#    alert(JSON.stringify(items))
    sueldoTotal = 0
    items.forEach (item) ->
      sueldoTotal += parseInt(item.total)
    $("#sueldoTotal").html(@formatCurrency(sueldoTotal))
    $("#sueldoPromedio").html(@formatCurrency(sueldoTotal/items.length))
    sueldos = _.map items, (item) ->
      item.total
    sueldos = _.filter sueldos, (num) -> 
      num > 0
    min = Math.min.apply @, sueldos
    $("#minimo").html(@formatCurrency(min))
    max = Math.max.apply @, sueldos
    $("#maximo").html(@formatCurrency(max))
    @ageGraph(items)
    $("#salarioAnhos").css("width", $(".container2").width())
    
    
  ageGraph: (items) ->
    currentYear = (new Date()).getFullYear()
    salarioAnhos = {}
    items.forEach (item) ->
#      alert(Math.random() * (2011 - 1980) + 1980)
      antiguedad = if(item.antiguedad) then parseInt(item.antiguedad) else (Math.floor(Math.random() * (2011 - 1980)) + 1980)
      salario = parseInt(item.total)
      if antiguedad
        if not (salarioAnhos[antiguedad])
          salarioAnhos[antiguedad] = 0
        salarioAnhos[antiguedad] = salarioAnhos[antiguedad] + salario 
    salarioAnhos2 = []
    for anho, salario of salarioAnhos      
      salarioAnhos2.push [anho, salario]
    salarioAnhos2 = _(salarioAnhos2).sortBy (a) ->
      parseInt(a[0])      
#    alert(JSON.stringify(salarioAnhos2))
    anhos = _.map salarioAnhos2, (sa) -> 
      sa[0]   
    salarios = _.map salarioAnhos2, (sa) -> 
      sa[1] 
    data =
      labels : anhos
      datasets : [{
        fillColor : "rgba(220,220,220,0.5)",
        strokeColor : "rgba(220,220,220,1)",
        pointColor : "rgba(220,220,220,1)",
        pointStrokeColor : "#fff",
        data : salarios
      }, {
        fillColor : "rgba(151,187,205,0.5)",
        strokeColor : "rgba(151,187,205,1)",
        pointColor : "rgba(151,187,205,1)",
        pointStrokeColor : "#fff",
        data : anhos
      }]

#    alert(JSON.stringify(data))
    ctx = $("#salarioAnhos").get(0).getContext("2d")
    salarioAnhosChart = new Chart(ctx).Line(data)
#    new Chart(ctx).Line(data,options)

  formatCurrency: (num) ->
    if(!num)
      num = "0"
    num = num.toString().replace(/\$|\,/g, '');
    num = Math.floor(num * 100 + 0.50000000001)
    num = Math.floor(num / 100).toString()
    i = 0
    while i < Math.floor((num.length - (1 + i)) / 3)
      num = num.substring(0, num.length - (4 * i + 3)) + '.' + num.substring(num.length - (4 * i + 3))
      i++
    sign = if num < 0 then "-" else ""
    sign + num

window.Nomina = new Nomina
 