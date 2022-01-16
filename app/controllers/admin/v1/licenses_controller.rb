module Admin::V1
  class LicensesController < ApiController
    before_action :load_license, only: [:show, :destroy, :update]

    def index
      game_licenses = License.where(game_id: params[:game_id])
      @loading_service = Admin::ModelLoadingService.new(game_licenses, searchable_params)
      @loading_service.call
    end

    def show; end

    def create
      @license = License.new
      @license.attributes = license_params
      save_license! :created
    end

    def update
      @license.attributes = license_params
      save_license!
    end

    def destroy
      @license = License.destroy(params[:id])
      @license.destroy!
    rescue StandardError
      render_error fields: @license.errors.messages
    end

    private

    def license_params
      return {} unless params.key?(:license)

      params.require(:license).permit(:id, :key, :game_id, :status, :platform)
    end

    def save_license!(status = :ok)
      @license.save!
      render :show, status: status
    rescue StandardError
      render_error fields: @license.errors.messages
    end

    def load_license
      @license = License.find(params[:id])
    end

    def load_licenses
      permitted_params = params.permit({ search: :key }, { order: {} }, :page, :length)
      @licenses = Admin::ModelLoadingService.new(License.all, permitted_params).call
    end

    def searchable_params
      params.permit({ search: :key}, { order: {}}, :page, :length)
    end
  end
end
