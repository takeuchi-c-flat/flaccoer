require 'rails_helper'

RSpec.describe Journal do
  describe '#price_for_balance' do
    let(:type_debit) { FactoryGirl.create(:subject_type, debit: true, credit: false) }
    let(:type_credit) { FactoryGirl.create(:subject_type, debit: false, credit: true) }
    let(:subject_debit1) { FactoryGirl.create(:subject_debit, subject_type: type_debit) }
    let(:subject_debit2) { FactoryGirl.create(:subject_debit, subject_type: type_credit) }
    let(:subject_credit1) { FactoryGirl.create(:subject_credit, subject_type: type_credit) }
    let(:subject_credit2) { FactoryGirl.create(:subject_credit, subject_type: type_debit) }

    example 'with debit - credit' do
      journal = create(:journal).tap { |m|
        m.subject_debit = subject_debit1
        m.subject_credit = subject_credit1
        m.price = 10000
      }

      expect(journal.price_for_balance(subject_debit1)).to eq(10000)
      expect(journal.price_for_balance(subject_credit1)).to eq(10000)
    end

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
