$ ->
  $("a#balance-sheet-button").on "click", ->
    $form = $("#new_balance_sheet_form")
    $.ajax({ url: "/balance_sheet", type: "POST", data: $form.serialize(), dataType: "html" }).done (data) ->
      $("#balance-sheet-list").html(data)
