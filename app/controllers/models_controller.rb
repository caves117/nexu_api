class ModelsController < ApplicationController
  before_action :set_model, only: %i[ show update destroy ]

  # GET /models
  def index

    if (request.query_parameters[:greater].present? && request.query_parameters[:lower].present? )
      @models = Model.where("average_price < :lower OR average_price > :greater", lower: request.query_parameters[:lower], greater: request.query_parameters[:greater])
    elsif request.query_parameters[:greater].present?
      @models = Model.where("average_price > ?", request.query_parameters[:greater])
    elsif request.query_parameters[:lower].present?
      @models = Model.where("average_price < ?", request.query_parameters[:lower])
    elsif params[:brand_id]
      @models = Brand.find_by_id(params[:brand_id]).models 
    else
      @models = Model.all
    end

    render json: @models
  end

  # GET /models/1
  def show
    render json: @model
  end

  # POST /models
  def create
    @model = Model.new(model_params)
    @model.brand_id = params[:brand_id]

    if Model.exists?(name: @model.name)
      render json: '{"error": "El modelo ya existe"}', status: :unprocessable_entity
    elsif @model.average_price != 0 && @model.average_price <= 100000
      render json: '{"error": "El precio promedio debe ser mayor a 100,000"}', status: :unprocessable_entity
    elsif @model.save
      render json: @model, status: :created, location: @model
    else
      render json: @model.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /models/1
  def update
    if @model.update(model_params)
      if @model.average_price > 100000.0
          render json: @model
      else
        render json: '{"error":"El precio promedio debe ser mayor a 100,000"}', status: :unprocessable_entity
      end
    else
      render json: @model.errors, status: :unprocessable_entity
    end
  end

  # DELETE /models/1
  def destroy
    @model.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_model
      @model = Model.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def model_params
      params.require(:model).permit(:brand_id, :name, :average_price)
    end
end
