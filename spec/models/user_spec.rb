require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations and validations check' do
    it { should have_many :events }
    it { should have_many :comments }
    it { should have_many :photos }
    it { should have_many :subscriptions }

    it { should validate_presence_of :name }
    it { should validate_length_of(:name).is_at_most(35) }
  end

  describe '#link_subscriptions' do
    let!(:subscription1) { create(:subscription, user_email: 'user123@example.com') }
    let!(:subscription2) { create(:subscription, confirmed: false, user_email: 'user123@example.com') }
    let!(:user) { build(:user, email: 'user123@example.com') }

    it 'confirms not-confirmed subscription' do
      user.save
      subscription2.reload

      expect(subscription2).to be_confirmed
    end

    it 'sends an email only when confirms subscriptions' do
      expect { user.save }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'links subscriptions to user' do
      user.save

      expect(user.subscriptions).to contain_exactly(subscription1, subscription2)
    end
  end
end
