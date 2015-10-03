require 'rails_helper'

RSpec.describe FiscalYear do
  describe '#methods' do
    example 'set_account_type with subject_template_type' do
      fiscal_year = create(:fiscal_year).tap { |m| m.account_type = nil }
      fiscal_year.set_account_type
      expect(fiscal_year.account_type).to eq(fiscal_year.subject_template_type.account_type)
    end

    example 'set_account_type without subject_template_type' do
      fiscal_year = create(:fiscal_year).tap { |m| m.subject_template_type = nil }
      fiscal_year.set_account_type
      expect(fiscal_year.account_type).to be_nil
    end
  end
end
