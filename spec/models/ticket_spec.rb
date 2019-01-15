# encoding: utf-8
require 'rails_helper'

RSpec.describe Ticket, type: :model do
  context 'ticketに正常な値が渡された場合' do
    # サンプルユーザを作成
    before do
      create(:user1)
    end

    # サンプルユーザのチケットを作成
    let(:ticket) { Ticket.new(
      title: 'a' * 30,
      user_id: User.find_by(user_id: 'Taro')[:id],
      content: 'a' * 1000,
      status: 'TODO'
    ) }

    it 'バリデーションに引っかからないこと' do
      ticket.valid?
      expect(ticket).to be_valid
    end
  end

  context 'titleのバリデーションの場合' do
    let(:ticket) { Ticket.new() }

    it 'presenceバリデーションが効くこと' do
      ticket.valid?
      expect(ticket.errors.messages[:title]).to include("can't be blank")
    end

    it 'maximumバリデーションが効くこと' do
      ticket[:title] = 'a' * 31
      ticket.valid?
      expect(ticket.errors.messages[:title]).to include('is too long (maximum is 30 characters)')
    end
  end

  context 'Contentのバリデーションの場合' do
    let(:ticket) { Ticket.new() }

    it 'Contentへのpresentバリデーションが効くこと' do
      ticket.valid?
      expect(ticket.errors.messages[:content]).to include("can't be blank")
    end

    it 'Contentへのmaximumバリデーションが効くこと' do
      ticket[:content] = 'a' * 1001
      ticket.valid?
      expect(ticket.errors.messages[:content]).to include('is too long (maximum is 1000 characters)')
    end
  end

  context 'statusのバリデーションの場合' do
    # そもそもArgumentErrorになる
    # it 'statusへのバリデーションが効くこと' do
    #   ticket = Ticket.new()
    #   ticket[:status] = 'invalid'
    #   ticket.valid?
    #   expect(ticket.errors.messages[:status]).to include("is not included in the list")
    # end
  end
end
