# encoding: utf-8
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  # newメソッド
  describe 'Get #new' do
    context 'ユーザの新規作成' do
      before { get :new }
      it 'レスポンスコードが200であること' do
        expect(response).to have_http_status(:ok)
      end

      it 'newテンプレートをレンダリングすること' do
        expect(response).to render_template :new
      end

      it '新しいuserオブジェクトがビューに渡されること' do
        expect(assigns(:user)).to be_a_new User
      end
    end
  end

  describe 'Post #create' do
    before do
      @referer = 'http://localhost'
      @request.env['HTTP_REFERER'] = @referer
    end

    context 'パラメータが正常な場合' do
      let(:params) do { 
        user:{
          user_id: 'test_user',
          name: 'user',
          password: 'password',
          password_confirmation: 'password'
        }
       }
      end

      it 'ユーザが一人増えていること' do
        expect{ post :create, params: params }.to change(User, :count).by(1)
      end

      it 'ログインページにリダイレクトされること' do
        expect(post :create, params: params).to redirect_to(controller: 'tickets', action: 'show')
      end
    end

    context 'パラメータが不正な場合' do
      let(:params) do { 
        user:{
          user_id: 'test_user',
          name: 'a' * 11,
          password: 'password',
          password_confirmation: 'invalid_password'
        }
       }
      end

      before { post(:create, params: params) }

      it 'リファラーにリダイレクトされること' do
        expect(response).to redirect_to(@referer)
      end

      it 'パスワード確認のエラーメッセージが含まれていること' do
        expect(flash[:error_messages]).to include "Password confirmation doesn't match Password"
      end
    end
  end
end
