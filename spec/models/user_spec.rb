# encoding: utf-8
require 'rails_helper'

RSpec.describe User, type: :model do
  # ランダムトークンの取得
  describe '#new_remember_token' do
    context '値を取得した場合' do
      it '2回呼び出した値がランダムに生成されていること' do
        expect(User.new_remember_token).not_to eq User.new_remember_token
      end
    end
  end

  # SHA256でのダイジェスト取得
  describe '#encrypt' do
    context 'ダイジェストを取得' do
      it 'ダイジェストが取得できていること' do
        expect(User.encrypt('test_token')).to eq 'cc0af97287543b65da2c7e1476426021826cab166f1e063ed012b855ff819656'
      end
    end
  end

  # バリデーション
  context 'バリデーションにかからない場合' do
    let (:user) { build_stubbed(:user1) }

    it 'バリデーションにかからないこと' do
      user.valid?
      expect(user).to be_valid
    end
  end

  context 'user_idのバリデーションの場合' do
    let (:user) { User.new }
    it 'user_idへのprecsenceバリデーションが効くこと' do
      user.valid?
      expect(user.errors.messages[:user_id]).to include("can't be blank")
    end

    it 'user_idへのmaximumバリデーションが効くこと' do
      user[:user_id] = 'a' * 11
      user.valid?
      expect(user.errors.messages[:user_id]).to include('is too long (maximum is 10 characters)')
    end

    it 'user_idへのuniquenessバリデーションが効くこと' do
      create(:user1)
      user = build_stubbed(:user1)
      user.valid?
      expect(user.errors.messages[:user_id]).to include('has already been taken')
    end
  end

  context 'nameへのバリデーションの場合' do
    let(:user) { User.new() }

    it 'nameへのpresenceバリデーションが効くこと' do
      user.valid?
      expect(user.errors.messages[:name]).to include("can't be blank")
    end

    it 'nameへのmaximumバリデーションが効くこと' do
      user[:name] = 'a' * 11
      user.valid?
      expect(user.errors.messages[:name]).to include('is too long (maximum is 10 characters)')
    end
  end

  # passwordへのバリデーションはhas_secure_passwordで実装
  # context 'passwordへのバリデーションの場合' do
  #   let(:user) { User.new() }

  #   it 'passwordへのpresenceバリデーションが効くこと' do
  #     user.valid?
  #     expect(user.errors.messages[:name]).to include("can't be blank")
  #   end

  #   it 'passwordへのmaximumバリデーションが効くこと' do
  #     user[:password] = 'a' * 73
  #     user.valid?
  #     expect(user.errors.messages[:password_confirmation]).to include('is too long (maximum is 72 characters)')
  #   end

  #   it 'passwordへのmaximumバリデーションが効くこと' do
  #     user[:password] = 'a' * 8
  #     user[:password_confirmation] = 'a' * 7
  #     user.valid?
  #     expect(user.errors.messages[:password_confirmation]).not_to include("doesn't match Password")
  #   end

  # end
end
