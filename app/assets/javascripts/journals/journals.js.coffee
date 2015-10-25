$ ->
  $.ajax({ url: "journals/subjects_debit", dataType: "html" }).done (data) ->
    $("#subjects-debit").html(data)
  $.ajax({ url: "journals/subjects_credit", dataType: "html" }).done (data) ->
    $("#subjects-credit").html(data)
  $('a[data-toggle="tab"]').on 'shown.bs.tab click', (e) ->
    tabName = e.target.href
    tabContentsId = tabName.split("#")[1]
    list_url = "journals/list/" + tabContentsId + "/"
    $.ajax({ url: list_url, dataType: "html" }).done (data) ->
      $("#" + tabContentsId).html(data)
  $('li.active').find('a[data-toggle="tab"]').trigger('click')
