require 'rails_helper'

RSpec.describe WatchUser do
  describe '#validate_user' do
    example 'validate is ok' do
      user = create(:user)
      fiscal_year = create(:fiscal_year)
      watch_user = WatchUser.new(fiscal_year: fiscal_year, user: user)
      expect(watch_user.valid?).to eq(true)
      expect(watch_user.errors[:user_email]).to eq([])
    end

    example 'validate is ng (user undefine)' do
      user = create(:user)
      fiscal_year = create(:fiscal_year, user: user)
      watch_user = WatchUser.new(fiscal_year: fiscal_year, user_email: 'aaa@local')
      expect(watch_user.valid?).to eq(false)
      expect(watch_user.errors[:user_email]).to include(' 指定したe-mailのユーザが見つかりません。')
    end

    example 'validate is ng (user is your)' do
      user = create(:user, email: 'AAA@local')
      fiscal_year = create(:fiscal_year, user: user)
      watch_user = WatchUser.new(fiscal_year: fiscal_year, user_email: 'AAA@local')
      expect(watch_user.valid?).to eq(false)
      expect(watch_user.errors[:user_email]).to include(' 指定したe-mailは、あなたのアカウントです。')
    end
  end
end
