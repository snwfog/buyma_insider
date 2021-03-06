class UserArticleSoldsController < ApplicationController
  options '/**' do
    ;
  end

  before '/:id(/**)?' do
    param :id, String, required: true

    @ua_sold = UserArticleSold.find(params[:id])
  end

  get '/:id/shipping_services' do
    json @ua_sold.shipping_services
  end

  get '/:id' do
    json @ua_sold
  end

  patch '/:id' do
    request.body.rewind
    payload = JSON.parse(request.body.read)

    if buyer_embedded_payload = payload.dig('data', 'buyer')
      payload['data'].delete('buyer')
      buyer_attrs      = extract_attributes(buyer_embedded_payload)
      buyer            = Buyer.find_or_initialize_by(email_address: buyer_attrs[:email_address])
      buyer.attributes = buyer_attrs if buyer.new_record?

      @ua_sold.transaction do
        buyer.save!
        @ua_sold.buyer = buyer
        @ua_sold.save!
      end
    end

    ua_sold_json = extract_attributes(payload)
    @ua_sold.update!(ua_sold_json)
    status :ok
    json @ua_sold
  end
end