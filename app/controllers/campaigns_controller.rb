class CampaignsController < ApplicationController
  before_filter :authenticate_user!
end
