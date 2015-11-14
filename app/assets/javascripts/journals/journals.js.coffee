$ ->
  $(window).on 'resize', ->
    height = $("div#journal-form-container").height()
    $("div#subjects-debit-container").height(height)
    $("div#subjects-credit-container").height(height)
  $.ajax({ url: "/journals/subjects_debit", dataType: "html" }).done (data) ->
    $("#subjects-debit").html(data)
    $("td.select-subject-debit").on 'click', (e) ->
      id = $(this).attr("id")
      $("div.input_subject_debit").find('select').val(id)
  $.ajax({ url: "/journals/subjects_credit", dataType: "html" }).done (data) ->
    $("#subjects-credit").html(data)
    $("td.select-subject-credit").on 'click', (e) ->
      id = $(this).attr("id")
      $("div.input_subject_credit").find('select').val(id)
  $('a[data-toggle="tab"]').on 'shown.bs.tab click', (e) ->
    tabName = e.target.href
    tabContentsId = tabName.split("#")[1]
    list_url = "/journals/list/" + tabContentsId + "/"
    $.ajax({ url: list_url, dataType: "html" }).done (data) ->
      $("#" + tabContentsId).html(data)
      $("tr.journal-list-item").on 'click', (e) ->
        id = $(this).attr("id")
        window.location.href = '/journals/copy/' + id
  $("li.active").find('a[data-toggle="tab"]').trigger('click')
  $(window).trigger('resize')
