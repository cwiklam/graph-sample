# frozen_string_literal: true
require 'chilkat'
# Disk controller
class DiskController < ApplicationController
  include GraphHelper

  def index
    response = get_disk_view(access_token)
    @files_names = response["value"].map{|obj| obj["name"]}
  end

  def new

  end

  def create
    http = Chilkat::CkHttp.new()
    content = File.read(params[:picture].tempfile)
    file = Chilkat::CkBinData.new()
    file.AppendEncoded(content, 'UTF-8')
    req = Chilkat::CkHttpRequest.new()
    req.put_HttpVerb("PUT")
    req.put_Path("/v1.0/drives/b!4RLrdQRYMESPvzn0DdDqqAqGVRfGWQ5DphR78v4tUrJUN3JKcWcZR5ZgBRL_7WsY/items/01VRBOIKPBEO3H4OPHT5FL5EGYOJUGVA57:/file_icon.png:/content")
    req.LoadBodyFromBd(file)
    req.put_ContentType("application/octet-stream")
    resp = http.SynchronousRequest("graph.microsoft.com",443,true,req)
    # TODO https://www.example-code.com/ruby/onedrive_upload_binary_data_from_memory.asp tutorial to fix
    binding.pry
  end
end
