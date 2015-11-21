require 'rails_helper'

RSpec.describe FiscalYear do
  describe '#validate_date_span' do
    example 'date_order NG' do
      fiscal_year = create(:fiscal_year).tap { |m|
        m.date_from = Date.new(2015, 1, 1)
        m.date_to = Date.new(2014, 12, 31)
      }
      fiscal_year.validate_date_span
      expect(fiscal_year.errors[:date_to]).to eq(['日付の指定が正しくありません。'])
    end

    example 'date_range NG' do
      fiscal_year = create(:fiscal_year).tap { |m|
        m.date_from = Date.new(2015, 1, 1)
        m.date_to = Date.new(2016, 7, 1)
      }
      fiscal_year.validate_date_span
      expect(fiscal_year.errors[:date_to]).to eq(['年度の範囲が制限を超えています。'])
    end

    example 'validate OK' do
      fiscal_year = create(:fiscal_year)
      fiscal_year.set_account_type
      fiscal_year.validate_date_span
      expect(fiscal_year.errors[:date_to]).to eq([])
    end
  end

  describe '#set_account_type' do
    example 'with subject_template_type' do
      fiscal_year = create(:fiscal_year).tap { |m| m.account_type = nil }
      fiscal_year.set_account_type
      expect(fiscal_year.account_type).to eq(fiscal_year.subject_template_type.account_type)
    end

    example 'without subject_template_type' do
      fiscal_year = create(:fiscal_year).tap { |m| m.subject_template_type = nil }
      fiscal_year.set_account_type
      expect(fiscal_year.account_type).to be_nil
    end
  end

  describe '#can_access?' do
    example 'my_fiscal_year' do
      user = create(:user)
      fiscal_year = FactoryGirl.create(:fiscal_year, user: user)
      expect(fiscal_year.can_access?(user)).to eq(true)
    end

    example 'with watch_user can_modify' do
      user = create(:user)
      other_user = create(:user)
      fiscal_year = FactoryGirl.create(:fiscal_year, user: user)
      create(:watch_user, fiscal_year: fiscal_year, user: other_user, can_modify: false)
      expect(fiscal_year.can_access?(other_user)).to eq(true)
    end

    example 'with watch_user can_not_modify' do
      user = create(:user)
      other_user = create(:user)
      fiscal_year = FactoryGirl.create(:fiscal_year, user: user)
      expect(fiscal_year.can_access?(other_user)).to eq(false)
    end
  end

  describe '#can_modify?' do
    example 'my_fiscal_year' do
      user = create(:user)
      fiscal_year = FactoryGirl.create(:fiscal_year, user: user)
      expect(fiscal_year.can_modify?(user)).to eq(true)
    end

    example 'my_fiscal_year and locked' do
      user = create(:user)
      fiscal_year = FactoryGirl.create(:fiscal_year, user: user, locked: true)
      expect(fiscal_year.can_modify?(user)).to eq(false)
    end

    example 'with watch_user can_modify' do
      user = create(:user)
      other_user = create(:user)
      fiscal_year = FactoryGirl.create(:fiscal_year, user: user)
      create(:watch_user, fiscal_year: fiscal_year, user: other_user, can_modify: true)
      expect(fiscal_year.can_modify?(other_user)).to eq(true)
    end

    example 'with watch_user can_not_modify' do
      user = create(:user)
      other_user = create(:user)
      fiscal_year = FactoryGirl.create(:fiscal_year, user: user)
      create(:watch_user, fiscal_year: fiscal_year, user: other_user, can_modify: false)
      expect(fiscal_year.can_modify?(other_user)).to eq(false)
    end
  end

  describe '#select_box_name' do
    example 'get' do
      fiscal_year = FactoryGirl.create(:fiscal_year, title: 'タイトル', organization_name: '企業名')
      expect(fiscal_year.select_box_name).to eq('タイトル - 企業名')
    end
  end
end
