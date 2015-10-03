require 'rails_helper'

RSpec.describe AccountType do
  describe '#methods' do
    example 'type_multi?' do
      expect(AccountType.find_by(code: 'MULTI').type_multi?).to eq(true)
      expect(AccountType.find_by(code: 'SINGLE').type_multi?).to eq(false)
    end
  end
end
