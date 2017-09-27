require 'rails_helper'

describe PhotosController, type: :controller do
  let!(:owner) { create(:user) }
  let!(:event) { create(:event, user: owner) }
  let!(:user) { create(:user) }
  let!(:subscription) { create(:subscription_with_user, user: user, event: event) }

  describe 'POST #create' do
    context 'valid attributes' do
      context 'event with no pincode' do
        context 'registered user creates photo' do
          before(:each) { sign_in user }

          it 'saves the new photo in the database' do
            expect { post :create, params: { photo: attributes_for(:photo), event_id: event } }.to change(event.photos, :count).by(1)
          end

          it 'photo assings to user' do
            expect { post :create, params: { photo: attributes_for(:photo), event_id: event } }.to change(user.photos, :count).by(1)
          end

          it 'redirect to event' do
            post :create, params: { photo: attributes_for(:photo), event_id: event }

            expect(response).to redirect_to event_path(event)
          end

          it 'sends an email notification to subscribers except user' do
            expect { post :create, params: { photo: attributes_for(:photo), event_id: event } }.to change { ActionMailer::Base.deliveries.count }.by(1)
          end
        end

        context 'anon user tries to create photo' do
          it 'does not save new photo' do
            expect { post :create, params: { photo: attributes_for(:photo), event_id: event } }.not_to change(Photo, :count)
          end

          it 'renders events#show' do
            post :create, params: { photo: attributes_for(:photo), event_id: event }

            expect(response).to render_template 'events/show'
          end
        end
      end

      context 'event with pincode' do
        let!(:event_with_pin) { create(:event, user: owner, pincode: '1234') }

        context 'pincode was not entered' do
          context 'registered user - owner of event' do
            before(:each) { sign_in owner }

            it 'saves the new photo in the database' do
              expect { post :create, params: { photo: attributes_for(:photo), event_id: event_with_pin } }.to change(event_with_pin.photos, :count).by(1)
            end
          end

          context 'registered user - not owner of event' do
            before(:each) { sign_in user }

            it 'does not save photo in the database' do
              expect { post :create, params: { photo: attributes_for(:photo), event_id: event_with_pin } }.not_to change(Photo, :count)
            end

            it 'generate flash alert' do
              post :create, params: { photo: attributes_for(:photo), event_id: event_with_pin }

              expect(flash[:notice]).to be_nil
              expect(flash[:alert]).to be
            end
          end

          context 'anon user' do
            it 'does not save photo in the database' do
              expect { post :create, params: { photo: attributes_for(:photo), event_id: event_with_pin } }.not_to change(Photo, :count)
            end

            it 'generate flash alert' do
              post :create, params: { photo: attributes_for(:photo), event_id: event_with_pin }

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

            it 'saves the new photo in the database' do
              expect { post :create, params: { photo: attributes_for(:photo), event_id: event_with_pin } }.to change(event_with_pin.photos, :count).by(1)
            end
          end

          context 'anon user' do
            it 'does not save new photo in the database' do
              expect { post :create, params: { photo: attributes_for(:photo), event_id: event_with_pin } }.not_to change(Photo, :count)
            end
          end
        end
      end
    end

    context 'invalid attributes' do
      context 'registered user tries to create invalid photo' do
        before(:each) { sign_in user }

        it 'does not save photo in database' do
          expect { post :create, params: { photo: attributes_for(:invalid_photo), event_id: event } }.not_to change(Photo, :count)
        end
      end

      context 'anon user tries to create invalid photo' do
        it 'does not save photo in database' do
          expect { post :create, params: { photo: attributes_for(:invalid_photo), event_id: event } }.not_to change(Photo, :count)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:photo) { create(:photo, user: user, event: event) }
    let!(:other_user_photo) { create(:photo, event: event) }

    it 'redirects to event' do
      delete :destroy, params: { id: photo, event_id: event }

      expect(response).to redirect_to event_path(event)
    end

    context 'owner of event tries to delete photo from event' do
      it 'deletes photo' do
        sign_in owner

        expect { delete :destroy, params: { id: other_user_photo, event_id: event } }.to change(Photo, :count).by(-1)
      end
    end

    context 'author of photo tries to delete own photo' do
      it 'deletes photo' do
        sign_in user

        expect { delete :destroy, params: { id: photo, event_id: event } }.to change(Photo, :count).by(-1)
      end
    end

    context 'registered user tries to delete non-own photo' do
      before(:each) { sign_in user }

      it 'does not delete photo' do
        expect { delete :destroy, params: { id: other_user_photo, event_id: event } }.not_to change(Photo, :count)
      end

      it 'generate flash alert' do
        delete :destroy, params: { id: other_user_photo, event_id: event }

        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end

    context 'anon user tries to delete photo' do
      it 'does not delete photo' do
        expect { delete :destroy, params: { id: photo, event_id: event } }.not_to change(Photo, :count)
      end

      it 'generate flash alert' do
        delete :destroy, params: { id: photo, event_id: event }

        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end
  end
end
