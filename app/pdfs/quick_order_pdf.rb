# encoding: utf-8
class QuickOrderPdf < Prawn::Document
  require 'prawn/measurement_extensions'

  def initialize(quick_order, view)
    super page_size: [80.mm, 60.mm], page_layout: :portrait, margin: 10
    @quick_order = quick_order
    @view = view
    font_families.update 'DroidSans' => {
      normal: "#{Rails.root}/app/assets/fonts/droidsans-webfont.ttf",
      bold: "#{Rails.root}/app/assets/fonts/droidsans-bold-webfont.ttf"
    }
    font 'DroidSans'
    client_part
    start_new_page
    receiver_part
    encrypt_document permissions: { modify_contents: false }
  end

  def client_part
    logo
    move_down 22
    font_size 24 do
      text "№ #{@quick_order.number_s}", align: :center, inlign_format: true, style: :bold
    end
    move_down 30
    text @view.t('tickets.user', name: @quick_order.user_short_name)
    move_down 5
    horizontal_line 0, 205
    stroke
    move_down 5
    text @view.t('tickets.contact_phone', number: @quick_order.user.try(:department).try(:contact_phone))
  end

  def receiver_part
    font_size 24 do
      text "№ #{@quick_order.number_s}", align: :center, inlign_format: true, style: :bold
    end
    text @quick_order.client_name
    text @quick_order.contact_phone
    move_down 5
    horizontal_line 0, 205
    stroke
    move_down 5
    text @view.t('tickets.operations_list')
    text @quick_order.quick_tasks.map(&:name).join(', ')
    move_down 5
    horizontal_line 0, 205
    stroke
    move_down 5
    text @view.t('tickets.user', name: @quick_order.user_short_name)
  end

  private

  def logo
    image File.join(Rails.root, 'app/assets/images/logo.jpg'), width: 50, height: 50, at: [0, cursor-10]
  end

end