json.extract! user, :id, :name, :email, :password, :coins, :chechin_number, :challenge_number, :created_at, :updated_at
json.url user_url(user, format: :json)
