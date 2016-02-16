class DinosaursController < ApplicationController
  before_action :set_dinosaur, only: [:show, :update, :destroy, :to_cage]

  # GET /dinosaurs
  # GET /dinosaurs.json
  def index
    @dinosaurs = Dinosaur.all

    expose @dinosaurs
  end

  # GET /dinosaurs/1
  # # GET /dinosaurs/1.json
  # def show
  #   expose @dinosaur
  # end

  # PUT /dinosaurs/cage
  def to_cage
    @cage = Cage.find(cage_params[:id])
    # As we're using validation on the Cage model to check for error
    # conditions, we cannot simply do either:
    #   @dinosaur.cage = @cage as this would not update the cage's number of dinosaurs until after @dinosaur is saved,
    #   @cage.dinosaurs << @dinosaur as this would autosave the dinosaur before running Cage validations.
    # Instead, we need to add @dinosaur to the Cage's associaton proxy
    @cage.dinosaurs(true).target.append(@dinosaur)

    @dinosaur.cage_id=@cage.id
    #run the cage validations to make sure the dinosaur can go into the cage
    if @cage.invalid?
      error!(:invalid_resource, @cage.errors)
    elsif @dinosaur.save
      expose @dinosaur, {root: :true, except: [:created_at, :updated_at]}
    else
      error!(:invalid_resource, @dinosaur.errors)
    end
  end


  # POST /dinosaurs
  # POST /dinosaurs.json
  def create
    @dinosaur = Dinosaur.new(dinosaur_params)
    if @dinosaur.save
      expose @dinosaur, status: :created, location: @dinosaur
    else
      if @dinosaur.errors.full_messages.include?('Name has already been taken')
        error! :conflict, metadata: {name_already_taken: @dinosaur.name}
      else
        error! :unprocessable_entity, @cage.errors, metadata: @dinosaur
      end
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
    @dinosaur = Dinosaur.find(params[:dinosaur][:id])
  end

  def dinosaur_params
    params.require(:dinosaur).permit(:name, :species_id, :cage_id)
  end

  def species_params
    params[:dinosaur].require(:species).permit(:id)
  end

  def cage_params
    params[:dinosaur].require(:cage).permit(:id)
  end
end
