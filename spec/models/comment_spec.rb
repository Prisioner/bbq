require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validations check' do
    it { should belong_to :event }
    it { should belong_to :user }

    it { should validate_presence_of :body }
    # user is optional
    it { should_not validate_presence_of :user }

    context 'user is present' do
      subject { Comment.new(user: FactoryGirl.create(:user)) }
      it { should_not validate_presence_of :user_name }
    end

    context 'user is nil' do
      it { should validate_presence_of :user_name }
    end
  end

  describe '#user_name' do
    context 'user is present' do
      let(:user) { FactoryGirl.create(:user, name: 'Петя') }
      let(:comment) { FactoryGirl.create(:comment_with_author, user: user, user_name: 'Вася') }

      it 'returns name of registered user' do
        expect(comment.user_name).to eq 'Петя'
      end
    end

    context 'user is blank' do
      let(:comment) { FactoryGirl.create(:comment, user_name: 'Анонимус') }

      it 'returns user_name' do
        expect(comment.user_name).to eq 'Анонимус'
      end
    end
  end
end
