require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'associations and validations check' do
    it { should belong_to :event }
    it { should belong_to :user }

    it { should validate_uniqueness_of(:confirm_token).case_insensitive }
    it { should allow_value(nil).for(:confirm_token) }
    it { should_not validate_presence_of :user }

    context 'user is present' do
      subject { build(:subscription_with_user) }

      it { should_not validate_presence_of :user_name }
      it { should_not validate_presence_of :user_email }

      # not validates email format if user is present
      it { should allow_value('not an email').for(:user_email) }

      it { should validate_uniqueness_of(:user).scoped_to(:event_id) }
      it { should_not validate_uniqueness_of(:user_email).scoped_to(:event_id) }
    end

    context 'user is nil' do
      let!(:event) { create(:event) }
      let!(:subscription) { create(:subscription, event: event, user_email: '123@123.ru') }
      let!(:user) { create(:user, email: 'registered_email@example.com') }

      it { should validate_presence_of :user_name }
      it { should validate_presence_of :user_email }

      # validates email format if user is nil
      it { should_not allow_value('not an email').for(:user_email) }
      it { should allow_value('correct_email@example.com').for(:user_email) }

      # стандартный тест падает, хотя судя по byebug и по выдаче ошибки должен проходить
      it 'should validate_uniqueness_of(:user_email).scoped_to(:event_id)' do
        new_subscription = build(:subscription, event: event, user_email: '123@123.ru')

        expect(new_subscription).to be_invalid
        expect(new_subscription.errors.full_messages).to contain_exactly 'Email уже подписан'
      end

      it 'should validate email is not belong to registered user' do
        new_subscription = build(:subscription, user_email: 'registered_email@example.com')

        expect(new_subscription).to be_invalid
        expect(new_subscription.errors.full_messages).to contain_exactly 'Email уже принадлежит зарегистрированному пользователю'
      end
    end
  end

  describe '#user_name' do
    context 'user is present' do
      let(:user) { create(:user, name: 'Петя') }
      let(:subscription) { create(:subscription_with_user, user: user, user_name: 'Вася') }

      it 'returns name of registered user' do
        expect(subscription.user_name).to eq 'Петя'
      end
    end

    context 'user is blank' do
      let(:subscription) { create(:subscription, user_name: 'Анонимус') }

      it 'returns user_name' do
        expect(subscription.user_name).to eq 'Анонимус'
      end
    end
  end

  describe '#user_email' do
    context 'user is present' do
      let(:user) { create(:user, email: 'petya@example.com') }
      let(:subscription) { create(:subscription_with_user, user: user, user_email: 'vasya@example.com') }

      it 'returns email of registered user' do
        expect(subscription.user_email).to eq 'petya@example.com'
      end
    end

    context 'user is blank' do
      let(:subscription) { create(:subscription, user_email: 'vasya@example.com') }

      it 'returns user_email' do
        expect(subscription.user_email).to eq 'vasya@example.com'
      end
    end
  end
end
