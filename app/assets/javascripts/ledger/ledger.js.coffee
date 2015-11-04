$ ->
  $("a#ledger-button").on "click", ->
    $form = $("#new_ledger_form")
    $.ajax({ url: "/ledger", type: "POST", data: $form.serialize(), dataType: "html" }).done (data) ->
      $("#ledger-list").html(data)
