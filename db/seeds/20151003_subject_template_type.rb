SubjectTemplateType.create!(
  account_type: AccountType.find_by(code: 'MULTI'),
  name: '個人事業主(青色申告)'
)
