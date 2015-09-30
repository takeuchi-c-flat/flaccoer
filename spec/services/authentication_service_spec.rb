require 'rails_helper'

RSpec.describe AuthenticationService do
  describe '#authenticate' do
    example 'email and password is OK' do
      user = FactoryGirl.create(:user, password: 'password1', suspended: true)
      expect(AuthenticationService.authenticate(user.email, 'password1')).to eq(user)
      expect(AuthenticationService.authenticate(user.email.upcase, 'password1')).to eq(user)
      expect(AuthenticationService.authenticate(user.email.downcase, 'password1')).to eq(user)
    end

    example 'email is NG' do
      user = FactoryGirl.create(:user, password: 'password1')
      expect(AuthenticationService.authenticate(user.email + 'X', 'password1')).to be_nil
    end

    example 'password is NG' do
      user = FactoryGirl.create(:user, password: 'password1')
      expect(AuthenticationService.authenticate(user.email, 'password')).to be_nil
    end
  end
end
