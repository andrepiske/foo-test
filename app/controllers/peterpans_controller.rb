class PeterpansController < ApplicationController
  def index
    render json: { 'hey' => 4 }
  end

  def show
    hl = HookLog.new(the_params: params.to_json)
    hl.save!

    # Rails.logger.info("Hey, looks those params: #{params.inspect}")

    render json: { key: 'pan!' }
  end

  def root
    render json: { works: 'yes, it works' }
  end
end
