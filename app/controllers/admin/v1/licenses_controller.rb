module Admin::V1
  class LicensesController < ApiController
    before_action :load_license, only: [:show, :destroy, :update]

    def index
      @loading_service = Admin::ModelLoadingService.new(License.all, searchable_params)
      @loading_service.call
    end

    def show; end

    def create
      @license = License.new
      @license.attributes = license_params
      save_license! :created
    end

    private

    def license_params
      return {} unless params.has_key?(:license)
      params.require(:license).permit(:id, :key, :game_id, :status, :platform)
    end

    def save_license!(status = :ok)
      @license.save!
      render :show, status: status
    rescue
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
