module Admin::V1
  class ApiController < ApplicationController
    include Authenticable


    def render_error(messages: nil, fields: nil, status: :unprocessable_entity)
      errors = {}
      errors['fields'] = fields if fields.present?
      errors['messages'] = messages if messages.present?

      render json: { errors: errors }, status: status
    end
  end
end
