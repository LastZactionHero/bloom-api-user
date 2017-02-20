class YardsController < ApplicationController
  before_action :validate_signed_in
  before_action :find_and_authorize_yard, only: [:update, :destroy, :show]

  def index
    @yards = current_user.yards
  end

  def show
  end

  def create
    @yard = Yard.create(
      user: current_user,
      zipcode: params[:zipcode],
      zone: params[:zone],
      soil: params[:soil],
      preferred_plant_types: params[:preferred_plant_types]
    )
    if @yard.errors.any?
      render status: 400, json: { errors: @yard.errors }
      return
    end
    render status: 201
  end

  def update
    @yard.zipcode = params[:zipcode] if params[:zipcode].present?
    @yard.zone = params[:zone] if params[:zone].present?
    @yard.soil = params[:soil] if params[:soil].present?
    @yard.save

    if @yard.errors.any?
      render status: 400, json: { errors: @yard.errors }
      return
    end

    render status: 200
  end

  def destroy
    @yard.destroy
    head 200
  end

  private

  def find_and_authorize_yard
    begin
      @yard = Yard.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      head 404
      return
    end
    if @yard.user != current_user
      head 403
      return
    end
  end

end
