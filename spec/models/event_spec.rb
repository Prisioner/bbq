require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations and validations check' do
    it { should belong_to :user }

    it { should have_many :comments }
    it { should have_many :subscriptions }
    it { should have_many :subscribers }
    it { should have_many :photos }

    it { should validate_presence_of :title }
    it { should validate_presence_of :address }
    it { should validate_presence_of :datetime }
    it { should validate_length_of(:title).is_at_most(255) }
  end

  describe '#visitors' do
    let(:owner) { FactoryGirl.create(:user, email: 'owner@ex.com') }

    let!(:user1) { FactoryGirl.create(:user, email: 'sbscrbr1@ex.com') }
    let!(:user2) { FactoryGirl.create(:user, email: 'sbscrbr2@ex.com') }
    let!(:user3) { FactoryGirl.create(:user, email: 'not_subscriber@ex.com') }

    let(:event) { FactoryGirl.create(:event, user: owner) }

    let!(:subscription1) { FactoryGirl.create(:subscription, event: event, user_email: 'anon_subscriber@ex.com' ) }
    let!(:subscription2) { FactoryGirl.create(:subscription_with_user, event: event, user: user1) }
    let!(:subscription3) { FactoryGirl.create(:subscription_with_user, event: event, user: user2) }

    it 'returns array of Users' do
      expect(event.visitors).to all be_an_instance_of User
    end

    it 'returns only registered subscribers and owner' do
      email_list = event.visitors.map(&:email)

      expect(email_list).to_not include 'not_subscriber@ex.com'
      expect(email_list).to_not include 'anon_subscriber@ex.com'
      expect(email_list).to contain_exactly('owner@ex.com', 'sbscrbr1@ex.com', 'sbscrbr2@ex.com')
    end
  end

  describe '#pincode_valid?' do
    let(:event) { FactoryGirl.create(:event, pincode: '1234') }

    context 'valid pincode given' do
      it 'returns true' do
        expect(event.pincode_valid?('1234')).to be_truthy
      end
    end

    context 'invalid pincode given' do
      it 'returns false' do
        expect(event.pincode_valid?('4321')).to be_falsey
      end
    end
  end
end
