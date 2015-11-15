$ ->
  $("a#ledger-button").on "click", ->
    $form = $("#new_ledger_form")
    $.ajax({ url: "/ledger", type: "POST", data: $form.serialize(), dataType: "html" }).done (data) ->
      $("#ledger-list").html(data)
  $("a#ledger-excel-button").on "click", ->
    subject_id = $("#new_ledger_form [id=ledger_form_subject_id]").val()
    date_from = $("#new_ledger_form [id=ledger_form_date_from]").val().replace(/\//g, "")
    date_to = $("#new_ledger_form [id=ledger_form_date_to]").val().replace(/\//g, "")
    href = "/ledger/excel/" + subject_id + "/" + date_from + "/" + date_to + ".xlsx"
    link = document.createElement('a')
    link.href = href
    link.download = ""
    link.click()
  $("a#ledger-button").trigger('click')
