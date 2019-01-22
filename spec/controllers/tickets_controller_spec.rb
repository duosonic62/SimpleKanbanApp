# encoding: utf-8
require 'rails_helper'

RSpec.describe TicketsController, type: :controller do
  let (:user) { create(:user1) }
  let (:other_user) { create(:user2) }

  # ログイン状態を作る
  before(:each) do
    old_controller = @controller
    @controller = SessionsController.new
    user.id
    # user1でログインさせる
    post( :create, params: { session: { user_id: 'Taro', password: 'passw0rd' } } )
    @controller = old_controller
  end

  describe 'Get #show' do
    context 'ログインしている場合' do
      before do 
        get :show 
      end
      it 'レスポンスコードが200であること' do
        expect(response).to have_http_status(:ok)
      end

      it 'newテンプレートをレンダリングすること' do
        expect(response).to render_template :show
      end

      it 'todoチケットのオブジェクトがビューに渡されること' do
        expect(assigns[:todo_tickets].size).to eq 1
      end

      it 'doingチケットのオブジェクトがビューに渡されること' do
        expect(assigns[:doing_tickets].size).to eq 1
      end

      it 'doneチケットのオブジェクトがビューに渡されること' do
        expect(assigns[:done_tickets].size).to eq 1
      end
    end
  end

  describe 'Get #detail' do
    context 'ログインしている場合' do
      let (:ticket) { user.ticket.first }
      before do
        get :detail, params: { id: ticket.id }
      end

      it 'レスポンスコードが200であること' do
        expect(response).to have_http_status(:ok)
      end

      it 'detailテンプレートをレンダリングすること' do
        expect(response).to render_template :detail
      end

      it 'チケットのオブジェクトがビューに渡されること' do
        expect(assigns[:ticket]).to eq ticket
      end
    end
  end

  describe 'Get #new' do
    context 'ログインしている場合' do
      before do
        get :new
      end

      it 'レスポンスコードが200であること' do
        expect(response).to have_http_status(:ok)
      end

      it 'newテンプレートをレンダリングすること' do
        expect(response).to render_template :new
      end

      it '新しいticketオブジェクトがビューに渡されること' do
        expect(assigns(:ticket)).to be_a_new Ticket
      end
    end
  end

  describe 'Post #create' do
    context 'パラメータが正しい場合' do
      let (:params) do { ticket: 
          {
            title: 'test_title',
            content: 'test_content',
            status: 'TODO'
          }
        }
      end

      it 'showにリダイレクトされること' do
        post(:create, params: params)
        expect(response).to redirect_to action: 'show'
      end
      
      it 'チケットが一つ増えていること' do
        expect{ post :create, params: params }.to change(Ticket, :count).by(1)
      end
    end

    context 'パラメータが不正な場合' do
      before do
        @referer = 'http://localhost'
        @request.env['HTTP_REFERER'] = @referer
        post(:create, params: {
          ticket: {
            title: '',
            content: '',
            status: 'TODO'
          }
        })
      end

      it 'リファラーにリダイレクトされること' do
        expect(response).to redirect_to(@referer)
      end

      it 'titleにエラーメッセージが含まれていること' do
        expect(flash[:error_messages]).to include "Title can't be blank"
      end

      it 'contentにエラーメッセージが含まれていること' do
        expect(flash[:error_messages]).to include "Content can't be blank"
      end
    end
  end

  describe 'Get #edit' do
    context 'ユーザ自身のチケットを編集しようとした場合' do
      let (:ticket) { user.ticket.first }
      before do
        get :edit, params: { id: ticket.id }
      end

      it 'レスポンスコードが200であること' do
        expect(response).to have_http_status(:ok)
      end

      it 'editテンプレートをレンダリングすること' do
        expect(response).to render_template :edit
      end

      it 'チケットのオブジェクトがビューに渡されること' do
        expect(assigns[:ticket]).to eq ticket
      end
    end

    context '他ユーザのチケットを編集しようとした場合' do
      let (:ticket) { other_user.ticket.first }
      before do
        get :edit, params: { id: ticket.id }
      end

      it 'showにリダイレクトされること' do
        expect(response).to redirect_to action: 'show'
      end

      it '不正なアクセスを伝えるエラーメッセージが含まれていること' do
        expect(flash[:error_messages]).to include 'Error! Unauthorized access.'
      end
    end
  end
  
  describe 'Post #update' do 
    context 'パラメータが正しい場合' do
      let (:ticket) { user.ticket.first }
      let (:params) do { 
          id: ticket.id,
          ticket: {
            title: 'Test title',
            content: 'Test content',
            status: 'DOING'
          }
        }
      end

      it 'showにリダイレクトされること' do
        post(:update, params: params)
        expect(response).to redirect_to action: 'show'
      end

      it 'チケットが更新されていること' do
        post(:update, params: params)
        expect(user.ticket.first[:title]).to eq params[:ticket][:title]
        expect(user.ticket.first[:content]).to eq params[:ticket][:content]
        expect(user.ticket.first[:status]).to eq params[:ticket][:status]
      end
    end

    context 'パラメータが不正な場合' do
      let (:ticket) { user.ticket.first }
      before do
        @referer = 'http://localhost'
        @request.env['HTTP_REFERER'] = @referer
        post(:update, 
          params: {
            id: ticket.id,
            ticket:{
              title: '',
              content: '',
              status: 'DOING'
            }
        })
      end

      it 'リファラーにリダイレクトされること' do
        expect(response).to redirect_to(@referer)
      end

      it 'titleにエラーメッセージが含まれていること' do
        expect(flash[:error_messages]).to include "Title can't be blank"
      end

      it 'contentにエラーメッセージが含まれていること' do
        expect(flash[:error_messages]).to include "Content can't be blank"
      end

    end
  end

  describe 'Post #upgrade' do
    context 'TODEのアイテムがパラメータで渡された場合' do
      let (:ticket) { user.ticket.find_by(status: 'TODO') }
      let (:params) { {id: ticket.id} }

      it 'showにリダイレクトされること' do
        post(:upgrade, params: params)
        expect(response).to redirect_to action: 'show'
      end

      it 'TODEからDOINGにステータスが更新されていること' do
        post(:upgrade, params: params)
        expect(user.ticket.find(ticket.id).status).to eq 'DOING'
      end
    end

    context 'DOINGのアイテムがパラメータで渡された場合' do
      let (:ticket) { user.ticket.find_by(status: 'DOING') }
      let (:params) { {id: ticket.id} }

      it 'showにリダイレクトされること' do
        post(:upgrade, params: params)
        expect(response).to redirect_to action: 'show'
      end

      it 'DOINGからDONEにステータスが更新されていること' do
        post(:upgrade, params: params)
        expect(user.ticket.find(ticket.id).status).to eq 'DONE'
      end
    end

    context 'DONEのアイテムがパラメータで渡された場合' do
      let (:ticket) { user.ticket.find_by(status: 'DONE') }
      let (:params) { {id: ticket.id} }

      it 'showにリダイレクトされること' do
        post(:upgrade, params: params)
        expect(response).to redirect_to action: 'show'
      end

      it 'DONEからステータスが更新されていないこと' do
        post(:upgrade, params: params)
        expect(user.ticket.find(ticket.id).status).to eq 'DONE'
      end
    end
  end

  describe 'Post #downgrade' do
    context 'TODEのアイテムがパラメータで渡された場合' do
      let (:ticket) { user.ticket.find_by(status: 'TODO') }
      let (:params) { {id: ticket.id} }

      it 'showにリダイレクトされること' do
        post(:downgrade, params: params)
        expect(response).to redirect_to action: 'show'
      end

      it 'TODEからステータスが更新されていないこと' do
        post(:downgrade, params: params)
        expect(user.ticket.find(ticket.id).status).to eq 'TODO'
      end
    end

    context 'DOINGのアイテムがパラメータで渡された場合' do
      let (:ticket) { user.ticket.find_by(status: 'DOING') }
      let (:params) { {id: ticket.id} }

      it 'showにリダイレクトされること' do
        post(:downgrade, params: params)
        expect(response).to redirect_to action: 'show'
      end

      it 'DOINGからTODEにステータスが更新されていること' do
        post(:downgrade, params: params)
        expect(user.ticket.find(ticket.id).status).to eq 'TODO'
      end
    end

    context 'DONEのアイテムがパラメータで渡された場合' do
      let (:ticket) { user.ticket.find_by(status: 'DONE') }
      let (:params) { {id: ticket.id} }

      it 'showにリダイレクトされること' do
        post(:downgrade, params: params)
        expect(response).to redirect_to action: 'show'
      end

      it 'DONEからDOINGにステータスが更新されていること' do
        post(:downgrade, params: params)
        expect(user.ticket.find(ticket.id).status).to eq 'DOING'
      end
    end
  end

  describe 'Delete #destroy' do
    context 'ログイン中のユーザのチケットがパラメータで渡された場合' do
      let (:ticket) { user.ticket.first }
      let (:params) { {id: ticket.id} }

      it 'showにリダイレクトされること' do
        delete(:destroy, params: params)
        expect(response).to redirect_to action: 'show'
      end

      it 'チケットが削除されていること' do
        delete(:destroy, params: params)
        expect(user.ticket.exists?(ticket.id)).to be_falsey
      end
    end

    context '他ユーザのチケットがパラメータで渡された場合' do
      let (:other_users_ticket) { other_user.ticket.first }
      let (:params) { {id: other_users_ticket.id} }

      it 'showにリダイレクトされること' do
        delete(:destroy, params: params)
        expect(response).to redirect_to action: 'show'
      end

      it 'チケットが削除されていないこと' do
        delete(:destroy, params: params)
        expect(Ticket.exists?(other_users_ticket.id)).to be_truthy
      end

      it '不正なアクセスを伝えるエラーメッセージが含まれていること' do
        delete(:destroy, params: params)
        expect(flash[:error_messages]).to include 'Error! Unauthorized access.'
      end
    end
  end

end