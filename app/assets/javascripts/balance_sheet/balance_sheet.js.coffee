$ ->
  $("a#balance-sheet-button").on "click", ->
    $form = $("#new_balance_sheet_form")
    $.ajax({ url: "/balance_sheet", type: "POST", data: $form.serialize(), dataType: "html" }).done (data) ->
      $("#balance-sheet-list").html(data)
  $("a.balance-sheet-excel-button").on "click", ->
    id = $(this).attr("id").replace("balance-sheet-excel-", "").replace("-button", "")
    date_from = $("#new_balance_sheet_form [id=balance_sheet_form_date_from]").val().replace(/\//g, "")
    date_to = $("#new_balance_sheet_form [id=balance_sheet_form_date_to]").val().replace(/\//g, "")
    href = "/balance_sheet/excel/" + id + "/" + date_from + "/" + date_to + ".xlsx"
    link = document.createElement('a')
    link.href = href
    link.download = ""
    link.click()
  $("a#balance-sheet-button").trigger('click')
