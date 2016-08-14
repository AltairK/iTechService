json.array! @devices.decorate do |device|
  json.extract! device, :id, :product_id
  json.url item_url(device.id, format: :json)
  json.label device.presentation
  json.value device.id
end
