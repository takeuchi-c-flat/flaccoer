$(document).on 'ready page:change', ->
  if $("#journal-input-container").length > 0
    $.ajax({ url: "journals/subjects_debit", dataType: "html" }).done (data) ->
      $("#subjects-debit").html(data)
    $.ajax({ url: "journals/subjects_credit", dataType: "html" }).done (data) ->
      $("#subjects-credit").html(data)
