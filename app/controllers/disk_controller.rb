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

  # TODO https://www.example-code.com/ruby/onedrive_upload_binary_data_from_memory.asp tutorial to fix
  def create
    http = Chilkat::CkHttp.new()
    file_access = Chilkat::CkFileAccess.new()
    file_access.OpenForRead(params[:picture].tempfile.path)
    file = Chilkat::CkBinData.new()
    # file_access.AppendBd(file)
    file_access.FileReadBd(99999999, file)
    req = Chilkat::CkHttpRequest.new()
    req.put_HttpVerb("PUT")
    req.put_Path("/v1.0/drives/b!4RLrdQRYMESPvzn0DdDqqAqGVRfGWQ5DphR78v4tUrJUN3JKcWcZR5ZgBRL_7WsY/items/01VRBOIKPBEO3H4OPHT5FL5EGYOJUGVA57:/file_icon.png:/content")
    req.LoadBodyFromBd(file)
    req.put_ContentType("application/octet-stream")
    req.AddHeader('Authorization', "Bearer #{session[:graph_token_hash][:token]}")
    resp = http.SynchronousRequest("graph.microsoft.com",443,true,req)
    if (http.get_LastMethodSuccess() != true)
      print http.lastErrorText() + "\n";
      exit
    end
    json = Chilkat::CkJsonObject.new()
    json.put_EmitCompact(false)
    json.Load(resp.bodyStr())

    if (resp.get_StatusCode() != 201)
      print json.emit() + "\n";
      print "Response status = " + resp.get_StatusCode().to_s() + "\n";

      exit
    end
    print json.emit() + "\n";
    print "@@ Success @@" + "\n";
    file_access.FileClose()
  end
end
