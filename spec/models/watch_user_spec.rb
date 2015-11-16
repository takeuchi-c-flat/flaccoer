require 'rails_helper'

RSpec.describe WatchUser do
  describe '#validate_user' do
    example 'validate is ok' do
      user = create(:user)
      watch_user = WatchUser.new(user: user)
      watch_user.valid?
      expect(watch_user.errors[:user_email]).to eq([])
    end

    example 'validate is ng' do
      watch_user = WatchUser.new(user_email: 'aaa@local')
      watch_user.valid?
      expect(watch_user.errors[:user_email]).to include(' 指定したe-mailのユーザが見つかりません。')
    end
  end
end
