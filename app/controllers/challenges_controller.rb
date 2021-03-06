class ChallengesController < ApplicationController
  before_action :set_challenge, only: [:show, :edit, :update, :destroy]
  before_action :set_host_for_local_storage, only: [:new, :create, :show, :edit, :update, :destroy]


  # GET /challenges
  # GET /challenges.json
  def index
    @challenges = Challenge.all
  end

  def filter
    text = params[:q]
    puts text
    puts params[:filter]+'!!!!'

    if params[:filter] == 'All'
      if !text.nil?
        challenges = Challenge.where('lower(name) like ?', "%#{text.downcase}%")
      else
        challenges = Challenge.all
      end
    else
      if !text.nil?
        challenges = Challenge.where("category = ? AND lower(name) like ?", params[:filter], "%#{text.downcase}%")
      else
        challenges = Challenge.where(category: params[:filter])
      end
    end
    render 'challenges/filter_result', locals: {challenges: challenges, filter: params[:filter]}
  end



  # GET /challenges/1
  # GET /challenges/1.json
  def show
    @comments = Comment.where(challenge_id: @challenge).order("created_at")
    @owner = User.where(id: @challenge.owner_id).first # find the owner of the challenge
  end

  # GET /challenges/new
  def new
    @challenge = Challenge.new
  end

  # GET /challenges/1/edit
  def edit
  end

  # POST /challenges
  # POST /challenges.json
  def create
    @challenge = Challenge.new(challenge_params)
    @challenge.owner_id = current_user.id
    @challenge.participant_number = 0
    @challenge.failed_number = 0
    Activity.create(user_id: current_user.id, challenge_id: @challenge.id, relation:"Created")
    if @challenge.image.attached?
      @challenge.pic_link = @challenge.image.service_url
    end
    respond_to do |format|
      if @challenge.save
        format.html { redirect_to @challenge, notice: 'Challenge was successfully created.' }
        format.json { render :show, status: :created, location: @challenge }
      else
        format.html { render :new }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /challenges/1
  # PATCH/PUT /challenges/1.json
  def update
    respond_to do |format|
      if @challenge.update(challenge_params)
        format.html { redirect_to @challenge, notice: 'Challenge was successfully updated.' }
        format.json { render :show, status: :ok, location: @challenge }
      else
        format.html { render :edit }
        format.json { render json: @challenge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /challenges/1
  # DELETE /challenges/1.json
  def destroy
    remove_user_participation @challenge.id
    Activity.create(user_id: current_user.id, challenge_id: @challenge.id, relation:"Deleted")
    @challenge.destroy
    respond_to do |format|
      format.html { redirect_to challenges_url, notice: 'Challenge was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def to_icalender
    @challenge = Challenge.find(params[:challenge_id])
    ChallengeMailer.with(challenge: @challenge, user: current_user).new_challenge_email.deliver_later
    # redirect_to(@challenge, :notice => 'Calendar sent')
    respond_to do |format|
      format.html { redirect_to @challenge, notice: 'check email' }
      format.json { render :show, status: :ok, location: @challenge }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_challenge
    @challenge = Challenge.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def challenge_params
    params.require(:challenge).permit(:name, :category, :description, :coins, :duration, :participant_number, :failed_number, :deadline, :image, :video)
  end

  def set_host_for_local_storage
    ActiveStorage::Current.host = request.base_url if Rails.application.config.active_storage.service == :local
  end
  
end
