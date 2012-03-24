$ ->
  pieContainer = $('#statistics-chart-pie')

  chart = new Highcharts.Chart
    chart:
      renderTo: 'statistics-chart-pie',
      plotBackgroundColor: null,
      plotBorderWidth: null,
      plotShadow: false

    title:
      text: pieContainer.attr('main-title')

    tooltip:
      formatter: ->
        "<b>#{@point.name}</b>: #{Math.round(@percentage * 100) / 100}%"

    plotOptions:
      pie:
        allowPointSelect: true,
        cursor: 'pointer',
        dataLabels:
          enabled: true,
          color: '#000000',
          connectorColor: '#000000',
          formatter: ->
            "<b>#{@point.name}</b>: #{@y}<i>(#{Math.round(@percentage * 100) / 100}%)</i>"

    series: [{
      type: 'pie',
      data: [
        {
          name: 'Живые',
          y: parseInt(pieContainer.attr('data-alive')),
          color: '#468847'
        },
        {
          name: 'Сомнительные',
          y: parseInt(pieContainer.attr('data-unknown')),
          color: '#F89406'
        },
        {
          name: 'Боты',
          y: parseInt(pieContainer.attr('data-bots')),
          sliced: true,
          selected: true,
          color: '#B94A48'
        }
      ]
    }]
