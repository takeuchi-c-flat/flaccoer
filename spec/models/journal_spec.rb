require 'rails_helper'

RSpec.describe Journal do
  let(:type_debit) { FactoryGirl.create(:subject_type, debit: true, credit: false) }
  let(:type_credit) { FactoryGirl.create(:subject_type, debit: false, credit: true) }
  let(:subject_debit1) { FactoryGirl.create(:subject_debit, subject_type: type_debit) }
  let(:subject_debit2) { FactoryGirl.create(:subject_debit, subject_type: type_credit) }
  let(:subject_credit1) { FactoryGirl.create(:subject_credit, subject_type: type_credit) }
  let(:subject_credit2) { FactoryGirl.create(:subject_credit, subject_type: type_debit) }

  describe '#validate_subject' do
    example 'validate is ok' do
      journal = create(:journal).tap { |m|
        m.subject_debit = subject_debit1
        m.subject_credit = subject_credit1
      }

      journal.valid?
      expect(journal.errors[:subject_debit]).to eq([])
    end

    example 'validate is ng' do
      journal = create(:journal).tap { |m|
        m.subject_debit = subject_debit1
        m.subject_credit = subject_debit1
      }

      journal.valid?
      expect(journal.errors[:subject_debit]).to include(' 貸借に同じ科目が指定されています。')
    end
  end

  describe '#validate_subject' do
    example 'validate is ok' do
      journal1 = create(:journal).tap { |m| m.journal_date = m.fiscal_year.date_from }
      journal2 = create(:journal).tap { |m| m.journal_date = m.fiscal_year.date_to }

      journal1.valid?
      journal2.valid?
      expect(journal1.errors[:journal_date]).to eq([])
      expect(journal2.errors[:journal_date]).to eq([])
    end

    example 'validate is ng' do
      journal1 = create(:journal).tap { |m| m.journal_date = m.fiscal_year.date_from.yesterday }
      journal2 = create(:journal).tap { |m| m.journal_date = m.fiscal_year.date_to.tomorrow }

      journal1.valid?
      journal2.valid?
      expect(journal1.errors[:journal_date]).to include(' 年度の範囲外です。')
      expect(journal2.errors[:journal_date]).to include(' 年度の範囲外です。')
    end
  end

  describe '#price_for_balance' do
    example 'with credit - debit' do
      journal = create(:journal).tap { |m|
        m.subject_debit = subject_debit2
        m.subject_credit = subject_credit2
        m.price = 10000
      }

      expect(journal.price_for_balance(subject_debit2)).to eq(-10000)
      expect(journal.price_for_balance(subject_credit2)).to eq(-10000)
    end

    example 'with debit - debit' do
      journal = create(:journal).tap { |m|
        m.subject_debit = subject_debit1
        m.subject_credit = subject_credit2
        m.price = 10000
      }

      expect(journal.price_for_balance(subject_debit1)).to eq(10000)
      expect(journal.price_for_balance(subject_credit2)).to eq(-10000)
    end
  end
end
