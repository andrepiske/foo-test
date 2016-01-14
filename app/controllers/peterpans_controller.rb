class PeterpansController < ApplicationController
  def index
    render json: { 'hey' => 4 }
  end

  def show
    render json: { key: 'pan!' }
  end

  def root
    render json: { works: 'yes, it works' }
  end
end
