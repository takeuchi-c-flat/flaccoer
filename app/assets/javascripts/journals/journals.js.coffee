$ ->
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
      $('a[data-mark]').on 'click', (e) ->
        e.preventDefault()
        e.stopPropagation()
        id = $(this).attr("data-id")
        if $(this).attr("data-mark") is "0"
          $(this).removeClass("btn-default")
          $(this).addClass("btn-danger")
          $(this).attr("data-mark", "1")
          href = "/journals/set_mark/" + id + "/"
        else
          $(this).removeClass("btn-danger")
          $(this).addClass("btn-default")
          $(this).attr("data-mark", "0")
          href = "/journals/reset_mark/" + id + "/"
        form = document.createElement("form")
        $.ajax({ url: href, type: 'patch'})
        return false
      $("tr.journal-list-item").on 'click', (e) ->
        id = $(this).attr("id")
        window.location.href = '/journals/copy/' + id
  $("li.active").find('a[data-toggle="tab"]').trigger('click')
  $(window).on 'resize', ->
    height = $("div#journal-form-container").height()
    $("div#subjects-debit-container").height(height)
    $("div#subjects-credit-container").height(height)
  $(window).trigger('resize')
