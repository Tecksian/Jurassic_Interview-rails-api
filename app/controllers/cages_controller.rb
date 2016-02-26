class CagesController < ApplicationController
  before_action :set_cage, only: [:show, :update, :destroy]

  # GET /cages
  # GET /cages.json
  def index
    if params[:status].nil?
      @cages = Cage.all
    else
      @cages = Cage.cage_status_filter(params[:status])
    end
    expose @cages
  end

  # GET /cages/1
  # GET /cages/1.json
  def show
    expose @cage, {root: :true, include: :dinosaurs}
  end

  # POST /cages
  # POST /cages.json
  def create
    @cage = Cage.new(cage_params)

    if @cage.save
      expose @cage, status: :created, location: @cage
    else
      error!(:invalid_resource, @cage.errors)
    end
  end

  # PATCH/PUT /cages/1
  # PATCH/PUT /cages/1.json
  def update
    @cage = Cage.find(params[:id])

    if @cage.update(cage_params)
      head :no_content
    else
      error! :invalid_resource ,@cage.errors.messages, status: :unprocessable_entity
    end
  end

  # DELETE /cages/1
  # DELETE /cages/1.json
  def destroy
    @cage.destroy

    head :no_content
  end

  private

  def set_cage
    @cage = Cage.find(params[:id])
  end

  def cage_params
    params.require(:cage).permit(:max_occupancy, :powered_up, :status)
  end
end
