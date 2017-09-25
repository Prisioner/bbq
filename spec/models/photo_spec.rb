require 'rails_helper'

RSpec.describe Photo, type: :model do
  describe 'associations and validations check' do
    it { should belong_to :event }
    it { should belong_to :user }

    it { should validate_presence_of :photo }
  end
end
