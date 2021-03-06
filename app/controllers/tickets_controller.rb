class TicketsController < ApplicationController
  before_action :set_ticket, only: [:detail, :edit, :update, :destroy, :upgrade, :downgrade]
  before_action :set_user
  before_action :require_sign_in!
  before_action :unauthorized_access, only: [:detail, :edit, :update, :destroy, :upgrade, :downgrade]

  # チケットの一覧を表示する
  def show
    @todo_tickets = Ticket.where(user_id: @user.id).where(status: :TODO)
    @doing_tickets = Ticket.where(user_id: @user.id).where(status: :DOING)
    @done_tickets = Ticket.where(user_id: @user.id).where(status: :DONE)
  end

  # チケットの詳細を表示する
  def detail
    if !collect_user?
      redirect_to action: 'show'  
    end
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
      flash[:error_messages] = @ticket.errors.full_messages
      flash[:ticket] = @ticket
      redirect_back(fallback_location: root_path)
    end
  end

  # チケットを編集する
  def edit
    # フラッシュで編集時のオブジェクトが流れてきた時のみ@ticketにセットする
    if flash[:ticket]
      @ticket = Ticket.new(flash[:ticket])
    end
    @status = { TODO: 'TODO', DOING: 'DOING', DONE: 'DONE'}
  end

  # チケットを更新
  def update
    if @ticket.update(ticket_params)
      redirect_to action: 'show'
    else
      ticket = Ticket.new(ticket_params)
      flash[:error_messages] = @ticket.errors.full_messages
      flash[:ticket] = ticket
      redirect_back(fallback_location: root_path)
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
      rescue
        flash[:error_messages] = ['Error! Unauthorized access.']
        redirect_to action: 'show'
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
        @user.ticket.exists?(params[:id])
      end

      # 不正なチケットアクセスの対処
      def unauthorized_access 
        if !collect_user?
          flash[:error_messages] = ['Error! Unauthorized access.']
          redirect_to action: 'show'
        end
      end
end
