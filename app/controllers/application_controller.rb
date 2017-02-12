class ApplicationController < ActionController::API
  def validate_signed_in
    head 401 unless current_user
  end
end
