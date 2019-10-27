if @new_event.present? # @new_eventに中身があれば
  json.array! @new_event # 配列かつjson形式で@new_eventを返す
end