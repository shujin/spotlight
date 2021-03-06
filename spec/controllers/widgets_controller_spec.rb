require 'rails_helper'

RSpec.describe WidgetsController, type: :controller do
  let!(:user) { User.create email: 'spotlight@pivotal.io', auth_token: 'fake-auth-token' }
  let(:valid_session) { {} }

  describe 'GET #new' do
    context 'when user is logged in' do
      before do
        session[:current_user] = user
      end

      it 'assigns a new widget as @widget' do
        get :new, {category: 'ci_widget'}
        expect(assigns(:widget)).to be_a_new(Widget)
        expect(assigns(:widget).category).to be_a Category::CiWidget
      end
    end

    context 'when user is not logged in' do
      it 'returns http unauthorized' do
        get :new, {category: 'ci_widget'}

        expect(response).to be_unauthorized
      end
    end
  end

  describe 'POST #create' do
    let!(:dashboard) { FactoryGirl.create :dashboard  }
    let(:valid_attributes) do
      {
        title: 'test',
        category: 'ci_widget',
        server_type: 'travis_ci',
        server_url: 'https://api.travis-ci.com',
        auth_key: 'access_token',
        project_name: 'neo/spotlight',
        height: '2',
        width: '2'
      }
    end

    context 'when user is logged in' do
      before do
        session[:current_user] = user
      end

      context 'with valid params' do
        it 'creates a new Widget' do
          expect {
            post :create, {:widget => valid_attributes}
          }.to change(Widget, :count).by(1)
        end

        it 'assigns a newly created widget as @widget' do
          post :create, {:widget => valid_attributes}
          expect(assigns(:widget)).to be_a(Widget)
          expect(assigns(:widget)).to be_persisted
        end

        it 'redirects to the dashboard' do
          post :create, {:widget => valid_attributes}
          expect(response).to redirect_to(ENV['WEB_HOST'])
        end

        it 'saves the widget title and size' do
          post :create, {:widget => valid_attributes}
          new_widget = Widget.last
          expect(new_widget.title).to eq 'test'
          expect(new_widget.height).to eq 2
          expect(new_widget.width).to eq 2
        end

        context 'with a field in csv format' do
          let(:valid_attributes) do
            {
                category: 'openair_widget',
                user_emails: 'user1@example.com, user2@example.com'
            }
          end

          it 'saves the widget with the processed field' do
            post :create, widget: valid_attributes

            expect(assigns(:widget).user_emails).to eq %w(user1@example.com user2@example.com)
          end
        end
      end

      context 'with invalid params' do
        context 'title missing' do
          let(:invalid_attributes) { {title: nil, category: 'ci_widget'} }

          it 'assigns a newly created but unsaved widget as @widget' do
            post :create, {:widget => invalid_attributes}
            expect(assigns(:widget)).to be_a_new(Widget)
          end

          it "re-renders the 'new' template" do
            post :create, {:widget => invalid_attributes}
            expect(response).to render_template('new')
          end
        end

        context 'title is too long' do
          let(:invalid_attributes) { {title: Faker::Lorem.characters(61), category: 'ci_widget' } }

          it 'assigns a newly created but unsaved widget as @widget' do
            post :create, {:widget => invalid_attributes}
            expect(assigns(:widget)).to be_a_new(Widget)
          end

          it "re-renders the 'new' template" do
            post :create, {:widget => invalid_attributes}
            expect(response).to render_template('new')
          end
        end
      end
    end

    context 'when user is not logged in' do
      it 'returns http unauthorized' do
        post :create, {widget: valid_attributes}

        expect(response).to be_unauthorized
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:widget) { FactoryGirl.create :widget, :with_default_dashboard }

    context 'when user is logged in' do
      before do
        session[:current_user] = user
      end

      it 'deletes the widget' do
        expect {
          delete :destroy, id: widget.id
        }.to change{Widget.count}.from(1).to(0)
      end

      it 'redirects to dashboard' do
        delete :destroy, id: widget.id
        expect(response).to redirect_to(ENV['WEB_HOST'])
      end
    end

    context 'when user is not logged in' do
      it 'returns http unauthorized' do
        delete :destroy, id: widget.id

        expect(response).to be_unauthorized
      end
    end
  end
end
