class DinosaursController < ApplicationController
  before_action :set_dinosaur, only: [:show, :update, :destroy]

  # GET /dinosaurs
  # GET /dinosaurs.json
  def index
    @dinosaurs = Dinosaur.all

    expose @dinosaurs
  end

  # GET /dinosaurs/1
  # GET /dinosaurs/1.json
  def show
    expose @dinosaur
  end

  # POST /dinosaurs
  # POST /dinosaurs.json
  def create
    @dinosaur = Dinosaur.new(dinosaur_params)
    if @dinosaur.save
      expose @dinosaur, status: :created, location: @dinosaur
    else
      error! :invalid, metadata: @dinosaur
    end
  end

  # PATCH/PUT /dinosaurs/1
  # PATCH/PUT /dinosaurs/1.json
  def update
    @dinosaur = Dinosaur.find(params[:id])

    if @dinosaur.update(dinosaur_params)
      head :no_content
    else
      expose @dinosaur.errors, status: :unprocessable_entity
    end
  end

  # DELETE /dinosaurs/1
  # DELETE /dinosaurs/1.json
  def destroy
    @dinosaur.destroy

    head :no_content
  end

  private

  def set_dinosaur
    @dinosaur = Dinosaur.find(params[:id])
  end

  def dinosaur_params
    params.require(:dinosaur).permit(:name)
  end
end
