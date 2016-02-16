class DinosaursController < ApplicationController
  before_action :set_dinosaur, only: [:update, :destroy, :to_cage]

  # GET /dinosaurs
  # GET /dinosaurs.json
  def index
    if @filter_on_field.nil?
      @dinosaurs = Dinosaur.all
    else
      #if we're filtering on species_name, convert to regular old name for use in Species
      @filter_on_field = 'name' if @filter_on_field.to_s == 'species_name'

      @dinosaurs = Dinosaur.joins(:species).merge( Species.where(filter_on_field.to_s => filter_on_value))
    end
    exposes @dinosaurs
  end

  # GET /dinosaurs/1
  # GET /dinosaurs/1.json
  def show
    @dinosaur=Dinosaur.find(params[:id])
    exposes @dinosaur, include: [:species, :cage]
  end

  # POST /dinosaurs
  # POST /dinosaurs.json
  def create
    @dinosaur = Dinosaur.new(dinosaur_params)
    if @dinosaur.species_id.nil?
      get_species
    end

    if @dinosaur.save
      expose @dinosaur
    else
      error!(:invalid_resource, @dinosaur.errors)
    end
  end

  # PATCH/PUT /dinosaurs/1
  # PATCH/PUT /dinosaurs/1.json
  def update
    @dinosaur = Dinosaur.find(params[:id])
    if @dinosaur.update(dinosaur_params)
      head :no_content
      expose @dinosaur
    else
      error!(:invalid_resource, @dinosaur.errors)
    end
  end

  # DELETE /dinosaurs/1
  # DELETE /dinosaurs/1.json
  def destroy
    @dinosaur.destroy
    head :no_content
  end

  # PUT /dinosaurs/cage
  def to_cage
    @cage = Cage.find(@dinosaur.cage_id || cage_params[:id])
    # As we're using validation on the Cage model to check for error
    # conditions, we cannot simply do either:
    #   @dinosaur.cage = @cage as this would not update the cage's number of dinosaurs until after @dinosaur is saved,
    #   @cage.dinosaurs << @dinosaur as this would autosave the dinosaur before running Cage validations.
    #   either the @dinosaur.build_cage or @cage.dinosaurs.build methods for assignment, as the virtual attributes
    #   we define for easier user API calls and returns pose problems. Yet another reason why active_model_serializers
    #   is far better than the serializable_hash - based foo Rails 4.2 put in (which am using, but shouldn't have!)
    # Instead, we need to add @dinosaur to the Cage's associaton proxy. However, doing this means we need
    # to guard against the case where someone is trying to assign the dinosaur to a cage it's already in.
    @cage.dinosaurs(true).target.append(@dinosaur) unless @dinosaur.cage_id == @cage.id

    @dinosaur.cage=@cage if @dinosaur.cage_id.nil?
    #run the cage validations to make sure the dinosaur can go into the cage
    if @cage.invalid?
      error!(:invalid_resource, @cage.errors)
    elsif @dinosaur.save
      expose @dinosaur
    else
      error!(:invalid_resource, @dinosaur.errors)
    end
  end

  private

  def set_dinosaur
    @dinosaur = Dinosaur.find_by!(name: dinosaur_params[:name])
    if @dinosaur.species_id.nil?
      get_species
    end
  end

  def dinosaur_params
    params.require(:dinosaur).permit(:id, :name, :species_name, :species, :species_id, :cage, :cage_id)
  end

  def cage_params
    params[:dinosaur].fetch(:cage, {}).permit(:id, :max_occupancy,:current_occupancy, :powered_up)
  end

  def species_params
    params[:dinosaur].fetch(:species, {}).permit(:id, :name)
  end

  def get_species
    find_name = (@dinosaur.species_name || species_params[:name])
    @dinosaur.species = Species.find_by_name!(find_name)
    @dinosaur.species_name
  rescue Exception => e
    @dinosaur.errors.add(e.message, find_name)
    error! :invalid_resource, @dinosaur.errors
  end
end

