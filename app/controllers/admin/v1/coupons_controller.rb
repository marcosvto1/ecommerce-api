module Admin::V1
  class CouponsController < ApiController
    def index
      @coupons = Coupon.all
    end

    def create
      @coupon = Coupon.new
      @coupon.attributes = coupon_params
      @coupon.save!
    rescue
      render_error fields: @coupon.errors.messages
    end

    private

    def coupon_params
      return {} unless params.has_key? :coupon
      params.require(:coupon).permit(:id, :code, :due_date, :discount_value, :status)
    end
  end
end
