module ChallengesHelper
  def challenge
    @challenge ||= Challenge.new
  end

  def active_challenge? challenge
    Date.today <= challenge.deadline - challenge.duration
  end

  def commenter_name comment
    if comment.user_id == @challenge.owner_id
      "@#{comment.user.name} (owner*)"
    else
      "@#{comment.user.name}"
    end
  end

  # check if user fails to check_in a challenge
  def failed? participate
    return participate.updated_at != Date.today
  end

  def finished? participate
    duration = Challenge.find(participate.challenge_id).duration
    return participate.continuous_check_in == duration
  end
end
