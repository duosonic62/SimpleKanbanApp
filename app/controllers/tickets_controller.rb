class TicketsController < ApplicationController
  before_action :set_ticket, only: [:detail, :edit, :update, :destroy, :upgrade, :downgrade]
  before_action :set_user
  before_action :require_sign_in!

  # チケットの一覧を表示する
  def show
    @todo_tickets = Ticket.where(user_id: @user.id).where(status: :TODO)
    @doing_tickets = Ticket.where(user_id: @user.id).where(status: :DOING)
    @done_tickets = Ticket.where(user_id: @user.id).where(status: :DONE)
  end

  # チケットの詳細を表示する
  def detail
  end

  # チケット作成画面を表示
  def new
    @ticket = Ticket.new(flash[:ticket])
  end

  # チケットを作成する
  def create
    @ticket = Ticket.new(ticket_params)
    @ticket.user_id = @user.id

    if @ticket.save
      # トップページに繊維
      redirect_to action: 'show'
    else
      # チケット作成ページに繊維
      redirect_to :back, flash: {
        ticket: @ticket,
        error_messages: @ticket.errors.full_messages
      }
    end
  end

  # チケットを編集する
  def edit
    # チケットの作成者が現在のユーザか？
    if !collect_user?
      redirect_to action: 'show'  
    end

    # フラッシュで編集時のオブジェクトが流れてきた時のみ@ticketにセットする
    if flash[:ticket]
      @ticket = Ticket.new(flash[:ticket])
    end
    @status = { TODO: 'TODO', DOING: 'DOING', DONE: 'DONE'}
  end

  # チケットを更新
  def update
    # チケットの作成者が現在のユーザか？
    if !collect_user?
      redirect_to action: 'show'  
    end
    if @ticket.update(ticket_params)
      redirect_to action: 'show'
    else
      binding.pry
      ticket = Ticket.new(ticket_params)
      redirect_to :back, flash: {
        ticket: ticket,
        error_messages: @ticket.errors.full_messages
      }
    end
  end

  # チケットをアップグレード
  def upgrade
    if @ticket.status == 'TODO'
      @ticket.update(status: :DOING)
    elsif @ticket.status == 'DOING'
      @ticket.update(status: :DONE)
    end
    redirect_to action: 'show'
  end

  # チケットをダウングレード
  def downgrade
    if @ticket.status == 'DOING'
      @ticket.update(status: :TODO)
    elsif @ticket.status == 'DONE'
      @ticket.update(status: :DOING)
    end
    redirect_to action: 'show'
  end
  
  # チケットを削除
  def destroy
    @ticket.destroy
    redirect_to action: 'show'
  end

    private
      # 選択したチケットをセット
      def set_ticket
        @ticket = Ticket.find(params[:id])
      end

      # ログイン中のuserをセット
      def set_user
        @user = current_user
      end

      # 編集されたくないものは取り除く
      def ticket_params
        params.require(:ticket).permit(:title, :content, :status)
      end

      # チケットの作成者が現在のユーザか？
      def collect_user?
        Ticket.find(params[:id])[:user_id] == @user[:id]
      end
end
