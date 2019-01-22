# encoding: utf-8
require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  # newメソッド
  describe 'Get #new' do
    context 'ログインしていない状態' do
      before { get :new }

      it 'レスポンスコードが200' do
        expect(response).to have_http_status(:ok)
      end

      it 'newテンプレートをレンダリング' do
        expect(response).to render_template :new
      end
    end
  
    context 'ログインしている状態' do
      let(:params) do
        { session: {
            user_id: 'Taro',
            password: 'passw0rd'
          }
        }
      end
      # ログイン状態を作る
      before(:each) do
        # user1を生成する
        create(:user1)
        # user1でログインさせる
        post( :create, params: params )
      end

      it 'トップページに遷移すること' do
        # expect(get :new).to redirect_to("/top")
        expect(get :new).to redirect_to(controller: 'tickets', action: 'show')
      end
    end
  end

  # createメソッド
  describe 'Post #create' do
    context '正しいユーザ情報' do
      let(:params) do
        { session: {
            user_id: 'Taro',
            password: 'passw0rd'
          }
        }
      end

      it 'ログインすること' do
        create(:user1)
        expect(post :create, params: params).to redirect_to(controller: 'tickets', action: 'show')
      end
    end
  end

  # destroyメソッド
  describe 'Delete #destroy' do
    context 'ログインしていた場合' do
      let(:params) do
        { session: {
            user_id: 'Taro',
            password: 'passw0rd'
          }
        }
      end
      # ログイン状態を作る
      before(:each) do
        # user1を生成する
        create(:user1)
        # user1でログインさせる
        post( :create, params: params )
      end

      it 'ログアウトすること' do
        expect(delete :destroy).to redirect_to action: 'new'
      end
    end

    context 'ログインしていなかった場合' do
      it 'ログイン画面に繊維すること' do
        expect(delete :destroy).to redirect_to action: 'new'
      end
    end
  end

end