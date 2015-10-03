json.array!(@fiscal_years) do |fiscal_year|
  json.extract! fiscal_year, :id, :user_id, :account_type_id, :subject_template_type_id, :title, :organization_name, :date_from, :date_to, :locked
  json.url fiscal_year_url(fiscal_year, format: :json)
end
