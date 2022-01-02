module Admin::V1
  class UsersController < ApiController
    def index
      @users = User.all
    end

    def create
      @user = User.create
      @user.attributes = user_params
      save_user!
      render :show, status: :created
    end

    private

    def save_user!
      @user.save!
    rescue
      render_error fields: user.errors.messages
    end

    def user_params
      return {} unless params.has_key?(:user)

      params.require(:user).permit(:name, :email, :password, :password_confirmation, :profile)
    end
  end
end
