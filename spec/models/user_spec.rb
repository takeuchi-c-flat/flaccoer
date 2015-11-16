require 'rails_helper'

RSpec.describe User do
  describe '#to_s' do
    example 'get' do
      expect(User.new(name: 'UserName').to_s).to eq('UserName')
    end
  end
end
