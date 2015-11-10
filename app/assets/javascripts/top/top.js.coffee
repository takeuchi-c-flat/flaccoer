$ ->
  $("tr.dashboard-list-item").on "click", ->
    subject_id = $(this).attr("id")
    if subject_id == "0"
      alert "明細がありません。"
      return
    href = "ledger/" + subject_id
    link = document.createElement('a')
    link.href = href
    link.click()
