# frozen_string_literal: true
require 'chilkat'
# Disk controller
class DiskController < ApplicationController
  include GraphHelper

  def index
    response     = get_disk_view(access_token)
    @files_names = response["value"].map { |obj| obj["name"] }
  end

  def new

  end

  def create
    http        = Chilkat::CkHttp.new()
    file_access = Chilkat::CkFileAccess.new()
    file_access.OpenForRead(params[:picture].tempfile.path)
    file = Chilkat::CkBinData.new()
    file_access.FileReadBd(99999999, file)
    req = Chilkat::CkHttpRequest.new()
    req.put_HttpVerb("PUT")
    req.put_Path("/v1.0/drives/b!4RLrdQRYMESPvzn0DdDqqAqGVRfGWQ5DphR78v4tUrJUN3JKcWcZR5ZgBRL_7WsY/items/01VRBOIKPBEO3H4OPHT5FL5EGYOJUGVA57:/#{params[:picture].original_filename}:/content")
    req.LoadBodyFromBd(file)
    req.put_ContentType("application/octet-stream")
    req.AddHeader('Authorization', "Bearer #{session[:graph_token_hash][:token]}")
    resp = http.SynchronousRequest("graph.microsoft.com", 443, true, req)
    if (http.get_LastMethodSuccess() != true)
      # print http.lastErrorText() + "\n"; DEBUG
      redirect_to disk_new_path, alert: 'Nie udało się przesłać pliku'
    else
      json = Chilkat::CkJsonObject.new()
      json.put_EmitCompact(false)
      json.Load(resp.bodyStr())
      if (resp.get_StatusCode() != 201 && resp.get_StatusCode() != 200)
        # print json.emit() + "\n"; DEBUG
        redirect_to disk_new_path, alert: 'Nie udało się przesłać pliku'
      else
        file_access.FileClose()
        redirect_to disk_path, notice: 'Pomyślnie przesłano plik'
      end
    end
  end
end
