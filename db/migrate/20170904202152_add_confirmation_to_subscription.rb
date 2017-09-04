class AddConfirmationToSubscription < ActiveRecord::Migration[5.1]
  def change
    add_column :subscriptions, :confirmed, :boolean, default: false
    add_column :subscriptions, :confirm_token, :string
  end
end
