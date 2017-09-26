require 'rails_helper'

describe EventsController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:own_event) { create(:event, user: user) }
  let(:event_with_pincode) { create(:event, user: user, pincode: '1234') }

  describe 'GET #index' do
    let!(:events) { create_list(:event, 3) }

    before(:each) { get :index }

    it 'populate array with all events' do
      expect(assigns(:events)).to eq events
    end

    it 'renders #index template' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    context 'event without pincode' do
      before(:each) { get :show, params: {id: event} }

      it 'assings event to @event' do
        expect(assigns(:event)).to eq event
      end

      it 'build new comment to @new_comment' do
        expect(assigns(:new_comment)).to be_a_new(Comment)
      end

      it 'build new photo to @new_photo' do
        expect(assigns(:new_photo)).to be_a_new(Photo)
      end

      it 'build new subscription to @new_subscription' do
        expect(assigns(:new_subscription)).to be_a_new(Subscription)
      end

      it 'renders #show template' do
        expect(response).to render_template :show
      end
    end

    context 'event with pincode' do
      context 'owner of event tries to access event' do
        before do
          sign_in user
          get :show, params: {id: event_with_pincode}
        end

        it 'renders #show template' do
          expect(response).to render_template :show
        end
      end

      context 'pincode was not entered' do
        before do
          get :show, params: {id: event_with_pincode}
        end

        it 'renders #password_form template' do
          expect(response).to render_template :password_form
        end
      end

      context 'pincode was entered' do
        before do
          request.cookies["events_#{event_with_pincode.id}_pincode"] = '1234'
          get :show, params: {id: event_with_pincode}
        end

        it 'renders #show template' do
          expect(response).to render_template :show
        end
      end
    end
  end

  describe 'POST #show' do
    context 'post valid pincode' do
      before(:each) do
        post :show, params: {id: event_with_pincode, pincode: '1234'}
      end

      it 'set cookie' do
        expect(response.cookies["events_#{event_with_pincode.id}_pincode"]).to eq '1234'
      end

      it 'render #show template' do
        expect(response).to render_template :show
      end
    end

    context 'post invalid pincode' do
      before(:each) do
        post :show, params: {id: event_with_pincode, pincode: '4321'}
      end

      it 'does not set cookie' do
        expect(response.cookies["events_#{event_with_pincode.id}_pincode"]).to be_nil
      end

      it 'render #password_form template' do
        expect(response).to render_template :password_form
      end

      it 'generate flash alert' do
        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end
  end

  describe 'GET #new' do
    context 'user is logged in' do
      before(:each) do
        sign_in user
        get :new
      end

      it 'render #new template' do
        expect(response).to render_template :new
      end

      it 'assigns new event to @event' do
        expect(assigns(:event)).to be_a_new(Event)
      end
    end

    context 'anon user' do
      before(:each) do
        get :new
      end

      it 'redirect to sign in path' do
        expect(response).to redirect_to new_user_session_path
      end

      it 'generate flash alert' do
        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end
  end

  describe 'GET #edit' do
    context 'user is owner of event' do
      before(:each) do
        sign_in user
        get :edit, params: {id: own_event}
      end

      it 'assigns event to @event' do
        expect(assigns(:event)).to eq own_event
      end

      it 'render #edit template' do
        expect(response).to render_template :edit
      end
    end

    context 'user is not owner of event' do
      before(:each) do
        sign_in user
        get :edit, params: {id: event}
      end

      it 'redirect to events path' do
        expect(response).to redirect_to events_path
      end

      it 'generate flash alert' do
        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end

    context 'anon user' do
      before(:each) do
        get :edit, params: {id: event}
      end

      it 'redirect to sign in path' do
        expect(response).to redirect_to new_user_session_path
      end

      it 'generate flash alert' do
        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end
  end

  describe 'POST #create' do
    context 'registered user' do
      before(:each) { sign_in user }

      context 'valid parameters' do
        it 'saves new event in database, assigns it to user' do
          expect { post :create, params: {event: attributes_for(:event)} }.to change(user.events, :count).by(1)
        end

        it 'redirects to event' do
          post :create, params: {event: attributes_for(:event)}

          expect(response).to redirect_to event_path(assigns(:event))
        end
      end

      context 'invalid parameters' do
        it 'does not save event in database' do
          expect { post :create, params: {event: attributes_for(:invalid_event)} }.not_to change(Event, :count)
        end

        it 're-render #new template' do
          post :create, params: {event: attributes_for(:invalid_event)}

          expect(response).to render_template :new
        end
      end
    end

    context 'anon user' do
      it 'does not save event in database' do
        expect { post :create, params: {event: attributes_for(:event)} }.not_to change(Event, :count)
      end

      it 'redirect to sign in path' do
        post :create, params: {event: attributes_for(:event)}

        expect(response).to redirect_to new_user_session_path
      end

      it 'generate flash alert' do
        post :create, params: {event: attributes_for(:event)}

        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end
  end

  describe 'PATCH #update' do
    context 'user is owner of event' do
      before(:each) { sign_in user }

      context 'valid attributes' do
        before(:each) do
          patch :update, params: { id: own_event, event: { title: 'new title', description: 'new description', address: 'new address', datetime: DateTime.parse('30.09.2017 14:00') } }
        end

        it 'assigns requested event to @event' do
          expect(assigns(:event)).to eq own_event
        end

        it 'change event attributes' do
          own_event.reload

          expect(own_event.title).to eq 'new title'
          expect(own_event.description).to eq 'new description'
          expect(own_event.address).to eq 'new address'
          expect(own_event.datetime).to eq DateTime.parse('30.09.2017 14:00')
        end

        it 'redirects to event' do
          expect(response).to redirect_to event_path(own_event)
        end
      end

      context 'invalid attributes' do
        before(:each) do
          patch :update, params: { id: own_event, event: { title: nil, description: 'new description', address: 'new address', datetime: DateTime.parse('30.09.2017 14:00') } }
        end

        it 'does not change event attributes' do
          own_event.reload

          # params from factory
          expect(own_event.title).to eq 'Супервечеринка'
          expect(own_event.description).to eq 'Вечеринка у Децла дома'
          expect(own_event.address).to eq 'дом Децла'
          expect(own_event.datetime).to eq DateTime.parse('31.12.2017 18:00')
        end

        it 're-renders edit template' do
          expect(response).to render_template :edit
        end
      end
    end

    context 'user is not owner of event' do
      before(:each) do
        sign_in user
        patch :update, params: { id: event, event: { title: 'new title', description: 'new description', address: 'new address', datetime: DateTime.parse('30.09.2017 14:00') } }
      end

      it 'does not change event attributes' do
        event.reload

        # params from factory
        expect(event.title).to eq 'Супервечеринка'
        expect(event.description).to eq 'Вечеринка у Децла дома'
        expect(event.address).to eq 'дом Децла'
        expect(event.datetime).to eq DateTime.parse('31.12.2017 18:00')
      end

      it 'redirect to events path' do
        expect(response).to redirect_to events_path
      end

      it 'generate flash alert' do
        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end

    context 'anon user' do
      before(:each) do
        patch :update, params: { id: event, event: { title: 'new title', description: 'new description', address: 'new address', datetime: DateTime.parse('30.09.2017 14:00') } }
      end

      it 'does not change event attributes' do
        event.reload

        # params from factory
        expect(event.title).to eq 'Супервечеринка'
        expect(event.description).to eq 'Вечеринка у Децла дома'
        expect(event.address).to eq 'дом Децла'
        expect(event.datetime).to eq DateTime.parse('31.12.2017 18:00')
      end

      it 'redirect to sign in path' do
        expect(response).to redirect_to new_user_session_path
      end

      it 'generate flash alert' do
        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      own_event
      event
    end

    context 'user tries to delete own event' do
      before(:each) { sign_in user }

      it 'deletes event' do
        expect { delete :destroy, params: { id: own_event } }.to change(Event, :count).by(-1)
      end

      it 'redirects to event path' do
        delete :destroy, params: { id: own_event }

        expect(response).to redirect_to events_path
      end
    end

    context 'user tries to delete not own event' do
      before(:each) { sign_in user }

      it 'does not delete event' do
        expect { delete :destroy, params: { id: event } }.not_to change(Event, :count)
      end

      it 'redirects to event path' do
        delete :destroy, params: { id: event }

        expect(response).to redirect_to events_path
      end
    end

    context 'anon user tries to delete event' do
      it 'does not delete event' do
        expect { delete :destroy, params: { id: event } }.not_to change(Event, :count)
      end

      it 'redirect to sign in path' do
        delete :destroy, params: { id: event }

        expect(response).to redirect_to new_user_session_path
      end

      it 'generate flash alert' do
        delete :destroy, params: { id: event }

        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end
  end
end
