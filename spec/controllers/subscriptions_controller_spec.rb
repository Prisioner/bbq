require 'rails_helper'

describe SubscriptionsController, type: :controller do
  let!(:owner) { create(:user) }
  let!(:event) { create(:event, user: owner) }
  let!(:user) { create(:user) }
  let!(:subscriber) { create(:user) }
  let!(:subscription) { create(:subscription_with_user, user: subscriber, event: event) }

  describe 'POST #create' do
    context 'valid attributes' do
      context 'event with no pincode' do
        context 'registered user creates subscription' do
          before(:each) { sign_in user }

          it 'saves the new subscription in the database' do
            expect { post :create, params: { event_id: event } }.to change(event.subscriptions, :count).by(1)
          end

          it 'subscription assings to user' do
            expect { post :create, params: { event_id: event } }.to change(user.subscriptions, :count).by(1)
          end

          it 'redirect to event' do
            post :create, params: { event_id: event }

            expect(response).to redirect_to event_path(event)
          end

          it 'sends an email notification to event owner' do
            expect { post :create, params: { event_id: event } }.to change { ActionMailer::Base.deliveries.count }.by(1)
          end
        end

        context 'subscriber tries to subscribe again' do
          before(:each) { sign_in subscriber }

          it 'does not save new subscription' do
            expect { post :create, params: { event_id: event } }.not_to change(Subscription, :count)
          end
        end

        context 'event owner tries to subscribe own event' do
          before(:each) { sign_in owner }

          it 'does not save new subscription' do
            expect { post :create, params: { event_id: event } }.not_to change(Subscription, :count)
          end
        end

        context 'anon user creates subscription' do
          it 'saves the new subscription in the database' do
            expect { post :create, params: { subscription: attributes_for(:subscription), event_id: event } }.to change(event.subscriptions, :count).by(1)
          end

          it 'redirect to event' do
            post :create, params: { subscription: attributes_for(:subscription), event_id: event }

            expect(response).to redirect_to event_path(event)
          end

          it 'sends email notification to anon user subscription email' do
            expect { post :create, params: { subscription: attributes_for(:subscription), event_id: event } }.to change { ActionMailer::Base.deliveries.count }.by(1)
          end
        end
      end

      context 'event with pincode' do
        let!(:event_with_pin) { create(:event, user: owner, pincode: '1234') }

        context 'pincode was not entered' do
          context 'registered user - not owner of event' do
            before(:each) { sign_in user }

            it 'does not save subscription in the database' do
              expect { post :create, params: { event_id: event_with_pin } }.not_to change(Subscription, :count)
            end

            it 'generate flash alert' do
              post :create, params: { event_id: event_with_pin }

              expect(flash[:notice]).to be_nil
              expect(flash[:alert]).to be
            end
          end

          context 'anon user' do
            it 'does not save subscription in the database' do
              expect { post :create, params: { subscription: attributes_for(:subscription), event_id: event_with_pin } }.not_to change(Subscription, :count)
            end

            it 'generate flash alert' do
              post :create, params: { subscription: attributes_for(:subscription), event_id: event_with_pin }

              expect(flash[:notice]).to be_nil
              expect(flash[:alert]).to be
            end
          end
        end

        context 'pincode was entered' do
          before(:each) do
            request.cookies["events_#{event_with_pin.id}_pincode"] = '1234'
          end

          context 'registered user - not owner of event' do
            before(:each) { sign_in user }

            it 'saves the new subscription in the database' do
              expect { post :create, params: { event_id: event_with_pin } }.to change(event_with_pin.subscriptions, :count).by(1)
            end
          end

          context 'anon user' do
            it 'saves the new subscription in the database' do
              expect { post :create, params: { subscription: attributes_for(:subscription), event_id: event_with_pin } }.to change(event_with_pin.subscriptions, :count).by(1)
            end
          end
        end
      end
    end

    context 'invalid attributes' do
      context 'anon user tries to create invalid subscription' do
        it 'does not save subscription in database' do
          expect { post :create, params: { subscription: attributes_for(:invalid_subscription), event_id: event } }.not_to change(Subscription, :count)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'redirects to event' do
      delete :destroy, params: { id: subscription, event_id: event }

      expect(response).to redirect_to event_path(event)
    end

    context 'owner of event tries to delete subscription' do
      it 'deletes subscription' do
        sign_in owner

        expect { delete :destroy, params: { id: subscription, event_id: event } }.to change(Subscription, :count).by(-1)
      end
    end

    context 'subscriber tries to delete own subscription' do
      it 'deletes subscription' do
        sign_in subscriber

        expect { delete :destroy, params: { id: subscription, event_id: event } }.to change(Subscription, :count).by(-1)
      end
    end

    context 'registered user tries to delete non-own subscription' do
      before(:each) { sign_in user }

      it 'does not delete subscription' do
        expect { delete :destroy, params: { id: subscription, event_id: event } }.not_to change(Subscription, :count)
      end

      it 'generate flash alert' do
        delete :destroy, params: { id: subscription, event_id: event }

        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end

    context 'anon user tries to delete subscription' do
      it 'does not delete subscription' do
        expect { delete :destroy, params: { id: subscription, event_id: event } }.not_to change(Subscription, :count)
      end

      it 'generate flash alert' do
        delete :destroy, params: { id: subscription, event_id: event }

        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end
  end

  describe 'GET #confirm_email' do
    let!(:confirmed_subscription) { create(:subscription, event: event) }
    let!(:non_confirmed_subscription) { create(:subscription, confirmed: false, event: event) }

    context 'subscription email was not confirmed' do
      before(:each) do
        token = non_confirmed_subscription.confirm_token
        get :confirm_email, params: { confirm_token: token }
      end

      it 'updates subscription confirmed status' do
        non_confirmed_subscription.reload

        expect(non_confirmed_subscription).to be_confirmed
      end

      it 'redirects to event' do
        expect(response).to redirect_to event_path(event)
      end
    end

    context 'subscription email was already confirmed' do
      before(:each) do
        token = confirmed_subscription.confirm_token
        get :confirm_email, params: { confirm_token: token }
      end

      it 'redirects to event' do
        expect(response).to redirect_to event_path(event)
      end

      it 'generate flash alert' do
        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end
  end
end
