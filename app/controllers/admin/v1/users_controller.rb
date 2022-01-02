module Admin::V1
  class UsersController < ApiController
    before_action :load_user, only: %i[update destroy]

    def index
      @users = User.all
    end

    def create
      @user = User.create
      @user.attributes = user_params
      save_user! :created
    end

    def update
      @user.attributes = user_params
      save_user! :ok
    end

    private

    def save_user!(status = :ok)
      @user.save!
      render :show, status: status
    rescue
      render_error fields: @user.errors.messages
    end

    def load_user
      @user = User.find(params[:id])
    end

    def user_params
      return {} unless params.has_key?(:user)

      params.require(:user).permit(:name, :email, :password, :password_confirmation, :profile)
    end
  end
end
