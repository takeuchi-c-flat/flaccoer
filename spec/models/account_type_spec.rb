require 'rails_helper'

RSpec.describe AccountType do
  describe '#methods' do
    example 'type_multi?' do
      expect(AccountType.find_by(code: 'MULTI').type_multi?).to eq(true)
      expect(AccountType.find_by(code: 'SINGLE').type_multi?).to eq(false)
    end

    example 'to_s' do
      expect(AccountType.find_by(code: 'MULTI').to_s).to eq('複式簿記')
    end
  end
end
