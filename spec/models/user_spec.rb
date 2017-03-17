require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'validates account status' do
      user = User.create(account_status: 'trial')
      expect(user.errors['account_status']).to be_empty

      user = User.create(account_status: 'full_access')
      expect(user.errors['account_status']).to be_empty

      user = User.create(account_status: 'free_forever')
      expect(user.errors['account_status']).to include('is not valid')
    end
  end

  describe 'account_status' do
    it 'returns account status' do
      user = FactoryGirl.create(:user, account_status: 'full_access')
      expect(user.account_status).to eq('full_access')
    end
  end

  describe 'account' do
    it 'creates with trial status' do
      user = User.create(email: 'user@site.com', password: 'abcd12345')
      expect(user.account['status']).to eq('trial')
      expect(user.account['payments']).to eq([])
    end

    it 'applies status on create' do
      user = User.create(email: 'user@site.com', password: 'abcd12345', account_status: 'full_access')
      expect(user.account['status']).to eq('full_access')
      expect(user.account['payments']).to eq([])
    end
  end
end
