# frozen_string_literal: true

# Disk controller
class DiskController < ApplicationController
  include GraphHelper

  def index
    get_disk_view(access_token)
  end
end
