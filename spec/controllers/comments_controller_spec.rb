require 'rails_helper'

describe CommentsController, type: :controller do
  let!(:owner) { create(:user) }
  let!(:event) { create(:event, user: owner) }
  let!(:user) { create(:user) }
  let!(:subscription) { create(:subscription_with_user, user: user, event: event) }

  describe 'POST #create' do
    context 'valid attributes' do
      context 'event with no pincode' do
        context 'registered user creates comment' do
          before(:each) { sign_in user }

          it 'saves the new comment in the database' do
            expect { post :create, params: { comment: attributes_for(:comment_with_author), event_id: event } }.to change(event.comments, :count).by(1)
          end

          it 'comment assings to user' do
            expect { post :create, params: { comment: attributes_for(:comment_with_author), event_id: event } }.to change(user.comments, :count).by(1)
          end

          it 'redirect to event' do
            post :create, params: { comment: attributes_for(:comment_with_author), event_id: event }

            expect(response).to redirect_to event_path(event)
          end

          it 'sends an email notification to subscribers except user' do
            expect { post :create, params: { comment: attributes_for(:comment_with_author), event_id: event } }.to change { ActionMailer::Base.deliveries.count }.by(1)
          end
        end

        context 'anon user creates comment' do
          it 'saves the new comment in the database' do
            expect { post :create, params: { comment: attributes_for(:comment), event_id: event } }.to change(event.comments, :count).by(1)
          end

          it 'redirect to event' do
            post :create, params: { comment: attributes_for(:comment), event_id: event }

            expect(response).to redirect_to event_path(event)
          end

          it 'sends an email notification to subscribers' do
            expect { post :create, params: { comment: attributes_for(:comment), event_id: event } }.to change { ActionMailer::Base.deliveries.count }.by(2)
          end
        end
      end

      context 'event with pincode' do
        let!(:event_with_pin) { create(:event, user: owner, pincode: '1234') }

        context 'pincode was not entered' do
          context 'registered user - owner of event' do
            before(:each) { sign_in owner }

            it 'saves the new comment in the database' do
              expect { post :create, params: { comment: attributes_for(:comment_with_author), event_id: event_with_pin } }.to change(event_with_pin.comments, :count).by(1)
            end
          end

          context 'registered user - not owner of event' do
            before(:each) { sign_in user }

            it 'does not save comments in the database' do
              expect { post :create, params: { comment: attributes_for(:comment_with_author), event_id: event_with_pin } }.not_to change(Comment, :count)
            end

            it 'generate flash alert' do
              post :create, params: { comment: attributes_for(:comment_with_author), event_id: event_with_pin }

              expect(flash[:notice]).to be_nil
              expect(flash[:alert]).to be
            end
          end

          context 'anon user' do
            it 'does not save comments in the database' do
              expect { post :create, params: { comment: attributes_for(:comment), event_id: event_with_pin } }.not_to change(Comment, :count)
            end

            it 'generate flash alert' do
              post :create, params: { comment: attributes_for(:comment), event_id: event_with_pin }

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

            it 'saves the new comment in the database' do
              expect { post :create, params: { comment: attributes_for(:comment_with_author), event_id: event_with_pin } }.to change(event_with_pin.comments, :count).by(1)
            end
          end

          context 'anon user' do
            it 'saves the new comment in the database' do
              expect { post :create, params: { comment: attributes_for(:comment), event_id: event_with_pin } }.to change(event_with_pin.comments, :count).by(1)
            end
          end
        end
      end
    end

    context 'invalid attributes' do
      context 'registered user tries to create invalid comment' do
        before(:each) { sign_in user }

        it 'does not save comment in database' do
          expect { post :create, params: { comment: attributes_for(:invalid_comment), event_id: event } }.not_to change(Comment, :count)
        end
      end

      context 'anon user tries to create invalid comment' do
        it 'does not save comment in database' do
          expect { post :create, params: { comment: attributes_for(:invalid_comment), event_id: event } }.not_to change(Comment, :count)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:comment1) { create(:comment_with_author, user: user, event: event) }
    let!(:comment2) { create(:comment, event: event) }

    it 'redirects to event' do
      delete :destroy, params: { id: comment1, event_id: event }

      expect(response).to redirect_to event_path(event)
    end

    context 'owner of event tries to delete comment from event' do
      it 'deletes comment' do
        sign_in owner

        expect { delete :destroy, params: { id: comment1, event_id: event } }.to change(Comment, :count).by(-1)
      end
    end

    context 'author of comment tries to delete own comment' do
      it 'deletes comment' do
        sign_in user

        expect { delete :destroy, params: { id: comment1, event_id: event } }.to change(Comment, :count).by(-1)
      end
    end

    context 'registered user tries to delete non-own comment' do
      before(:each) { sign_in user }

      it 'does not delete comment' do
        expect { delete :destroy, params: { id: comment2, event_id: event } }.not_to change(Comment, :count)
      end

      it 'generate flash alert' do
        delete :destroy, params: { id: comment2, event_id: event }

        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end

    context 'anon user tries to delete comment' do
      it 'does not delete comment' do
        expect { delete :destroy, params: { id: comment2, event_id: event } }.not_to change(Comment, :count)
      end

      it 'generate flash alert' do
        delete :destroy, params: { id: comment2, event_id: event }

        expect(flash[:alert]).to be
        expect(flash[:notice]).to be_nil
      end
    end
  end
end
