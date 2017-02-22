class BedsController < ApplicationController
  before_action :validate_signed_in
  before_action :find_and_authorize_yard, only: [:create]
  before_action :find_and_authorize_bed, only: [:update, :destroy, :show]

  def index
  end

  def show
  end

  def create
    @bed = Bed.create(
      yard: @yard,
      name: params[:name],
      width: params[:width].to_f,
      depth: params[:depth].to_f,
      orientation: params[:orientation],
      attached_to_house: params[:attached_to_house].to_bool,
      sunlight_morning: params[:sunlight_morning],
      sunlight_afternoon: params[:sunlight_afternoon],
      watered: params[:watered].to_bool
    )
    if @bed.errors.any?
      render status: 400, json: { errors: @bed.errors }
      return
    end

    render status: 201
  end

  def update
    @bed.name = params[:name] if params[:name]
    @bed.width = params[:width].to_f if params[:width]
    @bed.depth = params[:depth].to_f if params[:depth]
    @bed.orientation = params[:orientation] if params[:orientation]
    @bed.attached_to_house = params[:attached_to_house].to_bool unless params[:attached_to_house].nil?
    @bed.sunlight_morning = params[:sunlight_morning] if params[:sunlight_morning]
    @bed.sunlight_afternoon = params[:sunlight_afternoon] if params[:sunlight_afternoon]
    @bed.watered = params[:watered].to_bool unless params[:watered].nil?
    @bed.save

    if @bed.errors.any?
      render status: 400, json: { errors: @bed.errors }
      return
    end

    render status: 200
  end

  def destroy
    @bed.destroy
    head 200
  end

  private

  def find_and_authorize_bed
    begin
      @bed = Bed.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      head 404
      return
    end

    if @bed.yard.nil? || @bed.yard.user != current_user
      head 403
      return
    end
  end

  def find_and_authorize_yard
    begin
      @yard = Yard.find(params[:yard_id])
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
