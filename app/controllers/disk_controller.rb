# frozen_string_literal: true
require 'chilkat'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'
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
    @filename   = params[:picture].original_filename
    http        = Chilkat::CkHttp.new()
    file_access = Chilkat::CkFileAccess.new()
    file_access.OpenForRead(params[:picture].tempfile.path)
    file = Chilkat::CkBinData.new()
    file_access.FileReadBd(99999999, file)
    req = Chilkat::CkHttpRequest.new()
    req.put_HttpVerb("PUT")
    req.put_Path("/v1.0/drives/b!4RLrdQRYMESPvzn0DdDqqAqGVRfGWQ5DphR78v4tUrJUN3JKcWcZR5ZgBRL_7WsY/items/01VRBOIKPBEO3H4OPHT5FL5EGYOJUGVA57:/#{@filename}:/content")
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
        send_to_chat
        redirect_to disk_path, notice: 'Pomyślnie przesłano plik'
      end
    end
  end

  private

  def send_to_chat
    url                  = "https://graph.microsoft.com/beta/me/chats/19:2af3feeab396426bb0d91238f98e2b61@thread.v2/messages"
    @uri                 = URI.parse(url)
    req                  = Net::HTTP::Post.new(@uri)
    req['Accept']        = 'application/json'
    req['Content-Type']  = 'application/json'
    req['Authorization'] = "Bearer #{session[:graph_token_hash][:token]}"
    req.body             = { 'body' => { 'content' => "Przesłano plik: #{@filename}" } }.to_json.to_s
    @res                 = https.request(req)
  end

  def https
    https             = Net::HTTP.new(@uri.host, @uri.port)
    https.use_ssl     = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    https
  end
end
